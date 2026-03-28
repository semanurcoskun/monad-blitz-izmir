import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_flutter_projesi/core/theme/app_colors.dart';
import 'package:yeni_flutter_projesi/core/widgets/kinetic_card.dart';
import 'package:yeni_flutter_projesi/core/services/firebase_service.dart';
import 'package:yeni_flutter_projesi/features/wallet/presentation/providers/wallet_provider.dart';

class RouteResultsPage extends ConsumerWidget {
  final String from;
  final String to;
  final List<Map<String, dynamic>> routes;

  const RouteResultsPage({
    super.key,
    required this.from,
    required this.to,
    required this.routes,
  });

  Future<void> _purchaseTicket(BuildContext context, WidgetRef ref, Map<String, dynamic> route) async {
    final walletState = ref.read(walletProvider);
    
    if (!walletState.isConnected || walletState.address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect your wallet first!')),
      );
      return;
    }

    final String walletAddress = walletState.address!;
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final ticketData = {
        'from': from,
        'to': to,
        'airline': route['Airline'],
        'flightCode': route['Flight_code'],
        'departure': route['Departure'],
        'arrival': route['Arrival'],
        'fare': route['Fare'],
        'duration': route['Duration_in_hours'],
        'status': 'VERIFIED',
        'type': 'FLIGHT',
        'seat': '12A', // Mock seat
      };

      await FirebaseService().saveTicketToUserHistory(walletAddress, ticketData);
      
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket purchased successfully! Check your Inventory.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$from -> $to'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: routes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: AppColors.onSurfaceVariant),
                        SizedBox(height: 16),
                        Text('No routes found for this selection.'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: routes.length,
                    itemBuilder: (context, index) {
                      final route = routes[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: _buildRouteCard(
                          context,
                          ref: ref,
                          route: route,
                          airline: route['Airline'] ?? 'Unknown',
                          flightCode: route['Flight_code'] ?? '',
                          departure: route['Departure'] ?? '--:--',
                          arrival: route['Arrival'] ?? '--:--',
                          price: (route['Fare'] ?? 0.0).toStringAsFixed(2),
                          duration: '${route['Duration_in_hours'] ?? '?'}h',
                          type: 'FLIGHT',
                          isFastest: index == 0,
                          isMonad: true,
                        ),
                      );
                    },
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
    required WidgetRef ref,
    required Map<String, dynamic> route,
    required String airline,
    required String flightCode,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    airline.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    flightCode,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (isFastest)
                Container(
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
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeNode(departure, from),
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
              _buildTimeNode(arrival, to),
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
                    '\$$price MON',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _purchaseTicket(context, ref, route),
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
