import 'package:flutter/material.dart';

/// Reusable autocomplete text field widget
class AutocompleteTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final List<String> suggestions;
  final String? Function(String?)? validator;
  final void Function(String)? onSelected;

  const AutocompleteTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.suggestions,
    this.validator,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue.text.isEmpty) {
            return const Iterable<String>.empty();
          }
          return suggestions.where((String option) {
            return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
          });
        },
        onSelected: (String selection) {
          controller.text = selection;
          if (onSelected != null) onSelected!(selection);
        },
        fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
          // Sync with provided controller
          textEditingController.text = controller.text;
          textEditingController.addListener(() {
            controller.text = textEditingController.text;
          });

          return TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: label,
              hintText: hint,
              labelStyle: const TextStyle(color: Color(0xFF6C63FF)),
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              filled: true,
              fillColor: const Color(0xFF1A1F3A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6C63FF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: const Color(0xFF6C63FF).withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down, color: Color(0xFF6C63FF)),
            ),
            validator: validator,
            onFieldSubmitted: (value) => onFieldSubmitted(),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF1A1F3A),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200, maxWidth: 300),
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(option),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          option,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
