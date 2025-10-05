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

  // Funkcja do wyszukiwania autouzupełniania stacji
static Future<List<String>> searchAutocomplete(String query) async {
    if (query.isEmpty || query.length < 2) {
      return [];
    }
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search_autocomplete?query=${Uri.encodeComponent(query)}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('Search autocomplete response status: ${response.statusCode}');
      debugPrint('Search autocomplete response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        List<String> suggestions = [];
        
        if (data is List) {
          // Przekształć każdy element na string, niezależnie od typu
          for (var item in data) {
            if (item is String) {
              suggestions.add(item);
            } else if (item is Map<String, dynamic>) {
              // Jeśli to obiekt, spróbuj wyciągnąć nazwę stacji
              if (item['stop_name'] != null) {
                suggestions.add(item['stop_name'].toString());
              } else if (item['name'] != null) {
                suggestions.add(item['name'].toString());
              } else if (item['station'] != null) {
                suggestions.add(item['station'].toString());
              } else if (item['title'] != null) {
                suggestions.add(item['title'].toString());
              } else {
                // Fallback - użyj pierwszej wartości string w obiekcie
                for (var value in item.values) {
                  if (value is String && value.isNotEmpty) {
                    suggestions.add(value);
                    break;
                  }
                }
              }
            } else {
              // Przekształć na string
              suggestions.add(item.toString());
            }
          }
        } else if (data is Map) {
          // Spróbuj różnych kluczy
          List<dynamic>? items;
          if (data['results'] != null) {
            items = data['results'] as List?;
          } else if (data['data'] != null) {
            items = data['data'] as List?;
          } else if (data['suggestions'] != null) {
            items = data['suggestions'] as List?;
          } else if (data['items'] != null) {
            items = data['items'] as List?;
          }
          
          if (items != null) {
            for (var item in items) {
              if (item is String) {
                suggestions.add(item);
              } else if (item is Map<String, dynamic>) {
                // Jeśli to obiekt, spróbuj wyciągnąć nazwę stacji
                if (item['stop_name'] != null) {
                  suggestions.add(item['stop_name'].toString());
                } else if (item['name'] != null) {
                  suggestions.add(item['name'].toString());
                } else if (item['station'] != null) {
                  suggestions.add(item['station'].toString());
                } else if (item['title'] != null) {
                  suggestions.add(item['title'].toString());
                } else {
                  // Fallback - użyj pierwszej wartości string w obiekcie
                  for (var value in item.values) {
                    if (value is String && value.isNotEmpty) {
                      suggestions.add(value);
                      break;
                    }
                  }
                }
              } else {
                // Przekształć na string
                suggestions.add(item.toString());
              }
            }
          }
        }
        
        return suggestions;
      } else {
        debugPrint('Search autocomplete error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Search autocomplete exception: $e');
      return [];
    }
  }

  // Funkcja do wyszukiwania połączeń kolejowych
  static Future<Map<String, dynamic>?> searchJourneys({
    required String from,
    required String to,
    required String datetime,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/search').replace(queryParameters: {
        'from': from,
        'to': to,
        'datetime': datetime,
      });

      debugPrint('Searching journeys: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint('Journey search response status: ${response.statusCode}');
      debugPrint('Journey search response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Sprawdź czy odpowiedź zawiera jakiekolwiek wyniki
        bool hasResults = false;
        if (data != null) {
          if (data['results'] is List && (data['results'] as List).isNotEmpty) {
            hasResults = true;
          } else if (data['data'] is List && (data['data'] as List).isNotEmpty) {
            hasResults = true;
          } else if (data['journeys'] is List && (data['journeys'] as List).isNotEmpty) {
            hasResults = true;
          } else if (data is List && data.isNotEmpty) {
            hasResults = true;
          }
        }
        
        // Dodaj informację o tym czy znaleziono wyniki
        if (data is Map<String, dynamic>) {
          data['hasResults'] = hasResults;
        }
        
        return data;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          return {
            'error': 'Błąd wyszukiwania',
            'message': errorData['message'] ?? 'Nie udało się znaleźć połączeń'
          };
        } catch (e) {
          return {
            'error': 'Błąd wyszukiwania',
            'message': 'Kod błędu: ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      debugPrint('Journey search exception: $e');
      return {
        'error': 'Błąd połączenia',
        'message': 'Sprawdź połączenie z internetem: $e'
      };
    }
  }

  // Funkcja testowa do sprawdzenia połączenia z API
  static Future<Map<String, dynamic>?> testConnection() async {
    try {
      // Testuj endpoint search z przykładowymi danymi
      final response = await http.get(
        Uri.parse('$baseUrl/search?from=test&to=test&datetime=2025-01-01T12:00'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      // Sprawdź czy odpowiedź ma sens (status 200 lub błąd walidacji, ale nie błąd sieci)
      if (response.statusCode == 200 || response.statusCode == 400 || response.statusCode == 422) {
        return {
          'status': response.statusCode,
          'connected': true,
          'message': 'API dostępne'
        };
      } else {
        return {
          'status': response.statusCode,
          'connected': false,
          'message': 'API niedostępne (${response.statusCode})'
        };
      }
    } catch (e) {
      return {
        'status': 0,
        'connected': false,
        'message': 'Brak połączenia z API: $e'
      };
    }
  }
}
