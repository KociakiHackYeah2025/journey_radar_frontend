import 'package:flutter/material.dart';

class JourneySearchWidget extends StatelessWidget {
  final TextEditingController? fromController;
  final TextEditingController? toController;
  final VoidCallback? onSwap;

  const JourneySearchWidget({
    super.key,
    this.fromController,
    this.toController,
    this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: 90,
          child: Row(
            children: [
              // Lewa połowa - biała
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: Color(0xFFFDC300),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'SKĄD?',
                              style: TextStyle(
                                color: Color(0xFF232323),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 6),
                            child: TextField(
                              controller: fromController,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  color: Colors.grey.withOpacity(0.8),
                                  fontSize: 18,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(right: 24),
                                isDense: true,
                              ),
                              style: const TextStyle(
                                color: Color(0xFF232323),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Prawa połowa - 50% przezroczystość
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.navigation,
                              size: 16,
                              color: Color(0xFFFDC300),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'DOKĄD?',
                              style: TextStyle(
                                color: Color(0xFF232323),
                                fontSize: 14,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(top: 6),
                            child: TextField(
                              controller: toController,
                              decoration: InputDecoration(
                                hintStyle: TextStyle(
                                  color: Colors.grey.withOpacity(0.8),
                                  fontSize: 18,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(left: 12),
                                isDense: true,
                              ),
                              style: const TextStyle(
                                color: Color(0xFF232323),
                                fontSize: 12,
                              ),
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
        ),
        // Ikona na środku z białym kółkiem i borderem
        Positioned(
          top: 50 - 16, // 50% wysokości - połowa rozmiaru kółka
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: onSwap,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFDC300),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.swap_horiz,
                  size: 18,
                  color: Color(0xFFFDC300),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
