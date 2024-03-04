// Shared formatting helpers.
//
// NOTE: not every screen uses these. Some format prices inline.

String formatPrice(int price) {
  if (price >= 1000000) {
    final millions = price / 1000000;
    return '฿${millions.toStringAsFixed(2)}M';
  }
  if (price >= 1000) {
    final thousands = price / 1000;
    return '฿${thousands.toStringAsFixed(0)}K';
  }
  return '฿$price';
}

String formatArea(double sqm) {
  return '${sqm.toStringAsFixed(1)} m²';
}

String formatDateShort(String iso) {
  final date = DateTime.parse(iso);
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

String formatTime(String iso) {
  final date = DateTime.parse(iso);
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

String relativeTime(String iso) {
  final date = DateTime.parse(iso);
  final diff = DateTime.now().difference(date);
  if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
  if (diff.inDays > 0) return '${diff.inDays} days ago';
  if (diff.inHours > 0) return '${diff.inHours} hours ago';
  return 'Just now';
}
