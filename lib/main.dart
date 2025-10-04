import 'package:flutter/material.dart';
import 'widgets/app_background.dart';
import 'screens/second_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Journey Radar',
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'na czas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Text(
                'MAŁOPOLSKIE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SecondScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFFDC300),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Przejdź do drugiego ekranu',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
