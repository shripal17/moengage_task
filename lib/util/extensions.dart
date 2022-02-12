import 'package:intl/intl.dart';

extension StringX on String {
  // helper getter to translate camel case to readable text
  String get readableFromCamelCase {
    String readable = this[0].toUpperCase();
    for (int i = 1; i < length; i++) {
      if (this[i].toUpperCase() == this[i]) {
        readable += " " + this[i];
      } else {
        readable += this[i];
      }
    }
    return readable;
  }
}

final _timeDf = DateFormat("hh:mm");
final _dateDf = DateFormat("dd MMM");

extension HumanTimeX on DateTime {
  // helper getter to return human-friendly time
  String get humanReadableTime {
    final now = DateTime.now();
    final difference = now.difference(this);
    if (difference.inMinutes <= 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}min ago";
    } else if (difference.inHours < 12) {
      return "${difference.inHours} hours ago";
    } else if (difference.inHours <= 48 && now.day == day) {
      if (now.day == day) {
        return _timeDf.format(this);
      } else {
        return "Yesterday";
      }
    } else if (difference.inDays < 30) {
      return "${difference.inDays} days ago";
    }
    return _dateDf.format(this);
  }
}
