import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_flutter_projesi/core/theme/app_colors.dart';
import 'package:yeni_flutter_projesi/core/widgets/kinetic_card.dart';
import 'package:yeni_flutter_projesi/features/wallet/presentation/providers/wallet_provider.dart';
import 'package:yeni_flutter_projesi/features/wallet/data/wallet_service.dart';

class WalletPage extends ConsumerWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletState = ref.watch(walletProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(walletState),
              const SizedBox(height: 32),
              _buildBalanceCard(context, walletState),
              const SizedBox(height: 24),
              _buildNetworkInfo(),
              const SizedBox(height: 24),
              _buildActions(context, ref),
              const SizedBox(height: 32),
              _buildTransactionHistory(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WalletState walletState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'WALLET',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                walletState.shortenedAddress ?? '...',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBalanceCard(BuildContext context, WalletState walletState) {
    return KineticCard(
      hasAmbientShadow: true,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Balance',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                walletState.balance.toStringAsFixed(4),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'MON',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              walletState.address ?? '',
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.onSurfaceVariant,
                fontFamily: 'monospace',
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkInfo() {
    return KineticCard(
      color: AppColors.surfaceContainerHigh,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.diamond_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Monad Testnet',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Chain ID: ${MonadConfig.chainId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.green.shade400,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(walletProvider.notifier).refreshBalance();
            },
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('REFRESH'),
            style: OutlinedButton.styleFrom(
              side: BorderSide(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () async {
              await ref.read(walletProvider.notifier).disconnect();
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/connect',
                  (route) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, size: 18),
            label: const Text('DISCONNECT'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'RECENT ACTIVITY',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        KineticCard(
          color: AppColors.surfaceContainerLow,
          child: const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 32,
                    color: AppColors.outlineVariant,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No recent transactions',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
