import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_flutter_projesi/core/theme/app_colors.dart';
import 'package:yeni_flutter_projesi/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:yeni_flutter_projesi/features/navigation/presentation/pages/main_navigation_page.dart';

class ConnectWalletPage extends ConsumerStatefulWidget {
  const ConnectWalletPage({super.key});

  @override
  ConsumerState<ConnectWalletPage> createState() => _ConnectWalletPageState();
}

class _ConnectWalletPageState extends ConsumerState<ConnectWalletPage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    // Listen for app lifecycle to detect return from MetaMask
    WidgetsBinding.instance.addObserver(this);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Initialize wallet and check for existing session
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(walletProvider.notifier).init();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app is resumed from MetaMask, check if session was approved
    if (state == AppLifecycleState.resumed) {
      final walletState = ref.read(walletProvider);
      if (walletState.isConnecting) {
        // Force re-check the session - the future might already be resolved
        // Give it a small delay for WalletConnect relay to process
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            ref.read(walletProvider.notifier).checkPendingSession();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final walletState = ref.watch(walletProvider);

    // Navigate to main page when connected
    ref.listen<WalletState>(walletProvider, (prev, next) {
      if (next.isConnected && mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainNavigationPage()),
          (route) => false,
        );
      }
    });

    // Prevent back button from going to main page
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                // Logo & Branding
                _buildLogo(),
                const SizedBox(height: 24),
                const Text(
                  'THE KINETIC\nLEDGER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3.0,
                    height: 1.1,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Blockchain-powered travel on Monad',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(flex: 2),
                // Network Badge
                _buildNetworkBadge(),
                const SizedBox(height: 32),
                // Connect Button
                _buildConnectButton(walletState),
                const SizedBox(height: 16),
                // Manual retry link (only if connecting for a few seconds)
                if (walletState.isConnecting)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextButton(
                      onPressed: () =>
                          ref.read(walletProvider.notifier).checkPendingSession(),
                      child: Text(
                        'Hala bekliyor musunuz? Tekrar kontrol et',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.primary.withValues(alpha: 0.8),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                // Error message
                if (walletState.status == WalletConnectionStatus.error)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      walletState.errorMessage ?? 'Bağlantı hatası',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                // Info text
                Text(
                  'MetaMask cüzdanınızı bağlayarak\nMonad Testnet üzerinde giriş yapın',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    height: 1.5,
                  ),
                ),
                const Spacer(flex: 1),
                // Bottom branding
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Powered by Monad',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryContainer,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: 8,
            ),
          ],
        ),
        child: const Icon(
          Icons.diamond_outlined,
          size: 48,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildNetworkBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Monad Testnet',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectButton(WalletState walletState) {
    final isConnecting = walletState.isConnecting;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isConnecting
            ? null
            : () => ref.read(walletProvider.notifier).connect(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isConnecting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_wallet, size: 22),
                  SizedBox(width: 12),
                  Text(
                    'CONNECT WITH METAMASK',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
