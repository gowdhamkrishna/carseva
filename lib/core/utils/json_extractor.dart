import 'dart:convert';

/// Utility to robustly extract JSON from AI responses.
/// Handles markdown code blocks, surrounding text, and messy formatting.
class JsonExtractor {
  /// Extract a JSON object { ... } from text that may contain surrounding content.
  static Map<String, dynamic> extractObject(String text) {
    final cleaned = _stripMarkdown(text);
    
    final startIndex = cleaned.indexOf('{');
    if (startIndex == -1) return {};
    
    int bracketCount = 0;
    int endIndex = -1;
    for (int i = startIndex; i < cleaned.length; i++) {
      if (cleaned[i] == '{') bracketCount++;
      if (cleaned[i] == '}') bracketCount--;
      if (bracketCount == 0) { endIndex = i; break; }
    }
    if (endIndex == -1) return {};
    
    try {
      return json.decode(cleaned.substring(startIndex, endIndex + 1));
    } catch (e) {
      print('❌ JSON object decode error: $e');
      return {};
    }
  }

  /// Extract a JSON array [ ... ] from text that may contain surrounding content.
  static List<dynamic> extractArray(String text) {
    final cleaned = _stripMarkdown(text);
    
    final startIndex = cleaned.indexOf('[');
    if (startIndex == -1) return [];
    
    int bracketCount = 0;
    int endIndex = -1;
    for (int i = startIndex; i < cleaned.length; i++) {
      if (cleaned[i] == '[') bracketCount++;
      if (cleaned[i] == ']') bracketCount--;
      if (bracketCount == 0) { endIndex = i; break; }
    }
    if (endIndex == -1) return [];
    
    try {
      return json.decode(cleaned.substring(startIndex, endIndex + 1));
    } catch (e) {
      print('❌ JSON array decode error: $e');
      return [];
    }
  }

  static String _stripMarkdown(String text) {
    String cleaned = text.trim();
    // Remove ```json ... ``` and ``` ... ``` blocks
    cleaned = cleaned.replaceAll(RegExp(r'```json\s*', multiLine: true), '');
    cleaned = cleaned.replaceAll(RegExp(r'```\s*', multiLine: true), '');
    return cleaned.trim();
  }
}
