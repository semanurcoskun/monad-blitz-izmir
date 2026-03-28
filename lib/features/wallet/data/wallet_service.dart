import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

/// Monad Testnet chain configuration
class MonadConfig {
  static const int chainId = 10143;
  static const String chainIdHex = '0x27AF';
  static const String rpcUrl = 'https://testnet-rpc.monad.xyz';
  static const String networkName = 'Monad Testnet';
  static const String symbol = 'MON';
  static const String explorerUrl = 'https://testnet.monadexplorer.com';
  static const String namespace = 'eip155';
  static const String chainRef = 'eip155:10143';
}

/// WalletConnect v2 service for MetaMask integration
class WalletService {
  static const String _projectId = 'bedb28c546196ab66272d04884ba9013';
  static const String _savedAddressKey = 'connected_wallet_address';
  static const String _pendingConnectionKey = 'wallet_connection_pending';

  Web3App? _web3app;
  SessionData? _session;
  String? _connectedAddress;

  String? get connectedAddress => _connectedAddress;
  bool get isConnected => _connectedAddress != null; // Simpler check for now
  bool get hasActiveSession => _session != null;

  /// Callback when a session is connected
  Function(SessionData)? onSessionConnect;
  
  /// Callback when a session is deleted
  Function()? onSessionDelete;

  /// Initialize the WalletConnect Web3App
  Future<void> init() async {
    if (_web3app == null) {
      debugPrint('WalletService: Initializing Web3App...');
      _web3app = await Web3App.createInstance(
        projectId: _projectId,
        metadata: const PairingMetadata(
          name: 'The Kinetic Ledger',
          description: 'Blockchain-powered travel ticketing on Monad',
          url: 'https://walletconnect.com',
          icons: ['https://walletconnect.com/walletconnect-logo.png'],
          redirect: Redirect(
            native: 'kineticledger://',
            universal: null,
          ),
        ),
      );

      // Listen for relay events
      _web3app!.core.relayClient.onRelayClientConnect.subscribe((dynamic event) {
        debugPrint('WalletService: Relay client connected');
      });

      _web3app!.core.relayClient.onRelayClientError.subscribe((dynamic event) {
        debugPrint('WalletService: Relay client error: $event');
      });

      _web3app!.core.relayClient.onRelayClientDisconnect.subscribe((dynamic event) {
        debugPrint('WalletService: Relay client disconnected');
      });

      // Listen for session connect events
      _web3app!.onSessionConnect.subscribe((SessionConnect? event) {
        debugPrint('WalletService: onSessionConnect event received!');
        if (event != null) {
          _session = event.session;
          _extractAddress();
          debugPrint('WalletService: Connected to $_connectedAddress');
          onSessionConnect?.call(event.session);
        }
      });

      // Listen for session delete events
      _web3app!.onSessionDelete.subscribe((SessionDelete? event) {
        debugPrint('WalletService: onSessionDelete event received');
        _session = null;
        _connectedAddress = null;
        onSessionDelete?.call();
      });
    }

    // Ensure relayer is connected (important when resuming from background)
    await waitForRelay();

    // Try to restore existing session
    await _restoreSession();
  }

  /// Wait up to 5 seconds for relayer to connect
  Future<bool> waitForRelay() async {
    if (_web3app == null) return false;
    
    if (_web3app!.core.relayClient.isConnected) return true;

    debugPrint('WalletService: Relayer disconnected, connecting...');
    await _web3app!.core.relayClient.connect();
    
    int retries = 0;
    while (!_web3app!.core.relayClient.isConnected && retries < 10) {
      await Future.delayed(const Duration(milliseconds: 500));
      retries++;
    }
    
    debugPrint('WalletService: Relayer connected: ${_web3app!.core.relayClient.isConnected}');
    return _web3app!.core.relayClient.isConnected;
  }

  /// Attempt to restore a previously saved session
  Future<bool> _restoreSession() async {
    if (_web3app == null) return false;

    final sessions = _web3app!.getActiveSessions();
    
    if (sessions.isNotEmpty) {
      _session = sessions.values.first;
      _extractAddress();
      debugPrint('WalletService: Restored active session for $_connectedAddress');
      
      // Cache the address
      if (_connectedAddress != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_savedAddressKey, _connectedAddress!);
      }
      return true;
    } else {
      // Try to get saved address from local storage as fallback
      final prefs = await SharedPreferences.getInstance();
      _connectedAddress = prefs.getString(_savedAddressKey);
      if (_connectedAddress != null) {
        debugPrint('WalletService: Found cached address from prefs (no active session): $_connectedAddress');
        return true;
      }
    }
    return false;
  }

  /// Lightweight check for active sessions without re-initializing everything
  Future<bool> checkActiveSessions() async {
    if (_web3app == null) return false;
    
    // Just refresh the active session list
    return await _restoreSession();
  }

  /// Start connection flow and return the ConnectResponse for async tracking.
  /// This launches MetaMask but does NOT wait for session approval.
  Future<ConnectResponse?> connectAndGetResponse() async {
    // 1. Ensure relay is active and connected
    if (_web3app == null) await init();
    await waitForRelay();

    try {
      debugPrint('WalletService: Creating connection request...');
      
      // Set pending flag in storage before launching MetaMask
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_pendingConnectionKey, true);

      // Using optionalNamespaces instead of requiredNamespaces.
      // This is more robust as it allows the wallet to connect even if it
      // doesn't "know" the Monad chain yet.
      final ConnectResponse response = await _web3app!.connect(
        optionalNamespaces: {
          MonadConfig.namespace: const RequiredNamespace(
            chains: ['eip155:1', MonadConfig.chainRef], // Ethereum Mainnet fallback + Monad
            methods: [
              'eth_sendTransaction', 
              'eth_signTransaction', 
              'personal_sign', 
              'eth_signTypedData'
            ],
            events: ['chainChanged', 'accountsChanged'],
          ),
        },
      ).timeout(const Duration(seconds: 15));

      // Launch MetaMask
      final uri = response.uri;
      if (uri != null) {
        final uriString = uri.toString();
        debugPrint('WalletService: Generated WC URI: $uriString');

        bool launched = false;
        try {
          // Launch the wc: uri directly - Android will show registered apps (MetaMask)
          launched = await launchUrl(Uri.parse(uriString), mode: LaunchMode.externalNonBrowserApplication);
          debugPrint('WalletService: Direct WC launch result: $launched');
        } catch (e) {
          debugPrint('WalletService: Direct launch error: $e');
        }

        if (!launched) {
          debugPrint('WalletService: Trying universal link fallback...');
          final encodedUri = Uri.encodeComponent(uriString);
          final httpsUri = Uri.parse('https://metamask.app.link/wc?uri=$encodedUri');
          launched = await launchUrl(httpsUri, mode: LaunchMode.externalApplication);
          debugPrint('WalletService: Universal link launch result: $launched');
        }
      }

      return response;
    } catch (e) {
      debugPrint('WalletService: Connection start error (might be timeout): $e');
      return null;
    }
  }

  /// Set the session after approval and save address
  Future<void> setSession(SessionData session) async {
    _session = session;
    _extractAddress();

    if (_connectedAddress != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_savedAddressKey, _connectedAddress!);
      await prefs.remove(_pendingConnectionKey); // Clear pending flag
    }
  }

  /// Check if a connection was pending before app restart
  Future<bool> wasConnectionPending() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_pendingConnectionKey) ?? false;
  }

  /// Clear the pending connection flag
  Future<void> clearConnectionPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingConnectionKey);
  }

  /// Extract the connected wallet address from the session
  void _extractAddress() {
    if (_session == null) return;

    final accounts = _session!.namespaces[MonadConfig.namespace]?.accounts;
    if (accounts != null && accounts.isNotEmpty) {
      // Format: "eip155:10143:0xABC..."
      _connectedAddress = accounts.first.split(':').last;
    }
  }

  /// Get the MON token balance for the connected address
  Future<double> getBalance() async {
    if (_connectedAddress == null) return 0.0;

    try {
      final response = await http.post(
        Uri.parse(MonadConfig.rpcUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'eth_getBalance',
          'params': [_connectedAddress, 'latest'],
          'id': 1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hexBalance = data['result'] as String;
        final weiBalance = BigInt.parse(hexBalance);
        // Convert wei to MON (18 decimals)
        return weiBalance / BigInt.from(10).pow(18);
      }
    } catch (e) {
      debugPrint('WalletService: Balance check error: $e');
    }
    return 0.0;
  }

  /// Get a shortened version of the address (0x12...34Ab)
  String get shortenedAddress {
    if (_connectedAddress == null) return '';
    final addr = _connectedAddress!;
    if (addr.length < 10) return addr;
    return '${addr.substring(0, 6)}...${addr.substring(addr.length - 4)}';
  }

  /// Disconnect the wallet
  Future<void> disconnect() async {
    if (_session != null && _web3app != null) {
      try {
        await _web3app!.disconnectSession(
          topic: _session!.topic,
          reason: const WalletConnectError(code: 6000, message: 'User disconnected'),
        );
      } catch (_) {}
    }

    _session = null;
    _connectedAddress = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedAddressKey);
  }

  /// Dispose resources
  void dispose() {
    // Web3App handles its own cleanup
  }
}
