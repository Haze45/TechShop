enum DashboardDateFilter {
  last7Days,
  last30Days,
  last90Days,
  last6Months,
  last12Months,
  allTime,
}

extension DashboardDateFilterExtension on DashboardDateFilter {
  String get label {
    switch (this) {
      case DashboardDateFilter.last7Days:
        return 'Last 7 Days';

      case DashboardDateFilter.last30Days:
        return 'Last 30 Days';

      case DashboardDateFilter.last90Days:
        return 'Last 90 Days';

      case DashboardDateFilter.last6Months:
        return 'Last 6 Months';

      case DashboardDateFilter.last12Months:
        return 'Last 12 Months';

      case DashboardDateFilter.allTime:
        return 'All Time';
    }
  }

  DateTime? get startDate {
    final now = DateTime.now();

    switch (this) {
      case DashboardDateFilter.last7Days:
        return DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 6));

      case DashboardDateFilter.last30Days:
        return DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 29));

      case DashboardDateFilter.last90Days:
        return DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(const Duration(days: 89));

      case DashboardDateFilter.last6Months:
        return DateTime(now.year, now.month - 6, now.day);

      case DashboardDateFilter.last12Months:
        return DateTime(now.year, now.month - 12, now.day);

      case DashboardDateFilter.allTime:
        return null;
    }
  }

  DateTime get endDate {
    final now = DateTime.now();

    // Exclusive end boundary: beginning of tomorrow.
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  String? get startAtUtc {
    return startDate?.toUtc().toIso8601String();
  }

  String get endAtUtc {
    return endDate.toUtc().toIso8601String();
  }
}
