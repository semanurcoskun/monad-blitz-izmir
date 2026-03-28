import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'providers/wallet_provider.dart';
import 'providers/marketplace_provider.dart';

void main() {
  runApp(const MonadTicketApp());
}

class MonadTicketApp extends StatelessWidget {
  const MonadTicketApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => MarketplaceProvider()),
      ],
      child: MaterialApp(
        title: 'Monad Ticket',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: const Color(0xFF0f172a),
          textTheme: GoogleFonts.interTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme,
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: const Color(0xFF1e293b),
            elevation: 0,
            centerTitle: true,
            titleTextStyle: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366f1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
