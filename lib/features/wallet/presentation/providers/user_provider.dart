import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yeni_flutter_projesi/core/services/firebase_service.dart';
import 'package:yeni_flutter_projesi/features/wallet/presentation/providers/wallet_provider.dart';

final userProfileProvider = AsyncNotifierProvider<UserProfileNotifier, Map<String, dynamic>?>(() {
  return UserProfileNotifier();
});

class UserProfileNotifier extends AsyncNotifier<Map<String, dynamic>?> {
  FirebaseService get _firebaseService => FirebaseService();

  @override
  Future<Map<String, dynamic>?> build() async {
    final walletState = ref.watch(walletProvider);
    
    if (walletState.isConnected && walletState.address != null) {
      final profile = await _firebaseService.getUserProfile(walletState.address!);
      if (profile == null) {
        return await createInitialProfile(walletState.address!);
      }
      return profile;
    }
    return null;
  }

  Future<Map<String, dynamic>> createInitialProfile(String address) async {
    final initialData = {
      'walletAddress': address,
      'createdAt': DateTime.now().toIso8601String(),
      'displayName': 'Monad Traveler',
      'isVerified': false,
    };

    await _firebaseService.saveUserProfile(address, initialData);
    return initialData;
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final walletState = ref.read(walletProvider);
    if (!walletState.isConnected || walletState.address == null) return;

    state = const AsyncValue.loading();
    try {
      await _firebaseService.saveUserProfile(walletState.address!, updates);
      final currentData = state.value ?? {};
      state = AsyncValue.data({...currentData, ...updates});
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
