import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/navigation/presentation/pages/main_navigation_page.dart';
import 'features/routes/presentation/pages/route_results_page.dart';
import 'features/checkout/presentation/pages/checkout_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: KineticTravelApp(),
    ),
  );
}

class KineticTravelApp extends StatelessWidget {
  const KineticTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Kinetic Ledger',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const MainNavigationPage(),
        '/routes': (context) => const RouteResultsPage(),
        '/checkout': (context) => const CheckoutPage(),
      },
    );
  }
}
