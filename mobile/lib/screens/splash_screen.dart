import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import 'home_screen.dart';
import 'wallet_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkWallet();
  }

  Future<void> _checkWallet() async {
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    final walletProvider = context.read<WalletProvider>();
    if (walletProvider.isConnected) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/wallet');
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
              Color(0xFF1e1b4b),
              Color(0xFF312e81),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366f1), Color(0xFF4f46e5)],
                  ),
                ),
                child: Center(
                  child: Text(
                    '🎫',
                    style: TextStyle(fontSize: 50),
                  ),
                ),
              ),
              SizedBox(height: 24),
              // Title
              Text(
                'Monad Ticket',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              // Subtitle
              Text(
                'Decentralized Ticketing',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFfc7d2fe),
                ),
              ),
              SizedBox(height: 50),
              // Loading Indicator
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF6366f1),
                  ),
                  strokeWidth: 3,
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Yükleniyor...',
                style: TextStyle(
                  color: Color(0xFfc7d2fe),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
