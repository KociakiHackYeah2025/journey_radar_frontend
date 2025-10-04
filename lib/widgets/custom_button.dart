import 'package:flutter/material.dart';

enum CustomButtonVariant {
  primary,
  textOnly,
  textYellow,
  glassWhite,
  // Tutaj dodamy kolejne warianty w przyszłości
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final CustomButtonVariant variant;
  final EdgeInsetsGeometry? margin;
  final double? width;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.margin,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      child: ElevatedButton(
        onPressed: onPressed,
        style: _getButtonStyle(),
        child: Text(text, style: _getTextStyle()),
      ),
    );
  }

  ButtonStyle _getButtonStyle() {
    switch (variant) {
      case CustomButtonVariant.primary:
        return ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4565AD),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        );
      case CustomButtonVariant.textOnly:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        );
      case CustomButtonVariant.textYellow:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        );
      case CustomButtonVariant.glassWhite:
        return ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.white, width: 1.5),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        );
    }
  }

  TextStyle _getTextStyle() {
    switch (variant) {
      case CustomButtonVariant.primary:
        return const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        );
      case CustomButtonVariant.textOnly:
        return const TextStyle(
          color: Color(0xFF4565AD),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );
      case CustomButtonVariant.textYellow:
        return const TextStyle(
          color: Color(0xFFFDC300),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        );
      case CustomButtonVariant.glassWhite:
        return const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        );
    }
  }
}
