import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'widgets/app_background.dart';
import 'widgets/glass_card.dart';
import 'widgets/custom_button.dart';
import 'widgets/journey_search_widget.dart';
import 'services/api_service.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';
import 'screens/home_page.dart';
import 'screens/leaflet_map_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
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
                              height: 210,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Pastylka z nazwą przewoźnika
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Text(
                                        'KOLEJE MAZOWIECKIE',
                                        style: TextStyle(
                                          color: Color(0xFF232323),
                                          fontSize: 12,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Blok wyszukiwania
                                  const JourneySearchWidget(),

                                  const SizedBox(height: 16),

                                  // Przycisk szukania
                                  CustomButton(
                                    text: 'SZUKAJ POŁĄCZEŃ',
                                    onPressed: () {},
                                    variant: CustomButtonVariant.primary,
                                    width: double.infinity,
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
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
                              color: Colors.white.withOpacity(0.1),
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
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(
                  width: 250,
                  color: const Color(0xFFFDC300).withOpacity(0.25), // półprzezroczysty kolor
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
                        ListTile(
                          leading: const Icon(Icons.home, color: Colors.white),
                          title: const Text(
                            'Strona główna',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            setState(() {
                              isSidebarOpen = false;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomePage(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.map, color: Colors.white),
                          title: const Text(
                            'Mapa',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            setState(() {
                              isSidebarOpen = false;
                            });
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LeafletMapScreen(),
                              ),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.settings, color: Colors.white),
                          title: const Text(
                            'Ustawienia',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(Icons.info, color: Colors.white),
                          title: const Text(
                            'O aplikacji',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {},
                        ),
                        const Spacer(),
                        if (isLoggedIn)
                          ListTile(
                            leading: const Icon(Icons.logout, color: Colors.white),
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

          /// 🔲 Przycisk otwierania sidebaru
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 20,
            right: isSidebarOpen ? 270 : 20,
            child: SafeArea(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
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
