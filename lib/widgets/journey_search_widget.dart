import 'package:flutter/material.dart';
import 'autocomplete_text_field.dart';

class JourneySearchWidget extends StatefulWidget {
  final VoidCallback? onSwap;
  final TextEditingController fromController;
  final TextEditingController toController;
  final TextEditingController dateController;
  final TextEditingController timeController;

  const JourneySearchWidget({
    super.key,
    this.onSwap,
    required this.fromController,
    required this.toController,
    required this.dateController,
    required this.timeController,
  });

  @override
  State<JourneySearchWidget> createState() => _JourneySearchWidgetState();
}

class _JourneySearchWidgetState extends State<JourneySearchWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _swapLocations() {
    final temp = widget.fromController.text;
    widget.fromController.text = widget.toController.text;
    widget.toController.text = temp;
    widget.onSwap?.call();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      widget.dateController.text = '${picked.day.toString().padLeft(2, '0')}.${picked.month.toString().padLeft(2, '0')}.${picked.year}';
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      widget.timeController.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Górny rząd - SKĄD i DOKĄD
        Stack(
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
                            const SizedBox(height: 1),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(top: 6),
                                child: AutocompleteTextField(
                                  controller: widget.fromController,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                      color: Colors.grey.withValues(alpha: 0.8),
                                      fontSize: 18,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.only(right: 24),
                                    isDense: true,
                                  ),
                                  textStyle: const TextStyle(
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
                                      color: Colors.white.withValues(alpha: 0.5),
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
                            const SizedBox(height: 1),
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.only(top: 6),
                                child: AutocompleteTextField(
                                  controller: widget.toController,
                                  decoration: InputDecoration(
                                    hintStyle: TextStyle(
                                      color: Colors.grey.withValues(alpha: 0.8),
                                      fontSize: 18,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.only(left: 12),
                                    isDense: true,
                                  ),
                                  textStyle: const TextStyle(
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
                  onTap: _swapLocations,
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
        ),
        
        const SizedBox(height: 1),
        
        // Dolny rząd - DATA i GODZINA
        Container(
          width: double.infinity,
          height: 70,
          child: Row(
            children: [
              // Lewa część - DATA (70%)
              Flexible(
                flex: 7,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: Color(0xFFFDC300),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: widget.dateController,
                            decoration: InputDecoration(
                              hintText: 'Wybierz datę',
                              hintStyle: TextStyle(
                                color: Colors.grey.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              color: Color(0xFF232323),
                              fontSize: 12,
                            ),
                            readOnly: true,
                            onTap: () => _selectDate(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Prawa część - GODZINA (30%)
              Flexible(
                flex: 3,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 16,
                          color: Color(0xFFFDC300),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: widget.timeController,
                            decoration: InputDecoration(
                              hintText: 'Wybierz godzinę',
                              hintStyle: TextStyle(
                                color: Colors.grey.withValues(alpha: 0.8),
                                fontSize: 12,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: const TextStyle(
                              color: Color(0xFF232323),
                              fontSize: 12,
                            ),
                            readOnly: true,
                            onTap: () => _selectTime(context),
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
      ],
    );
  }
}
