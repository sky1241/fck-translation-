import 'dart:convert';

Map<String, dynamic> safeJsonDecodeToMap(String source) {
  final dynamic decoded = jsonDecode(source);
  if (decoded is Map<String, dynamic>) return decoded;
  throw const FormatException('JSON décodé mais racine non-objet.');
}

/// Extract first top-level JSON object substring from an arbitrary string.
/// Returns null if not found.
String? extractFirstJson(String input) {
  final int start = input.indexOf('{');
  if (start == -1) return null;

  int depth = 0;
  bool inString = false;
  bool isEscaped = false;
  for (int i = start; i < input.length; i++) {
    final String ch = input[i];
    if (inString) {
      if (isEscaped) {
        isEscaped = false;
      } else if (ch == '\\') {
        isEscaped = true;
      } else if (ch == '"') {
        inString = false;
      }
      continue;
    }

    if (ch == '"') {
      inString = true;
      continue;
    }
    if (ch == '{') depth++;
    if (ch == '}') depth--;
    if (depth == 0) {
      return input.substring(start, i + 1);
    }
  }
  return null;
}


