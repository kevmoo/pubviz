const colorPink = 'pink';
const colorRed = 'red';
const colorPrimary = '#0175C2'; // Dart blue
const colorBackgroundPrimary = '#e3f2fd'; // Light blue

bool isOutdatedColor(String? color) {
  if (color == null) return false;
  final c = color.toLowerCase();
  return c == colorRed || c == colorPink;
}
