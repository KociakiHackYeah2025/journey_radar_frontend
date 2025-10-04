import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'https://kociaki-api.intuizm.com';
  
  static SharedPreferences? _prefs;
  
  // Fallback storage w pamięci
  static String? _memoryToken;
  static String? _memoryTokenType;
  
  static Future<SharedPreferences?> _getPrefs() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs!;
    } catch (e) {
      debugPrint('SharedPreferences error: $e');
      return null;
    }
  }
  
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      debugPrint('Attempting login for: $email');
      
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // API zwraca access_token, nie token
        if (data['access_token'] != null) {
          try {
            final prefs = await _getPrefs();
            if (prefs != null) {
              await prefs.setString('auth_token', data['access_token']);
              await prefs.setString('token_type', data['token_type'] ?? 'bearer');
              debugPrint('Token saved to SharedPreferences');
            } else {
              // Fallback do pamięci
              _memoryToken = data['access_token'];
              _memoryTokenType = data['token_type'] ?? 'bearer';
              debugPrint('Token saved to memory (SharedPreferences failed)');
            }
          } catch (e) {
            debugPrint('Error saving token: $e');
            // Fallback do pamięci
            _memoryToken = data['access_token'];
            _memoryTokenType = data['token_type'] ?? 'bearer';
          }
        }
        
        return data;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'error': 'Błąd logowania',
            'message': errorData['message'] ?? 'Nieprawidłowy email lub hasło'
          };
        } catch (e) {
          return {
            'error': 'Błąd logowania',
            'message': 'Kod błędu: ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      debugPrint('Login exception: $e');
      return {
        'error': 'Błąd połączenia',
        'message': 'Sprawdź połączenie z internetem: $e'
      };
    }
  }

  static Future<Map<String, dynamic>?> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'error': 'Błąd rejestracji',
            'message': errorData['message'] ?? 'Nie udało się utworzyć konta'
          };
        } catch (e) {
          return {
            'error': 'Błąd rejestracji',
            'message': 'Kod błędu: ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      return {
        'error': 'Błąd połączenia',
        'message': 'Sprawdź połączenie z internetem: $e'
      };
    }
  }

  static Future<void> logout() async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        await prefs.remove('auth_token');
        await prefs.remove('token_type');
      }
      // Wyczyść też pamięć
      _memoryToken = null;
      _memoryTokenType = null;
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Wyczyść pamięć mimo błędu
      _memoryToken = null;
      _memoryTokenType = null;
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await _getPrefs();
      if (prefs != null) {
        return prefs.getString('auth_token');
      } else {
        // Fallback do pamięci
        return _memoryToken;
      }
    } catch (e) {
      debugPrint('Error getting token: $e');
      return _memoryToken; // Fallback do pamięci
    }
  }

  static Future<String?> getAuthHeader() async {
    try {
      final prefs = await _getPrefs();
      String? token;
      String tokenType = 'bearer';
      
      if (prefs != null) {
        token = prefs.getString('auth_token');
        tokenType = prefs.getString('token_type') ?? 'bearer';
      } else {
        // Fallback do pamięci
        token = _memoryToken;
        tokenType = _memoryTokenType ?? 'bearer';
      }
      
      if (token != null && token.isNotEmpty) {
        return '${tokenType.toLowerCase()} $token';
      }
    } catch (e) {
      debugPrint('Error getting auth header: $e');
      // Fallback do pamięci
      if (_memoryToken != null && _memoryToken!.isNotEmpty) {
        final tokenType = _memoryTokenType ?? 'bearer';
        return '${tokenType.toLowerCase()} $_memoryToken';
      }
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      debugPrint('Error checking login status: $e');
      return false;
    }
  }

  // Funkcja testowa do sprawdzenia połączenia z API
  static Future<Map<String, dynamic>?> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      return {
        'status': response.statusCode,
        'connected': true,
        'message': 'API dostępne'
      };
    } catch (e) {
      return {
        'status': 0,
        'connected': false,
        'message': 'Brak połączenia z API: $e'
      };
    }
  }
}