import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Search for routes by source and destination
  Future<List<Map<String, dynamic>>> searchRoutes({
    required String source,
    required String destination,
    String? airline,
    String? date,
  }) async {
    try {
      // Normalizing to Title Case for Firestore matching (e.g. "mumbai" -> "Mumbai")
      final normalizedSource = _toTitleCase(source.trim());
      final normalizedDestination = _toTitleCase(destination.trim());

      debugPrint('FirebaseService: Searching routes FROM: [$normalizedSource] TO: [$normalizedDestination] ON: [$date]');
      
      // Simple query to avoid composite index requirements
      Query query = _firestore.collection('routes')
          .where('Source', isEqualTo: normalizedSource)
          .where('Destination', isEqualTo: normalizedDestination);

      final querySnapshot = await query.get();
      
      debugPrint('FirebaseService: Raw DB results found: ${querySnapshot.docs.length}');

      List<Map<String, dynamic>> results = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // In-memory filtering for more reliability
      if (date != null && date.isNotEmpty) {
        results = results.where((route) {
          final routeDate = route['Date_of_journey']?.toString() ?? '';
          return routeDate == date;
        }).toList();
        debugPrint('FirebaseService: After date filtering ($date): ${results.length}');
      }

      if (airline != null && airline.isNotEmpty) {
        results = results.where((route) {
          final routeAirline = route['Airline']?.toString() ?? '';
          return routeAirline == airline;
        }).toList();
        debugPrint('FirebaseService: After airline filtering ($airline): ${results.length}');
      }
      
      return results;
    } catch (e) {
      debugPrint('FirebaseService: CRITICAL SEARCH ERROR: $e');
      return [];
    }
  }

  String _toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  /// Save or update user profile using wallet address as document ID
  Future<void> saveUserProfile(String walletAddress, Map<String, dynamic> profileData) async {
    try {
      debugPrint('FirebaseService: Saving user profile for $walletAddress');
      await _firestore.collection('users').doc(walletAddress).set(
        profileData,
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('FirebaseService: Save profile error: $e');
    }
  }

  /// Save ticket purchase to user's history
  Future<void> saveTicketToUserHistory(String walletAddress, Map<String, dynamic> ticketData) async {
    try {
      debugPrint('FirebaseService: Saving ticket for $walletAddress');
      await _firestore.collection('users').doc(walletAddress).collection('tickets').add({
        ...ticketData,
        'purchaseDate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('FirebaseService: Save ticket error: $e');
    }
  }

  /// Get current user profile from Firestore
  Future<Map<String, dynamic>?> getUserProfile(String walletAddress) async {
    try {
      final doc = await _firestore.collection('users').doc(walletAddress).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('FirebaseService: Get profile error: $e');
      return null;
    }
  }

  /// Get all tickets for a user
  Future<List<Map<String, dynamic>>> getUserTickets(String walletAddress) async {
    try {
      debugPrint('FirebaseService: Fetching tickets for $walletAddress');
      final querySnapshot = await _firestore
          .collection('users')
          .doc(walletAddress)
          .collection('tickets')
          .orderBy('purchaseDate', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('FirebaseService: Get tickets error: $e');
      return [];
    }
  }
}
