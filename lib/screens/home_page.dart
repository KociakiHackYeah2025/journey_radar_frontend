import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import 'login_page.dart';
import 'leaflet_map_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> _logout(BuildContext context) async {
    await ApiService.logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journey Radar'),
        backgroundColor: const Color(0xFFFDC300),
        actions: [
          IconButton(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            tooltip: 'Wyloguj się',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.explore,
                size: 80,
                color: Color(0xFFFDC300),
              ),
              const SizedBox(height: 20),
              const Text(
                'Witamy w Journey Radar!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4565AD),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Odkrywaj nowe miejsca i twórz swoją mapę wspomnień',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              
              // Przycisk do mapy
              CustomButton(
                text: 'Otwórz mapę',
                variant: CustomButtonVariant.primary,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LeafletMapScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              
              // Przycisk z statystykami (placeholder)
              CustomButton(
                text: 'Moje punkty',
                variant: CustomButtonVariant.textOnly,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funkcja w przygotowaniu'),
                      backgroundColor: Color(0xFFFDC300),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}