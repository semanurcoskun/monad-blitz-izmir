import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
import 'package:yeni_flutter_projesi/features/wallet/data/wallet_service.dart';

/// Wallet connection states
enum WalletConnectionStatus { disconnected, connecting, connected, error }

/// State class for wallet
class WalletState {
  final WalletConnectionStatus status;
  final String? address;
  final String? shortenedAddress;
  final double balance;
  final String? errorMessage;

  const WalletState({
    this.status = WalletConnectionStatus.disconnected,
    this.address,
    this.shortenedAddress,
    this.balance = 0.0,
    this.errorMessage,
  });

  WalletState copyWith({
    WalletConnectionStatus? status,
    String? address,
    String? shortenedAddress,
    double? balance,
    String? errorMessage,
  }) {
    return WalletState(
      status: status ?? this.status,
      address: address ?? this.address,
      shortenedAddress: shortenedAddress ?? this.shortenedAddress,
      balance: balance ?? this.balance,
      errorMessage: errorMessage,
    );
  }

  bool get isConnected => status == WalletConnectionStatus.connected;
  bool get isConnecting => status == WalletConnectionStatus.connecting;
}

/// Global wallet service instance
final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

/// Notifier for wallet state management using Riverpod v3 Notifier pattern
class WalletNotifier extends Notifier<WalletState> {
  @override
  WalletState build() => const WalletState();

  WalletService get _walletService => ref.read(walletServiceProvider);

  /// Initialize and try to restore previous session
  Future<void> init() async {
    debugPrint('WalletNotifier: Initializing...');
    
    // Setup listeners before calling service init
    _walletService.onSessionConnect = (session) async {
      debugPrint('WalletNotifier: onSessionConnect callback triggered!');
      final balance = await _walletService.getBalance();
      
      // Update state to connected
      state = WalletState(
        status: WalletConnectionStatus.connected,
        address: _walletService.connectedAddress,
        shortenedAddress: _walletService.shortenedAddress,
        balance: balance,
      );
    };

    _walletService.onSessionDelete = () {
      debugPrint('WalletNotifier: onSessionDelete callback triggered');
      state = const WalletState(status: WalletConnectionStatus.disconnected);
    };

    await _walletService.init();
    
    // Don't auto-resume checkPendingSession, just let the user press the button
    // But we can check if address was already restored by _walletService.init()
    /*
    if (_walletService.isConnected) {
      final balance = await _walletService.getBalance();
      state = WalletState(
        status: WalletConnectionStatus.connected,
        address: _walletService.connectedAddress,
        shortenedAddress: _walletService.shortenedAddress,
        balance: balance,
      );
    } else {
      state = const WalletState(status: WalletConnectionStatus.disconnected);
    }
    */
  }

  /// Connect wallet via MetaMask
  Future<void> connect() async {
    debugPrint('WalletNotifier: Starting connection flow...');
    state = state.copyWith(status: WalletConnectionStatus.connecting);

    final response = await _walletService.connectAndGetResponse();

    if (response == null) {
      debugPrint('WalletNotifier: ConnectResponse was null');
      state = WalletState(
        status: WalletConnectionStatus.error,
        errorMessage: 'Bağlantı başlatılamadı. Tekrar deneyin.',
      );
      return;
    }

    // We rely on onSessionConnect event for the main transition, 
    // but _waitForSession is a backup.
    _waitForSession(response);
  }

  /// Wait for the session future to complete (Backup to the event listener)
  Future<void> _waitForSession(ConnectResponse response) async {
    try {
      debugPrint('WalletNotifier: Waiting for session future...');
      final session = await response.session.future.timeout(
        const Duration(minutes: 3),
      );

      debugPrint('WalletNotifier: Session future resolved!');
      // Only update if not already connected via the listener
      if (state.status != WalletConnectionStatus.connected) {
        await _walletService.setSession(session);
        final balance = await _walletService.getBalance();

        state = WalletState(
          status: WalletConnectionStatus.connected,
          address: _walletService.connectedAddress,
          shortenedAddress: _walletService.shortenedAddress,
          balance: balance,
        );
      }
    } catch (e) {
      debugPrint('WalletNotifier: Session future error or timeout: $e');
      // Only error out if we aren't already connected via the listener
      if (state.status == WalletConnectionStatus.connecting) {
        state = WalletState(
          status: WalletConnectionStatus.error,
          errorMessage: 'MetaMask oturumu zaman aşımına uğradı.',
        );
      }
    }
  }

  /// Called from lifecycle observer when app is resumed from MetaMask
  /// Re-checks active sessions if a connection is pending
  Future<void> checkPendingSession() async {
    if (state.status != WalletConnectionStatus.connecting) return;

    debugPrint('WalletNotifier: App resumed, starting session check loop...');
    
    // Try up to 5 times (total ~10 seconds)
    for (int i = 0; i < 5; i++) {
      debugPrint('WalletNotifier: Session check attempt ${i + 1}...');
      
      // Refresh state
      await _walletService.init();
      
      if (_walletService.isConnected) {
        debugPrint('WalletNotifier: Found active session on attempt ${i + 1}!');
        // ... navigation happens through ref.listen
        return;
      }
      
      // Delay before next check
      await Future.delayed(const Duration(seconds: 2));
    }
    
    debugPrint('WalletNotifier: No session found after all retries');
  }

  /// Disconnect wallet
  Future<void> disconnect() async {
    debugPrint('WalletNotifier: Disconnecting...');
    await _walletService.disconnect();
    state = const WalletState(status: WalletConnectionStatus.disconnected);
  }

  /// Refresh balance
  Future<void> refreshBalance() async {
    if (state.isConnected) {
      final balance = await _walletService.getBalance();
      state = state.copyWith(balance: balance);
    }
  }
}

/// Global wallet state provider
final walletProvider = NotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);
