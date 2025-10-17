import 'package:intl/intl.dart';

class DateTimeFormatter {
    static String format(DateTime dateTime) {
        final now = DateTime.now();
        final difference = now.difference(dateTime);

        // Today's entry
        if (difference.inDays == 0) {
            return 'Today at ${DateFormat.jm().format(dateTime)}';
        }

        // Yesterday's entry
        if (difference.inDays == 1) {
            return 'Yesterday at ${DateFormat.jm().format(dateTime)}';
        }

        // Entries within the previous week
        if (difference.inDays < 7) {
            return '${DateFormat.EEEE().format(dateTime)} at ${DateFormat.jm().format(dateTime)}';
        }

        // Entries longer than a week
        return DateFormat('MMM d, yyyy - h:mm a').format(dateTime);
    }
}