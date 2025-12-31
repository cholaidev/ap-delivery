import 'package:flutter/material.dart';

enum DateFilterType { today, week, month, custom }

class DateFilterHelper {
  static bool isInRange({
    required DateTime date,
    required DateFilterType filter,
    DateTimeRange? customRange,
  }) {
    final now = DateTime.now();

    switch (filter) {
      case DateFilterType.today:
        return date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;

      case DateFilterType.week:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return date.isAfter(startOfWeek.subtract(const Duration(seconds: 1))) &&
            date.isBefore(endOfWeek.add(const Duration(days: 1)));

      case DateFilterType.month:
        return date.year == now.year && date.month == now.month;

      case DateFilterType.custom:
        if (customRange == null) return false;
        return date.isAfter(
              customRange.start.subtract(const Duration(seconds: 1)),
            ) &&
            date.isBefore(customRange.end.add(const Duration(days: 1)));
    }
  }
}
