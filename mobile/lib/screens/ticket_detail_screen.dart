import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/marketplace_provider.dart';
import '../providers/wallet_provider.dart';

class TicketDetailScreen extends StatefulWidget {
  final transaction;

  const TicketDetailScreen({
    required this.transaction,
    Key? key,
  }) : super(key: key);

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final marketplaceProvider = context.watch<MarketplaceProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Bilet Detayları'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NFT Badge
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6366f1), Color(0xFF4f46e5)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    '✨',
                    style: TextStyle(fontSize: 48),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'NFT Bilet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ERC-721 Token #${widget.transaction.tokenId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFfc7d2fe),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Price Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF475569)),
              ),
              child: Column(
                children: [
                  Text(
                    'Fiyat',
                    style: TextStyle(color: Color(0xFF94a3b8), fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${widget.transaction.price} MON',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10b981),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Platform Ücreti: %5 (${(double.parse(widget.transaction.price) * 0.05).toStringAsFixed(2)} MON)',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748b)),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Satıcı Alacağı: ${(double.parse(widget.transaction.price) * 0.95).toStringAsFixed(2)} MON',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748b)),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Details Section
            _buildDetailSection('İşlem Bilgileri', [
              _buildDetailRow('Token ID', widget.transaction.tokenId),
              _buildDetailRow(
                'Satıcı',
                widget.transaction.seller.substring(0, 6) +
                    '...' +
                    widget.transaction.seller.substring(
                      widget.transaction.seller.length - 4,
                    ),
              ),
            ]),
            SizedBox(height: 16),
            // NFT Info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF1e3a8a).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Color(0xFF3b82f6), width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🔐 Blockchain Güvenliği',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Bu bilet ERC-721 NFT olarak Monad blockchain\'de kalıcı olarak kaydedilmiştir. Transferini yapabilir, pazarda satabilir veya etkinliğe giriş için kullanabilirsin.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFf93c5fd),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            // Buy Button
            if (walletProvider.isConnected && !marketplaceProvider.isLoading)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _showPurchaseDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF10b981),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart),
                      SizedBox(width: 8),
                      Text(
                        '${widget.transaction.price} MON ile Satın Al',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (marketplaceProvider.isLoading)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF64748b),
                  ),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseDialog(BuildContext context) {
    final walletProvider = context.read<WalletProvider>();
    final marketplaceProvider = context.read<MarketplaceProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Satın Al'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bu NFT biletini satın almak istediğinize emin misiniz?'),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF1e293b),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bilet #${widget.transaction.tokenId}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${widget.transaction.price} MON',
                    style: TextStyle(color: Color(0xFF10b981)),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _purchaseTicket(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF10b981),
            ),
            child: Text('Satın Al'),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseTicket(BuildContext context) async {
    final walletProvider = context.read<WalletProvider>();
    final marketplaceProvider = context.read<MarketplaceProvider>();

    final success = await marketplaceProvider.buyTicket(
      buyerAddress: walletProvider.address!,
      tokenId: widget.transaction.tokenId,
      amount: widget.transaction.price,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 8),
              Expanded(child: Text('İşlem başarılı! Bilet cüzdanına eklendi.')),
            ],
          ),
          backgroundColor: Color(0xFF065f46),
        ),
      );
      Future.delayed(Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(marketplaceProvider.error ?? 'Satın alma başarısız'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildDetailSection(
    String title,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF1e293b),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Color(0xFF475569)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Color(0xFF94a3b8)),
          ),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
