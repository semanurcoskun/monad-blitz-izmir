import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_flutter_projesi/core/theme/app_colors.dart';
import 'package:yeni_flutter_projesi/core/widgets/kinetic_card.dart';
import 'package:yeni_flutter_projesi/features/wallet/presentation/providers/wallet_provider.dart';

class NftTicketsPage extends ConsumerWidget {
  const NftTicketsPage({super.key});

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
              _buildInventoryStats(context),
              const SizedBox(height: 24),
              _buildTicketCard(
                context,
                id: 'MN-0025-A2',
                from: 'IST',
                to: 'ANK',
                seat: '12A',
                type: 'FLIGHT',
                isMonad: true,
              ),
              const SizedBox(height: 16),
              _buildTicketCard(
                context,
                id: 'OB-9912-B1',
                from: 'PAR',
                to: 'LDN',
                seat: '4B',
                type: 'BUS',
                isMonad: false,
              ),
              const SizedBox(height: 32),
              _buildExploreDestinations(context),
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
          'KINETIC INVENTORY',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            walletState.shortenedAddress ?? '0x...',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryStats(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Assets',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
            Text('03', style: Theme.of(context).textTheme.headlineMedium),
          ],
        ),
        const Spacer(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Network',
              style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
            ),
            const Text(
              'Monad Mainnet',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketCard(
    BuildContext context, {
    required String id,
    required String from,
    required String to,
    required String seat,
    required String type,
    required bool isMonad,
  }) {
    final Color brandColor = isMonad ? AppColors.primary : AppColors.secondary;

    return KineticCard(
      hasAmbientShadow: true,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: brandColor.withValues(alpha: 0.05),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      type == 'FLIGHT'
                          ? Icons.airplanemode_active
                          : Icons.directions_bus,
                      size: 16,
                      color: brandColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: brandColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  id,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRouteNode(from, 'Istanbul'),
                    Icon(
                      Icons.arrow_forward,
                      color: AppColors.outlineVariant,
                      size: 20,
                    ),
                    _buildRouteNode(to, 'Ankara', isEnd: true),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTicketInfo('SEAT', seat),
                    _buildTicketInfo('CLASS', 'Premium'),
                    _buildTicketInfo('STATUS', 'VERIFIED', isVerified: true),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: brandColor.withValues(alpha: 0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'VIEW EXPLORER',
                          style: TextStyle(color: brandColor, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brandColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 0),
                        ),
                        child: const Text(
                          'DOWNLOAD PASS',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteNode(String code, String city, {bool isEnd = false}) {
    return Column(
      crossAxisAlignment: isEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          code,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          city,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildTicketInfo(
    String label,
    String value, {
    bool isVerified = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            if (isVerified)
              const Icon(Icons.verified, size: 12, color: Colors.green),
            if (isVerified) const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExploreDestinations(BuildContext context) {
    return KineticCard(
      color: AppColors.surfaceContainerHigh,
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Looking for more?',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'Discover new destinations globally.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('EXPLORE'),
          ),
        ],
      ),
    );
  }
}
