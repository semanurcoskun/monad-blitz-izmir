import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/marketplace_provider.dart';
import '../providers/wallet_provider.dart';
import 'ticket_detail_screen.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  @override
  void initState() {
    super.initState();
    _refreshListings();
  }

  Future<void> _refreshListings() async {
    final provider = context.read<MarketplaceProvider>();
    await provider.loadListings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshListings,
        child: Consumer<MarketplaceProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.listings.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366f1)),
                ),
              );
            }

            if (provider.error != null && provider.listings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Hata',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      provider.error ?? 'Bilinmeyen hata',
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _refreshListings,
                      icon: Icon(Icons.refresh),
                      label: Text('Tekrar Dene'),
                    ),
                  ],
                ),
              );
            }

            if (provider.listings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox_outlined, size: 64, color: Color(0xFF64748b)),
                    SizedBox(height: 16),
                    Text('Henüz bilet bulunmuyor'),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: provider.listings.length + (provider.isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == provider.listings.length) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6366f1)),
                      ),
                    ),
                  );
                }

                final ticket = provider.listings[index];
                return TicketListCard(
                  transaction: ticket,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TicketDetailScreen(
                          transaction: ticket,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class TicketListCard extends StatelessWidget {
  final ticket;
  final VoidCallback onTap;

  const TicketListCard({
    required this.transaction,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: Color(0xFF1e293b),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Color(0xFF475569)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NFT Bilet #${transaction.tokenId}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '✨ ERC-721 NFT',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF6366f1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF10b981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${transaction.price} MON',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10b981),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Divider(color: Color(0xFF475569)),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfo('Satıcı', transaction.seller.substring(0, 10) + '...'),
                  _buildInfo('Tarih', 'İşlemde'),
                ],
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6366f1),
                  ),
                  child: Text('Detayları Gör'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Color(0xFF94a3b8)),
        ),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ],
    );
  }
}
