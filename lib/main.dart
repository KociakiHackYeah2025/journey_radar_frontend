import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widgets/app_background.dart';
import 'widgets/glass_card.dart';
import 'widgets/custom_button.dart';
import 'widgets/journey_search_widget.dart';
import 'screens/login_page.dart';
import 'screens/register_page.dart';

void main() {
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

  @override
  Widget build(BuildContext context) {
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

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
                          Container(
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
                            child: Container(
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

                  // 🔐 Przyciski na dole
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        CustomButton(
                          text: 'Zaloguj się',
                          variant: CustomButtonVariant.primary,
                          width: double.infinity,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                            );
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
                  ),
                ],
              ),
            ),
          ),

          /// 📂 Sidebar wysuwany z prawej strony
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: isSidebarOpen ? 0 : -250,
            top: 0,
            bottom: 0,
            child: Container(
              width: 250,
              color: const Color(0xFFFDC300).withOpacity(0.8),
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
                      onTap: () {},
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
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.white),
                      title: const Text(
                        'Wyloguj',
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// 🔲 PRZYCISK TOGGLE — równy odstęp, przesuwa się z sidebarem
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 20, // 📏 równy odstęp od góry
            right: isSidebarOpen ? 250 + 20 : 20, // 📏 20px od prawej
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
