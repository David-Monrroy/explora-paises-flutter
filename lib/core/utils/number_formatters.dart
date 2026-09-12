String compactNumber(num value) {
  if (value >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)} B';
  }
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)} M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)} K';
  return value.toString();
}

String formatNumber(num value) {
  final text = value.round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    final reverseIndex = text.length - i;
    buffer.write(text[i]);
    if (reverseIndex > 1 && reverseIndex % 3 == 1) {
      buffer.write('.');
    }
  }
  return buffer.toString();
}
