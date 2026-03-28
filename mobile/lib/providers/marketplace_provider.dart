import 'package:flutter/material.dart';
import '../models/ticket_model.dart';
import '../models/transaction_model.dart';
import '../services/api_service.dart';

class MarketplaceProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Transaction> _listings = [];
  List<Ticket> _userTickets = [];
  List<Transaction> _purchaseHistory = [];

  bool _isLoading = false;
  String? _error;

  List<Transaction> get listings => _listings;
  List<Ticket> get userTickets => _userTickets;
  List<Transaction> get purchaseHistory => _purchaseHistory;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadListings() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _listings = await _apiService.getMarketplaceTransactions();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUserTickets(String address) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _userTickets = await _apiService.getUserTickets(address);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadPurchaseHistory() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _purchaseHistory = await _apiService.getPurchaseHistory();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> buyTicket({
    required String buyerAddress,
    required String tokenId,
    required String amount,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final result = await _apiService.buyTicket(
        buyerAddress: buyerAddress,
        tokenId: tokenId,
        amount: amount,
      );

      _error = null;
      await loadListings();
      await loadUserTickets(buyerAddress);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> useTicket(String tokenId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _apiService.useTicket(tokenId);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
