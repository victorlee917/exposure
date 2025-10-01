String extractYear(String? date) {
  if (date == null || date.isEmpty) return 'Unknown';
  final m = RegExp(r'\b(\d{4})\b').firstMatch(date);
  return m != null ? m.group(1)! : 'Unknown';
}
