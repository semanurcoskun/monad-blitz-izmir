import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_flutter_projesi/core/services/firebase_service.dart';
import 'package:yeni_flutter_projesi/features/wallet/presentation/providers/wallet_provider.dart';

/// Provider that fetches all tickets for the currently connected wallet
final userTicketsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final walletState = ref.watch(walletProvider);
  
  if (!walletState.isConnected || walletState.address == null) {
    return [];
  }
  
  return await FirebaseService().getUserTickets(walletState.address!);
});
