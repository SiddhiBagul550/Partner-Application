import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();
  factory LoggerService() => _instance;
  LoggerService._internal();

  // Web fallback: If the app is hosted together, we can use a relative or absolute URL.
  // We assume the Next.js frontend handles this API route.
  static const String _logApiUrl = 'http://localhost:3000/api/log'; 

  Future<void> logEvent(String type, String message, {Map<String, dynamic>? metadata}) async {
    try {
      await http.post(
        Uri.parse(_logApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'type': type,
          'message': message,
          'metadata': metadata,
        }),
      );
      debugPrint('[LOGGER] $type: $message');
    } catch (e) {
      debugPrint('[LOGGER ERR] Failed to write log: $e');
    }
  }

  Future<void> logAuthFailure(String email, String reason) async {
    await logEvent('AUTH_FAILURE', 'App login failed for $email: $reason', metadata: {'email': email, 'reason': reason});
  }
}

