import 'package:flutter/material.dart';
import 'package:yeni_flutter_projesi/core/theme/app_colors.dart';
import 'package:yeni_flutter_projesi/core/widgets/kinetic_card.dart';

class RouteResultsPage extends StatelessWidget {
  const RouteResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('London (LHR) -> Paris (CDG)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                _buildRouteCard(
                  context,
                  departure: '08:45',
                  arrival: '10:15',
                  price: '240.50',
                  duration: '1h 30m',
                  type: 'FLIGHT',
                  isFastest: true,
                  isMonad: true,
                ),
                const SizedBox(height: 16),
                _buildRouteCard(
                  context,
                  departure: '12:30',
                  arrival: '14:00',
                  price: '215.10',
                  duration: '1h 30m',
                  type: 'FLIGHT',
                  isMonad: true,
                ),
                const SizedBox(height: 16),
                _buildRouteCard(
                  context,
                  departure: '09:00',
                  arrival: '16:45',
                  price: '45.00',
                  duration: '7h 45m',
                  type: 'BUS',
                  isMonad: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildFilterChip('Cheapest', false),
          const SizedBox(width: 8),
          _buildFilterChip('Fastest', true),
          const SizedBox(width: 8),
          _buildFilterChip('Carrier', false),
          const SizedBox(width: 8),
          _buildFilterChip('Direct', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.white : AppColors.onSurfaceVariant,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildRouteCard(
    BuildContext context, {
    required String departure,
    required String arrival,
    required String price,
    required String duration,
    required String type,
    bool isFastest = false,
    bool isMonad = true,
  }) {
    final Color brandColor = isMonad ? AppColors.primary : AppColors.secondary;

    return KineticCard(
      hasAmbientShadow: isFastest,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFastest)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'FASTEST ROUTE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeNode(departure, 'LHR'),
              Column(
                children: [
                  Text(
                    duration,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 60,
                    height: 1,
                    color: AppColors.outlineVariant,
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    type == 'FLIGHT'
                        ? Icons.airplanemode_active
                        : Icons.directions_bus,
                    size: 14,
                    color: AppColors.onSurfaceVariant,
                  ),
                ],
              ),
              _buildTimeNode(arrival, 'CDG'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PRICE',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '$price MONAD',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: brandColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: const Text('SELECT'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeNode(String time, String station) {
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          station,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
