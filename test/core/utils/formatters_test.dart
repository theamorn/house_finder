import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/core/utils/formatters.dart';

void main() {
  group('formatPrice', () {
    test('formats zero as raw baht value', () {
      expect(formatPrice(0), '฿0');
    });

    test('formats small values under 1,000 as raw baht value', () {
      expect(formatPrice(1), '฿1');
      expect(formatPrice(999), '฿999');
    });

    test('formats values >= 1,000 and < 1,000,000 in thousands (K)', () {
      // Exact multiples of 1000 avoid ambiguous half-up rounding.
      expect(formatPrice(1000), '฿1K');
      expect(formatPrice(5000), '฿5K');
      expect(formatPrice(25000), '฿25K');
      expect(formatPrice(999000), '฿999K');
    });

    test('formats values >= 1,000,000 in millions (M) with 2 decimals', () {
      expect(formatPrice(1000000), '฿1.00M');
      expect(formatPrice(2500000), '฿2.50M');
      // 12345678 / 1000000 = 12.345678 -> rounds to 12.35
      expect(formatPrice(12345678), '฿12.35M');
    });

    test('boundary just below the millions threshold uses thousands', () {
      // 999999 / 1000 = 999.999 -> toStringAsFixed(0) rounds to 1000
      expect(formatPrice(999999), '฿1000K');
    });
  });

  group('formatArea', () {
    test('rounds to 1 decimal place and appends m² suffix', () {
      expect(formatArea(45.678), '45.7 m²');
      expect(formatArea(3.14159), '3.1 m²');
    });

    test('formats whole numbers with a trailing .0', () {
      expect(formatArea(100.0), '100.0 m²');
      expect(formatArea(0.0), '0.0 m²');
    });
  });

  group('formatDateShort', () {
    test('formats a mid-year date', () {
      // Hand-computed: Jan 15, 2024
      expect(formatDateShort('2024-01-15T10:30:00'), '15 Jan 2024');
    });

    test('formats the first day of December', () {
      // Hand-computed: Dec 1, 2024
      expect(formatDateShort('2024-12-01T00:00:00'), '1 Dec 2024');
    });

    test('formats the last day of February in a non-leap year', () {
      // Hand-computed: Feb 28, 2023
      expect(formatDateShort('2023-02-28T23:59:59'), '28 Feb 2023');
    });
  });

  group('formatTime', () {
    test('pads single-digit hours and minutes with leading zeros', () {
      // Hand-computed: 00:05
      expect(formatTime('2024-01-15T00:05:00'), '00:05');
    });

    test('formats a mid-day time without padding needed', () {
      // Hand-computed: 10:30
      expect(formatTime('2024-01-15T10:30:00'), '10:30');
    });

    test('formats the last minute of the day', () {
      // Hand-computed: 23:59
      expect(formatTime('2024-01-15T23:59:00'), '23:59');
    });
  });

  group('relativeTime', () {
    test('returns "X months ago" for dates far more than 30 days in the past', () {
      // A date many years in the past is unambiguously > 30 days ago
      // regardless of when this test runs.
      final result = relativeTime('2000-01-01T00:00:00Z');
      expect(result, matches(RegExp(r'^\d+ months ago$')));
    });

    test('returns "X days ago" for a date some days in the past', () {
      final iso = DateTime.now().subtract(const Duration(days: 5)).toIso8601String();
      expect(relativeTime(iso), '5 days ago');
    });

    test('returns "X hours ago" for a date some hours in the past', () {
      final iso = DateTime.now().subtract(const Duration(hours: 3)).toIso8601String();
      expect(relativeTime(iso), '3 hours ago');
    });

    test('returns "Just now" for a date a few seconds in the past', () {
      final iso = DateTime.now().subtract(const Duration(seconds: 1)).toIso8601String();
      expect(relativeTime(iso), 'Just now');
    });
  });
}
