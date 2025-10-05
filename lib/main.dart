import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'widgets/app_background.dart';
import 'widgets/glass_card.dart';
import 'widgets/custom_button.dart';
import 'widgets/journey_search_widget.dart';
import 'services/api_service.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/train_search_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicjalizacja SharedPreferences
  try {
    await SharedPreferences.getInstance();
  } catch (e) {
    debugPrint('SharedPreferences initialization error: $e');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journey Radar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isSidebarOpen = false;
  bool isLoggedIn = false;
  bool isCheckingLoginStatus = true;
  bool isApiConnected = false;
  String apiConnectionMessage = 'Sprawdzanie połączenia...';

  // Zmienne dla wyników wyszukiwania
  List<Map<String, dynamic>> searchResults = [];
  bool isSearching = false;
  bool hasSearched = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _testApiConnection();
  }

  Future<void> _checkLoginStatus() async {
    try {
      final loggedIn = await ApiService.isLoggedIn();
      if (mounted) {
        setState(() {
          isLoggedIn = loggedIn;
          isCheckingLoginStatus = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoggedIn = false;
          isCheckingLoginStatus = false;
        });
      }
    }
  }

  Future<void> _testApiConnection() async {
    try {
      final result = await ApiService.testConnection();
      if (mounted) {
        setState(() {
          isApiConnected = result?['connected'] ?? false;
          apiConnectionMessage = result?['message'] ?? 'Błąd połączenia';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isApiConnected = false;
          apiConnectionMessage = 'Błąd połączenia z API';
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await ApiService.logout();
      if (mounted) {
        setState(() {
          isLoggedIn = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zostałeś wylogowany'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Błąd podczas wylogowywania'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Add controllers for the search widget
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  Future<void> _performJourneySearch() async {
    if (_fromController.text.isEmpty || _toController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Proszę wypełnić zarówno miejsce wyjazdu jak i miejsce przeznaczenia',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_dateController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proszę wybrać datę i godzinę podróży'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!isApiConnected) {
      // NAWET bez API - pokaż mockowe wyniki
      setState(() {
        isSearching = true;
      });

      // Symuluj krótkie ładowanie
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        setState(() {
          hasSearched = true;
          isSearching = false;
          searchResults = _generateMockResults();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Brak połączenia z API - wyświetlam przykładowe połączenia',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      // Sprawdź czy data i godzina zostały wybrane
      String datetime;
      if (_dateController.text.isNotEmpty && _timeController.text.isNotEmpty) {
        // Konwertuj format daty z DD.MM.YYYY na YYYY-MM-DD
        final dateParts = _dateController.text.split('.');
        if (dateParts.length == 3) {
          final day = dateParts[0].padLeft(2, '0');
          final month = dateParts[1].padLeft(2, '0');
          final year = dateParts[2];
          datetime = '$year-$month-${day}T${_timeController.text}';
        } else {
          throw Exception('Nieprawidłowy format daty');
        }
      } else {
        // Użyj aktualnej daty i godziny jako domyślnej
        final now = DateTime.now();
        datetime =
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      }

      final result = await ApiService.searchJourneys(
        from: _fromController.text,
        to: _toController.text,
        datetime: datetime,
      );

      // Sprawdź czy faktycznie znaleziono połączenia
      bool hasResults = false;
      int resultCount = 0;
      String messageType = 'demo';

      if (result != null && result['error'] == null) {
        // Sprawdź różne możliwe struktury odpowiedzi API
        if (result['results'] is List &&
            (result['results'] as List).isNotEmpty) {
          hasResults = true;
          resultCount = (result['results'] as List).length;
          messageType = 'success';
        } else if (result['data'] is List &&
            (result['data'] as List).isNotEmpty) {
          hasResults = true;
          resultCount = (result['data'] as List).length;
          messageType = 'success';
        } else if (result['journeys'] is List &&
            (result['journeys'] as List).isNotEmpty) {
          hasResults = true;
          resultCount = (result['journeys'] as List).length;
          messageType = 'success';
        } else if (result is List && (result as List).isNotEmpty) {
          hasResults = true;
          resultCount = (result as List).length;
          messageType = 'success';
        }
      } else if (result?['error'] != null) {
        messageType = 'error';
      }

      // ZAWSZE pokaż wyniki - nawet przy błędzie API
      if (mounted) {
        setState(() {
          hasSearched = true;
          isSearching = false;
          if (hasResults) {
            // Jeśli mamy prawdziwe wyniki API
            searchResults = _extractSearchResults(result);
          } else {
            // Używamy mockowych danych dla demo/błędu
            searchResults = _generateMockResults();
          }
        });

        // Pokaż odpowiedni komunikat
        String message;
        Color backgroundColor;

        switch (messageType) {
          case 'success':
            message =
                'Znaleziono $resultCount połączeń z ${_fromController.text} do ${_toController.text}';
            backgroundColor = Colors.green;
            break;
          case 'error':
            message = 'Błąd API - wyświetlam przykładowe połączenia';
            backgroundColor = Colors.orange;
            break;
          default:
            message = 'Wyświetlam przykładowe połączenia (demo)';
            backgroundColor = Colors.blue;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: backgroundColor),
        );
        debugPrint('Journey search results: $result');
      }
    } catch (e) {
      if (mounted) {
        // NAWET przy wyjątku - pokaż mockowe wyniki
        setState(() {
          hasSearched = true;
          isSearching = false;
          searchResults = _generateMockResults();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Błąd połączenia - wyświetlam przykładowe połączenia',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        debugPrint('Journey search error: $e');
      }
    }
  }

  List<Map<String, dynamic>> _extractSearchResults(dynamic apiResult) {
    // Tutaj można będzie przetwarzać prawdziwe dane z API
    List<Map<String, dynamic>> results = [];

    // Różne możliwe struktury odpowiedzi API
    List<dynamic>? rawResults;
    if (apiResult['results'] is List) {
      rawResults = apiResult['results'];
    } else if (apiResult['data'] is List) {
      rawResults = apiResult['data'];
    } else if (apiResult['journeys'] is List) {
      rawResults = apiResult['journeys'];
    } else if (apiResult is List) {
      rawResults = apiResult;
    }

    if (rawResults != null) {
      for (var item in rawResults) {
        results.add({
          'from': item['from'] ?? 'Stacja A',
          'to': item['to'] ?? 'Stacja B',
          'departureTime': item['departureTime'] ?? '10:30',
          'arrivalTime': item['arrivalTime'] ?? '11:45',
          'duration': item['duration'] ?? '1h 15min',
          'changes': item['changes'] ?? 0,
          'platform': item['platform'] ?? '3',
        });
      }
    }

    return results;
  }

  List<Map<String, dynamic>> _generateMockResults() {
    // Mockowe dane połączeń - każde z inną trasą
    return [
      {
        'from': _fromController.text.isNotEmpty
            ? _fromController.text
            : 'KRAKÓW GŁÓWNY',
        'to': _toController.text.isNotEmpty ? _toController.text : 'TARNÓW',
        'departureTime': '16:04',
        'arrivalTime': '17:46',
        'duration': '1h 42min',
        'changes': 0,
        'platform': '3',
        'delay': 0,
        'trainType': 'IC',
        'routePoints': [
          {'lat': 50.0647, 'lng': 19.9450, 'name': 'Kraków Główny'},
          {'lat': 50.0135, 'lng': 20.9890, 'name': 'Tarnów'},
        ],
      },
      {
        'from': _fromController.text.isNotEmpty
            ? _fromController.text
            : 'KRAKÓW GŁÓWNY',
        'to': _toController.text.isNotEmpty ? _toController.text : 'TARNÓW',
        'departureTime': '17:40',
        'arrivalTime': '19:29',
        'duration': '1h 49min',
        'changes': 0,
        'platform': '1',
        'delay': 0,
        'trainType': 'RE',
        'routePoints': [
          {'lat': 50.0647, 'lng': 19.9450, 'name': 'Kraków Główny'},
          {'lat': 50.0800, 'lng': 20.2100, 'name': 'Bochnią'}, // Punkt pośredni
          {'lat': 50.0400, 'lng': 20.6500, 'name': 'Brzesko'}, // Punkt pośredni
          {'lat': 50.0135, 'lng': 20.9890, 'name': 'Tarnów'},
        ],
      },
      {
        'from': _fromController.text.isNotEmpty
            ? _fromController.text
            : 'KRAKÓW GŁÓWNY',
        'to': _toController.text.isNotEmpty ? _toController.text : 'TARNÓW',
        'departureTime': '18:15',
        'arrivalTime': '20:12',
        'duration': '1h 57min',
        'changes': 0,
        'platform': '2',
        'delay': 5,
        'trainType': 'TLK',
        'routePoints': [
          {'lat': 50.0647, 'lng': 19.9450, 'name': 'Kraków Główny'},
          {'lat': 50.1200, 'lng': 20.1000, 'name': 'Wieliczka'}, // Inna trasa
          {
            'lat': 50.0900,
            'lng': 20.4500,
            'name': 'Niepołomice',
          }, // Punkt pośredni
          {'lat': 50.0600, 'lng': 20.7800, 'name': 'Dębica'}, // Punkt pośredni
          {'lat': 50.0135, 'lng': 20.9890, 'name': 'Tarnów'},
        ],
      },
    ];
  }

  Widget _buildConnectionMap(Map<String, dynamic> connection) {
    final routePoints =
        connection['routePoints'] as List<Map<String, dynamic>>? ?? [];

    if (routePoints.isEmpty) {
      return Container(
        color: Colors.grey[400],
        child: const Center(
          child: Text(
            'Mapa niedostępna',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    }

    // Przygotuj punkty dla mapy
    final List<LatLng> mapPoints = routePoints
        .map((point) => LatLng(point['lat'] as double, point['lng'] as double))
        .toList();

    // Wyznacz centrum mapy
    double centerLat =
        mapPoints.map((p) => p.latitude).reduce((a, b) => a + b) /
        mapPoints.length;
    double centerLng =
        mapPoints.map((p) => p.longitude).reduce((a, b) => a + b) /
        mapPoints.length;

    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(centerLat, centerLng),
        initialZoom: 8.5,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
        ),
      ),
      children: [
        // Warstwa kafelków
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.journey_radar',
        ),

        // Linia trasy - kolor zależny od typu pociągu
        if (mapPoints.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: mapPoints,
                strokeWidth: 3.0,
                color: _getTrainColor(connection['trainType'] ?? 'IC'),
              ),
            ],
          ),

        // Markery stacji - mniejsze dla mini-mapy
        MarkerLayer(
          markers: routePoints.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            final isFirst = index == 0;
            final isLast = index == routePoints.length - 1;

            return Marker(
              point: LatLng(point['lat'] as double, point['lng'] as double),
              width: 24,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  color: isFirst
                      ? Colors.green
                      : (isLast ? Colors.red : Colors.blue),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Center(
                  child: Icon(
                    isFirst
                        ? Icons.play_arrow
                        : (isLast ? Icons.stop : Icons.circle),
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getTrainColor(String trainType) {
    switch (trainType.toUpperCase()) {
      case 'IC':
        return const Color(0xFFFDC300); // Żółty dla InterCity
      case 'RE':
        return Colors.blue; // Niebieski dla Regional Express
      case 'IR':
        return Colors.green; // Zielony dla InterRegio
      case 'TLK':
        return Colors.purple; // Fioletowy dla TLK
      default:
        return const Color(0xFFFDC300); // Domyślny żółty
    }
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🌄 Główne tło i zawartość
          AppBackground(
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 1),

                  // 📄 Główna zawartość
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 1),

                          // Logo
                          SizedBox(
                            height: 150,
                            child: SvgPicture.asset(
                              'assets/images/icons/logo.svg',
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 1),

                          // GlassCard z wyszukiwaniem
                          GlassCard(
                            width: double.infinity,
                            child: SizedBox(
                              height: 275,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Pastylka z nazwą przewoźnika i statusem API
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: const Text(
                                          'KOLEJE MAŁOPOLSKIE',
                                          style: TextStyle(
                                            color: Color(0xFF232323),
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: isApiConnected
                                              ? Colors.green
                                              : Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 16),

                                  // Blok wyszukiwania
                                  JourneySearchWidget(
                                    fromController: _fromController,
                                    toController: _toController,
                                    dateController: _dateController,
                                    timeController: _timeController,
                                  ),

                                  const SizedBox(height: 1),

                                  // Przycisk szukania
                                  CustomButton(
                                    text: 'SZUKAJ POŁĄCZEŃ',
                                    onPressed: _performJourneySearch,
                                    variant: CustomButtonVariant.primary,
                                    width: double.infinity,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // 🚂 Sekcja wyników wyszukiwania
                          if (isSearching)
                            const Center(
                              child: Column(
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text(
                                    'Szukam połączeń...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          if (hasSearched &&
                              !isSearching &&
                              searchResults.isNotEmpty)
                            Column(
                              children: [
                                for (final result in searchResults)
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    width: double.infinity,
                                    child: GlassCard(
                                      width: double.infinity,
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // 🟡 GÓRA – od/do (bez labeli) + okrągły „swap” na środku
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Row(
                                                  children: [
                                                    // lewa połowa – start
                                                    Expanded(
                                                      child: Container(
                                                        decoration: const BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                topLeft:
                                                                    Radius.circular(
                                                                      16,
                                                                    ),
                                                              ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              16,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              result['from'],
                                                              style: const TextStyle(
                                                                color: Color(
                                                                  0xFF232323,
                                                                ),
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              result['departureTime'],
                                                              style:
                                                                  const TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),

                                                    // prawa połowa – cel
                                                    Expanded(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white
                                                              .withValues(alpha: 0.5),
                                                          borderRadius:
                                                              const BorderRadius.only(
                                                                topRight:
                                                                    Radius.circular(
                                                                      16,
                                                                    ),
                                                              ),
                                                        ),
                                                        padding:
                                                            const EdgeInsets.fromLTRB(
                                                              32,
                                                              16,
                                                              16,
                                                              16,
                                                            ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              result['to'],
                                                              style: const TextStyle(
                                                                color: Color(
                                                                  0xFF232323,
                                                                ),
                                                                fontSize: 18,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 4,
                                                            ),
                                                            Text(
                                                              result['arrivalTime'],
                                                              style:
                                                                  const TextStyle(
                                                                    color: Colors
                                                                        .black54,
                                                                    fontSize:
                                                                        14,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),

                                                // środkowy okrąg (dekor)
                                                Container(
                                                  width: 38,
                                                  height: 38,
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: const Color(
                                                        0xFFFDC300,
                                                      ),
                                                      width: 2,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withValues(alpha: 0.1),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: const Icon(
                                                    Icons.arrow_forward_rounded,
                                                    size: 20,
                                                    color: Color(0xFFFDC300),
                                                  ),
                                                ),
                                              ],
                                            ),

                                            // 📊 szczegóły — kontynuacja headera
                                            Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                    horizontal: 16,
                                                  ),
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                border: Border(
                                                  top: BorderSide(
                                                    color: Color(0xFFFDC300),
                                                    width: 2,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.train,
                                                        color: Color(
                                                          0xFF232323,
                                                        ),
                                                        size: 18,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Text(
                                                        result['trainType'] ??
                                                            'Pociąg',
                                                        style: const TextStyle(
                                                          color: Color(
                                                            0xFF232323,
                                                          ),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (result['changes'] == 0)
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 5,
                                                          ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.green
                                                            .withValues(alpha: 0.1),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              12,
                                                            ),
                                                      ),
                                                      child: const Text(
                                                        'Bezpośredni',
                                                        style: TextStyle(
                                                          color: Colors.green,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                      ),
                                                    ),
                                                  Text(
                                                    'Peron ${result['platform']}',
                                                    style: const TextStyle(
                                                      color: Color(0xFF232323),
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // 🗺️ mini-mapa – przylepiona pod szczegółami
                                            Container(
                                              width: double.infinity,
                                              height: 180,
                                              decoration: const BoxDecoration(
                                                color: Colors.white,
                                                border: Border(
                                                  top: BorderSide(
                                                    color: Color(0xFFFDC300),
                                                    width: 2,
                                                  ),
                                                ),
                                                borderRadius: BorderRadius.only(
                                                  bottomLeft: Radius.circular(
                                                    16,
                                                  ),
                                                  bottomRight: Radius.circular(
                                                    16,
                                                  ),
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                      bottomLeft:
                                                          Radius.circular(16),
                                                      bottomRight:
                                                          Radius.circular(16),
                                                    ),
                                                child: _buildConnectionMap(
                                                  result,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),

                  // 🔐 Przyciski na dole - warunkowe wyświetlanie
                  if (isCheckingLoginStatus)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    )
                  else if (!isLoggedIn)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          CustomButton(
                            text: 'Zaloguj się',
                            variant: CustomButtonVariant.primary,
                            width: double.infinity,
                            onPressed: () async {
                              final result = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginPage(),
                                ),
                              );
                              // Jeśli logowanie się powiodło, odśwież stan
                              if (result == true) {
                                _checkLoginStatus();
                              }
                            },
                          ),
                          const SizedBox(height: 15),
                          CustomButton(
                            text: 'Zarejestruj się',
                            variant: CustomButtonVariant.glassWhite,
                            width: double.infinity,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 24,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Jesteś zalogowany',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 15),
                          CustomButton(
                            text: 'Wyloguj się',
                            variant: CustomButtonVariant.glassWhite,
                            width: double.infinity,
                            onPressed: _logout,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          /// 📂 Sidebar z BLUR
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: isSidebarOpen ? 0 : -250,
            top: 0,
            bottom: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    color: isSidebarOpen ? Colors.white : Colors.transparent,
                    width: isSidebarOpen ? 3.0 : 0.0,
                  ),
                ),
              ),
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                  child: Container(
                    width: 250,
                    color: const Color(
                      0xFFFDC300,
                    ).withValues(alpha: 0.25), // półprzezroczysty kolor
                    child: SafeArea(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Menu',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Przyciski zależne od stanu logowania
                          if (!isLoggedIn) ...[
                            // Przed zalogowaniem - tylko przycisk "Zaloguj"
                            ListTile(
                              leading: const Icon(
                                Icons.login,
                                color: Colors.white,
                              ),
                              title: const Text(
                                'Zaloguj',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () async {
                                setState(() {
                                  isSidebarOpen = false;
                                });
                                final result = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginPage(),
                                  ),
                                );
                                if (result == true) {
                                  _checkLoginStatus();
                                }
                              },
                            ),
                          ] else ...[
                            // Po zalogowaniu - przyciski "Profil" i "Zgłoś utrudnienia"
                            ListTile(
                              leading: const Icon(
                                Icons.person,
                                color: Colors.white,
                              ),
                              title: const Text(
                                'Profil',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                setState(() {
                                  isSidebarOpen = false;
                                });
                                // TODO: Navigacja do profilu
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Funkcja profilu w przygotowaniu'),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.report_problem,
                                color: Colors.white,
                              ),
                              title: const Text(
                                'Zgłoś utrudnienia',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                setState(() {
                                  isSidebarOpen = false;
                                });
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const TrainSearchScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                          const Spacer(),
                          if (isLoggedIn)
                            ListTile(
                              leading: const Icon(
                                Icons.logout,
                                color: Colors.white,
                              ),
                              title: const Text(
                                'Wyloguj',
                                style: TextStyle(color: Colors.white),
                              ),
                              onTap: () {
                                setState(() {
                                  isSidebarOpen = false;
                                });
                                _logout();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// 🔲 Przycisk otwierania sidebaru
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 20,
            right: isSidebarOpen ? 270 : 20,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.grid_view_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      isSidebarOpen = !isSidebarOpen;
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
