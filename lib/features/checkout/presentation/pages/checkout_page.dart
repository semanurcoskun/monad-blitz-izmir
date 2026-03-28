import 'package:flutter/material.dart';
import 'package:yeni_flutter_projesi/core/theme/app_colors.dart';
import 'package:yeni_flutter_projesi/core/widgets/kinetic_card.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  int? selectedSeatIndex = 5; // Default selected seat for demo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Seat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSeatMap(),
            const SizedBox(height: 32),
            _buildLegend(),
            const SizedBox(height: 40),
            _buildOrderSummary(context),
            const SizedBox(height: 40),
            _buildMintButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSeatMap() {
    return Column(
      children: [
        const Text('FRONT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: 20,
          itemBuilder: (context, index) {
            final isOccupied = index % 7 == 0;
            final isSelected = selectedSeatIndex == index;
            
            return GestureDetector(
              onTap: isOccupied ? null : () => setState(() => selectedSeatIndex = index),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : (isOccupied ? AppColors.surfaceContainerHigh : AppColors.surfaceContainerLow),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}${['A', 'B', 'C', 'D'][index % 4]}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildLegendItem('Available', AppColors.surfaceContainerLow),
        _buildLegendItem('Occupied', AppColors.surfaceContainerHigh),
        _buildLegendItem('Selected', AppColors.primary),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildOrderSummary(BuildContext context) {
    return KineticCard(
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('ORDER SUMMARY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 16),
          _buildSummaryRow('Seat Price', '240.50 MON'),
          _buildSummaryRow('Service Fee', '1.00 MON'),
          _buildSummaryRow('Gas Estimate', '0.002 MON'),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TOTAL TO PAY', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(
                '241.502 MON',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary, fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMintButton(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 20),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 18),
                SizedBox(width: 12),
                Text('MINT NFT TICKET'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'IMMUTABLE VERIFICATION SECURED BY MONAD',
          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.onSurfaceVariant),
        ),
      ],
    );
  }
}
