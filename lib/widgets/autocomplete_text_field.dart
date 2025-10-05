import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AutocompleteTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextStyle? textStyle;
  final InputDecoration? decoration;
  final EdgeInsets? contentPadding;

  const AutocompleteTextField({
    super.key,
    required this.controller,
    this.hintText = '',
    this.textStyle,
    this.decoration,
    this.contentPadding,
  });

  @override
  State<AutocompleteTextField> createState() => _AutocompleteTextFieldState();
}

class _AutocompleteTextFieldState extends State<AutocompleteTextField> {
  Timer? _debounceTimer;
  List<String> _suggestions = [];
  bool _isLoading = false;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    widget.controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onTextChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchSuggestions(widget.controller.text);
    });
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      if (_suggestions.isNotEmpty) {
        _showOverlay();
      }
      // Uruchom wyszukiwanie od razu po focus jeśli jest tekst
      if (widget.controller.text.isNotEmpty) {
        _searchSuggestions(widget.controller.text);
      }
    } else {
      _removeOverlay();
    }
  }

  Future<void> _searchSuggestions(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
      _removeOverlay();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final suggestions = await ApiService.searchAutocomplete(query);
      if (mounted) {
        setState(() {
          _suggestions = suggestions;
          _isLoading = false;
        });
        
        if (suggestions.isNotEmpty && _focusNode.hasFocus) {
          _showOverlay();
        } else {
          _removeOverlay();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
        _removeOverlay();
      }
    }
  }

  void _showOverlay() {
    _removeOverlay();
    
    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: _getTextFieldWidth(),
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, _getTextFieldHeight()),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    dense: true,
                    title: Text(
                      _suggestions[index],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF232323),
                      ),
                    ),
                    onTap: () {
                      widget.controller.text = _suggestions[index];
                      _removeOverlay();
                      _focusNode.unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
    
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _getTextFieldWidth() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.width ?? 200;
  }

  double _getTextFieldHeight() {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    return renderBox?.size.height ?? 40;
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: widget.decoration ??
            InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.grey.withOpacity(0.8),
                fontSize: 18,
              ),
              border: InputBorder.none,
              contentPadding: widget.contentPadding ?? const EdgeInsets.all(8),
              isDense: true,
              suffixIcon: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : null,
            ),
        style: widget.textStyle ??
            const TextStyle(
              color: Color(0xFF232323),
              fontSize: 12,
            ),
      ),
    );
  }
}
