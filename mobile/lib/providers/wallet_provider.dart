import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletProvider extends ChangeNotifier {
  String? _address;
  bool _isConnected = false;
  String? _error;

  String? get address => _address;
  bool get isConnected => _isConnected;
  String? get error => _error;

  WalletProvider() {
    _loadSavedWallet();
  }

  Future<void> _loadSavedWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _address = prefs.getString('wallet_address');
      _isConnected = _address != null;
      notifyListeners();
    } catch (e) {
      _error = 'Cüzdan yüklenemedi: $e';
      notifyListeners();
    }
  }

  // Simulated wallet connection - in real app, use WalletConnect or MetaMask
  Future<void> connectWallet(String address) async {
    try {
      // Validate address format
      if (!address.startsWith('0x') || address.length != 42) {
        throw Exception('Geçersiz cüzdan adresi');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('wallet_address', address);

      _address = address;
      _isConnected = true;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Bağlantı hatası: $e';
      notifyListeners();
    }
  }

  Future<void> disconnectWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('wallet_address');

      _address = null;
      _isConnected = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Çıkış hatası: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
