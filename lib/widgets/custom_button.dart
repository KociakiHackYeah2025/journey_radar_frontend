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
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.margin,
    this.width,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: margin,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: _getButtonStyle(),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(text, style: _getTextStyle()),
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
          backgroundColor: Colors.white.withValues(alpha: 0.9),
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
