const colorPink = 'pink';
const colorRed = 'red';

bool isOutdatedColor(String? color) {
  if (color == null) return false;
  final c = color.toLowerCase();
  return c == colorRed || c == colorPink;
}
