class DateFormatter {
  static const List<String> _namaBulan = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember'
  ];

  static String formatFull(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = _namaBulan[dateTime.month];
    final year = dateTime.year;
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute WIB';
  }

  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second WIB';
  }

  static String formatShortDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = _namaBulan[dateTime.month].substring(0, 3);
    final year = dateTime.year;
    return '$day $month $year';
  }

  static String timeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inSeconds < 60) {
      return '${diff.inSeconds} detik yang lalu';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} menit yang lalu';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} jam yang lalu';
    } else {
      return '${diff.inDays} hari yang lalu';
    }
  }
}

