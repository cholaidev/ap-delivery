import 'package:flutter/material.dart';

/// Date filter types
enum DateFilterTypes { today, week, month, custom }

/// Resolve a date filter into an actual DateTimeRange
DateTimeRange resolveDateRange(
  DateFilterTypes filter,
  DateTimeRange? customRange,
) {
  final now = DateTime.now();

  switch (filter) {
    case DateFilterTypes.today:
      final start = DateTime(now.year, now.month, now.day);
      return DateTimeRange(
        start: start,
        end: start.add(const Duration(days: 1)),
      );

    case DateFilterTypes.week:
      final start = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: now.weekday - 1));
      return DateTimeRange(
        start: start,
        end: start.add(const Duration(days: 7)),
      );

    case DateFilterTypes.month:
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 1);
      return DateTimeRange(start: start, end: end);

    case DateFilterTypes.custom:
      if (customRange == null) {
        throw ArgumentError(
          'Custom date range must be provided for DateFilterType.custom',
        );
      }
      return customRange;
  }
}
