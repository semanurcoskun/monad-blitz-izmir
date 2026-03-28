import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/ticket_model.dart';
import '../models/transaction_model.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android emulator localhost

  // Marketplace
  Future<List<Transaction>> getMarketplaceTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/marketplace/transactions'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<Transaction> transactions = (json['transactions'] as List)
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
        return transactions;
      } else {
        throw Exception('Marketplace yüklenemedi');
      }
    } catch (e) {
      throw Exception('Ağ hatası: $e');
    }
  }

  Future<Map<String, dynamic>> getListing(String tokenId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/marketplace/listing/$tokenId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return json['listing'] ?? {};
      } else {
        throw Exception('Bilet bulunamadı');
      }
    } catch (e) {
      throw Exception('Ağ hatası: $e');
    }
  }

  // Purchases
  Future<Map<String, dynamic>> buyTicket({
    required String buyerAddress,
    required String tokenId,
    required String amount,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/purchases/from-marketplace'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'buyerAddress': buyerAddress,
          'tokenId': tokenId,
          'amount': amount,
        }),
      ).timeout(const Duration(seconds: 30));

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['success'] == true) {
        return json;
      } else {
        throw Exception(json['error'] ?? 'Satın alma başarısız');
      }
    } catch (e) {
      throw Exception('Satın alma hatası: $e');
    }
  }

  Future<List<Transaction>> getPurchaseHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/purchases/history'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<Transaction> transactions = (json['purchases'] as List)
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
        return transactions;
      } else {
        throw Exception('Geçmiş yüklenemedi');
      }
    } catch (e) {
      throw Exception('Ağ hatası: $e');
    }
  }

  Future<List<Transaction>> getUserPurchases(String address) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/purchases/user/$address'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<Transaction> transactions = (json['purchases'] as List)
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
        return transactions;
      } else {
        throw Exception('Satın almalar yüklenemedi');
      }
    } catch (e) {
      throw Exception('Ağ hatası: $e');
    }
  }

  // Tickets
  Future<List<Ticket>> getUserTickets(String address) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets/user/$address'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List<Ticket> tickets = (json['tickets'] as List)
            .map((e) => Ticket.fromJson(e as Map<String, dynamic>))
            .toList();
        return tickets;
      } else {
        throw Exception('Biletler yüklenemedi');
      }
    } catch (e) {
      throw Exception('Ağ hatası: $e');
    }
  }

  Future<Ticket> getTicket(String tokenId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/tickets/$tokenId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Ticket.fromJson(json['ticket']);
      } else {
        throw Exception('Bilet bulunamadı');
      }
    } catch (e) {
      throw Exception('Ağ hatası: $e');
    }
  }

  Future<Map<String, dynamic>> useTicket(String tokenId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/tickets/$tokenId/use'),
      ).timeout(const Duration(seconds: 10));

      final json = jsonDecode(response.body);

      if (response.statusCode == 200 && json['success'] == true) {
        return json;
      } else {
        throw Exception('Bilet kullanılamadı');
      }
    } catch (e) {
      throw Exception('Bilet kullanma hatası: $e');
    }
  }

  // Health check
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/health'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
