import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import 'home_screen.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  void _connectWallet() async {
    final address = _addressController.text.trim();

    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lütfen cüzdan adresini girin')),
      );
      return;
    }

    final walletProvider = context.read<WalletProvider>();
    await walletProvider.connectWallet(address);

    if (walletProvider.isConnected) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(walletProvider.error ?? 'Bağlantı başarısız')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0f172a),
              Color(0xFF1e293b),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  SizedBox(height: 40),
                  // Logo
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366f1), Color(0xFF4f46e5)],
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '💰',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Cüzdanı Bağla',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Monad Testnet\'te bilet satın almaya başla',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFfa0aec0),
                    ),
                  ),
                  SizedBox(height: 40),
                  // Info Box
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFF1e293b),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Color(0xFF475569)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '📋 Gereksinimler:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildRequirement('Monad Testnet Cüzdanı'),
                        _buildRequirement('Geçerli Cüzdan Adresi (0x...)'),
                        _buildRequirement('Yeterli MON Token\'ı'),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  // Address Input
                  TextField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      hintText: '0x...',
                      hintStyle: TextStyle(color: Color(0xFF64748b)),
                      labelText: 'Cüzdan Adresi',
                      labelStyle: TextStyle(color: Color(0xFF94a3b8)),
                      prefixIcon: Icon(Icons.wallet_outlined, color: Color(0xFF6366f1)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF475569)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF475569)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Color(0xFF6366f1), width: 2),
                      ),
                      filled: true,
                      fillColor: Color(0xFF1e293b),
                    ),
                    style: TextStyle(color: Colors.white),
                    maxLines: 1,
                  ),
                  SizedBox(height: 24),
                  // Connect Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _connectWallet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF6366f1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.link, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Cüzdanı Bağla',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Help Text
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF1e3a8a).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '💡 Cüzdan adresini MetaMask veya diğer Web3 cüzdanından kopyalayabilirsin',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFf93c5fd),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Color(0xFF10b981), size: 20),
          SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: Color(0xFfc7d2fe), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
