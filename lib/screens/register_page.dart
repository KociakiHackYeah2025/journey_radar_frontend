import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_card.dart';
import '../services/api_service.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await ApiService.register(
          _emailController.text.trim(),
          _passwordController.text,
        );

        if (result != null) {
          if (result['error'] != null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Błąd rejestracji'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            // Sukces - pokaż komunikat i przekieruj do logowania
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Konto zostało utworzone pomyślnie!'),
                  backgroundColor: Colors.green,
                ),
              );

              // Przekierowanie do strony logowania
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Wystąpił nieoczekiwany błąd'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Proszę wprowadzić email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Proszę wprowadzić prawidłowy email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Proszę wprowadzić hasło';
    }
    if (value.length < 6) {
      return 'Hasło musi mieć co najmniej 6 znaków';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Proszę potwierdzić hasło';
    }
    if (value != _passwordController.text) {
      return 'Hasła nie są identyczne';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header z przyciskiem wstecz
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    // Przycisk wstecz
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    // Pusty kontener dla wyrównanias
                  ],
                ),
              ),

              // Główna zawartość
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
                    
                    return SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: 24,
                        right: 24,
                        bottom: keyboardHeight > 0 ? keyboardHeight + 20 : 0,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Column(
                            children: [
                              // Logo na górze
                              Container(
                                height: 110,
                                child: SvgPicture.asset(
                                  'assets/logo.svg',
                                  fit: BoxFit.contain,
                                  placeholderBuilder: (BuildContext context) => Container(
                                    child: const Center(
                                      child: Text(
                                        'MAŁOPOLSKIE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 2.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Karta rejestracji
                              GlassCard(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      // Tekst powitalny
                                      const Text(
                                        'Witamy w podróży z nami!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Pole Email
                                      TextFormField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        validator: _validateEmail,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Email',
                                          hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFFDC300),
                                              width: 2,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                              width: 1,
                                            ),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Pole Hasło
                                      TextFormField(
                                        controller: _passwordController,
                                        obscureText: true,
                                        validator: _validatePassword,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Hasło',
                                          hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFFDC300),
                                              width: 2,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                              width: 1,
                                            ),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Pole Powtórz hasło
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        obscureText: true,
                                        validator: _validateConfirmPassword,
                                        style: const TextStyle(
                                          color: Colors.black87,
                                          fontSize: 16,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Powtórz hasło',
                                          hintStyle: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                          filled: true,
                                          fillColor: Colors.white,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                              width: 1,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Color(0xFFFDC300),
                                              width: 2,
                                            ),
                                          ),
                                          errorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                              width: 1,
                                            ),
                                          ),
                                          focusedErrorBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: const BorderSide(
                                              color: Colors.red,
                                              width: 2,
                                            ),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 24),

                                      // Przycisk Zarejestruj się
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _handleRegister,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF5A7BC8),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<Color>(
                                                          Colors.white,
                                                        ),
                                                  ),
                                                )
                                              : const Text(
                                                  'ZAREJESTRUJ SIĘ',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 40),
                              
                              // Spacer aby wypchać link na dół
                              const Spacer(),
                              
                              // Link do logowania na dole ekranu  
                              Column(
                                children: [
                                  const Text(
                                    'Dołączyłeś już do nas?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const LoginPage(),
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Zaloguj się',
                                      style: TextStyle(
                                        color: Color(0xFFFDC300),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.underline,
                                        decorationColor: Color(0xFFFDC300),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
