import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member_model.dart';
import '../models/history_model.dart';

/// [ApiService] manages all outgoing network requests to the backend server.
///
/// It implements a centralized approach for:
/// 1. Base URL management via environment variables.
/// 2. Automatic Authorization header injection.
/// 3. Standardized error handling and data parsing.
class ApiService {
  /// Dynamically retrieves the Base URL from the .env configuration.
  ///
  /// Throws an [Exception] if API_URL is missing to prevent silent
  /// failures in downstream network calls (Fail-Fast Principle).
  String get baseUrl {
    final url = dotenv.env['API_URL'];

    if (url == null || url.isEmpty) {
      throw Exception('CRITICAL: API_URL not found in .env configuration');
    }

    return url;
  }

  /// Generates the standard HTTP headers required for authorized requests.
  ///
  /// Fetches the JWT 'access_token' from local storage and injects it
  /// into the Authorization header using the Bearer scheme.
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ===========================================================================
  // 👤 MEMBER PROFILE SERVICES
  // ===========================================================================

  /// Retrieves the authenticated member's point profile.
  ///
  /// Returns [MemberModel] on success, or [null] if the request fails
  /// or the user is unauthorized.
  Future<MemberModel?> fetchMemberProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/members/me/points'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        return MemberModel.fromJson(jsonDecode(response.body));
      } else {
        debugPrint('PROFILE_FETCH_ERROR: Status Code ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('PROFILE_FETCH_EXCEPTION: $e');
      return null;
    }
  }

  // ===========================================================================
  // 📝 TRANSACTION HISTORY SERVICES
  // ===========================================================================

  /// Fetches transaction history for a specific member.
  ///
  /// [memberId] is required to target the correct history set.
  /// Performs data flattening (flatMap) to extract nested point history records
  /// and sorts them by date in descending order (Newest first).
  Future<List<HistoryModel>> fetchHistory(String memberId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/history/$memberId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final rawData = jsonDecode(response.body);

        // Handle cases where the API explicitly returns a message instead of data.
        if (rawData is Map && rawData.containsKey('message')) {
          return [];
        }

        List<HistoryModel> histories = [];

        // Data Transformation: Flatten the list if point_histories are nested within transactions.
        if (rawData is List) {
          for (var tx in rawData) {
            // Check for nested histories (similar to React flatMap logic).
            if (tx['point_histories'] != null &&
                tx['point_histories'] is List) {
              for (var ph in tx['point_histories']) {
                histories.add(HistoryModel.fromJson(ph));
              }
            } else {
              // Fallback for flat data structures.
              histories.add(HistoryModel.fromJson(tx));
            }
          }
        }

        // Sorting: Ensure UI displays the most recent activities at the top.
        histories.sort((a, b) => b.createdAt.compareTo(a.createdAt));

        return histories;
      } else {
        debugPrint('HISTORY_FETCH_ERROR: Status Code ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('HISTORY_FETCH_EXCEPTION: $e');
      return [];
    }
  }
}
