int compareSemver(String a, String b) {
  List<int> parse(String value) {
    final core = value.split('+').first.split('-').first.trim();
    final parts = core.split('.').map((part) => int.tryParse(part) ?? 0).toList();
    while (parts.length < 3) {
      parts.add(0);
    }
    return parts.take(3).toList();
  }

  final left = parse(a);
  final right = parse(b);
  for (var i = 0; i < 3; i++) {
    final compared = left[i].compareTo(right[i]);
    if (compared != 0) return compared;
  }
  return 0;
}
