import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'features/wallet/presentation/pages/connect_wallet_page.dart';
import 'features/navigation/presentation/pages/main_navigation_page.dart';
import 'features/routes/presentation/pages/route_results_page.dart';
import 'features/checkout/presentation/pages/checkout_page.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ProviderScope(child: KineticTravelApp()));
}

class KineticTravelApp extends StatelessWidget {
  const KineticTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Kinetic Ledger',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/connect',
      routes: {
        '/connect': (context) => const ConnectWalletPage(),
        '/': (context) => const MainNavigationPage(),
        '/routes': (context) => const RouteResultsPage(),
        '/checkout': (context) => const CheckoutPage(),
      },
    );
  }
}
