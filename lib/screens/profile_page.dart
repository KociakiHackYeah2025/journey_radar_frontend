import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import '../widgets/custom_button.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userInfo;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final result = await ApiService.getUserInfo();

      if (mounted) {
        setState(() {
          if (result != null && result['error'] == null) {
            userInfo = result;
          } else {
            errorMessage =
                result?['message'] ?? 'Nie udało się pobrać danych profilu';
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Wystąpił błąd: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    try {
      await ApiService.logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Zostałeś wylogowany'),
            backgroundColor: Colors.green,
          ),
        );
        // Zwróć true aby poinformować ekran główny o wylogowaniu
        Navigator.of(context).pop(true);
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

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Usuń konto'),
        content: const Text(
          'Czy na pewno chcesz usunąć swoje konto? Ta operacja jest nieodwracalna.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Anuluj'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Usuń konto'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() {
          isLoading = true;
        });

        final result = await ApiService.deleteAccount();

        if (mounted) {
          setState(() {
            isLoading = false;
          });

          if (result != null && result['success'] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Konto zostało usunięte'),
                backgroundColor: Colors.green,
              ),
            );
            // Zwróć true aby poinformować ekran główny o usunięciu konta (które powoduje wylogowanie)
            Navigator.of(context).pop(true);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(result?['message'] ?? 'Nie udało się usunąć konta'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Wystąpił błąd: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 🔥 Funkcja do wyznaczania rangi i progu
  Map<String, dynamic> _getRankInfo(int points) {
    if (points >= 300) {
      return {
        'rank': 'Ekspert',
        'nextLevel': null,
        'nextGoal': 300,
      };
    } else if (points >= 150) {
      return {
        'rank': 'Doświadczony',
        'nextLevel': 'Ekspert',
        'nextGoal': 300,
      };
    } else if (points >= 50) {
      return {
        'rank': 'Aktywny',
        'nextLevel': 'Doświadczony',
        'nextGoal': 150,
      };
    } else {
      return {
        'rank': 'Początkujący',
        'nextLevel': 'Aktywny',
        'nextGoal': 50,
      };
    }
  }

  /// 🔥 Oblicz procent progresu do kolejnej rangi
  double _calculateProgress(int points) {
    final info = _getRankInfo(points);
    final nextGoal = info['nextGoal'];
    if (nextGoal == null) return 1.0; // Ekspert — max progress
    double base = 0;
    if (points >= 150) base = 150;
    else if (points >= 50) base = 50;
    else base = 0;

    return ((points - base) / (nextGoal - base)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final points = userInfo?['points'] ?? 0;
    final rankInfo = _getRankInfo(points);
    final rank = rankInfo['rank'];
    final nextGoal = rankInfo['nextGoal'];
    final nextLevel = rankInfo['nextLevel'];
    final pointsToNext = nextGoal != null ? (nextGoal - points) : 0;
    final progress = _calculateProgress(points);

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // 🔙 Górna belka
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Profil',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      SizedBox(
                        height: 100,
                        child: SvgPicture.asset(
                          'assets/images/icons/logo.svg',
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 30),

                      if (isLoading)
                        const CircularProgressIndicator()
                      else if (errorMessage != null)
                        Text(errorMessage!)
                      else if (userInfo != null)
                        GlassCard(
                          width: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 🌟 Nagłówek z rangą
                                Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.9),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.star,
                                        color: Color(0xFFFDC300),
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      rank.toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // 📊 Karta użytkownika
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userInfo!['email']
                                                ?.toString()
                                                .toUpperCase() ??
                                            'BRAK DANYCH',
                                        style: const TextStyle(
                                          color: Color(0xFF232323),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'dziękujemy, że jesteś z nami.',
                                        style: TextStyle(
                                          color: Color(0xFF666666),
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // 📍 Punkty
                                      Text(
                                        '$points punktów',
                                        style: const TextStyle(
                                          color: Color(0xFF232323),
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      // 📶 Pasek postępu
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          minHeight: 8,
                                          backgroundColor:
                                              Colors.grey.withOpacity(0.3),
                                          valueColor:
                                              const AlwaysStoppedAnimation(
                                                  Color(0xFF5A7BC8)),
                                        ),
                                      ),

                                      const SizedBox(height: 8),

                                      // 📢 Info o następnej randze
                                      if (nextLevel != null)
                                        Text(
                                          'Brakuje $pointsToNext punktów, by zostać $nextLevel.',
                                          style: const TextStyle(
                                            color: Color(0xFF5A7BC8),
                                            fontSize: 12,
                                          ),
                                        )
                                      else
                                        const Text(
                                          'Osiągnąłeś najwyższą rangę! 🎉',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 12,
                                          ),
                                        ),

                                      const SizedBox(height: 12),
                                      const Text(
                                        'Za każde pomyślne zgłoszenie otrzymasz 25 punktów.',
                                        style: TextStyle(
                                          color: Color(0xFF666666),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ),

              // 🔐 Footer
              if (userInfo != null && !isLoading && errorMessage == null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      CustomButton(
                        text: 'Wyloguj',
                        variant: CustomButtonVariant.primary,
                        width: double.infinity,
                        onPressed: _logout,
                      ),
                      const SizedBox(height: 15),
                      CustomButton(
                        text: 'Usuń konto',
                        variant: CustomButtonVariant.glassWhite,
                        width: double.infinity,
                        onPressed: _deleteAccount,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
