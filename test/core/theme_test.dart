import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/core/theme.dart';

void main() {
  group('color constants', () {
    test('kPrimary has expected ARGB value', () {
      expect(kPrimary, const Color(0xFF1B6B50));
      expect(kPrimary.toARGB32(), 0xFF1B6B50);
    });

    test('kAccent has expected ARGB value', () {
      expect(kAccent, const Color(0xFFE8A33D));
      expect(kAccent.toARGB32(), 0xFFE8A33D);
    });

    test('kSurface has expected ARGB value', () {
      expect(kSurface, const Color(0xFFF7F7F5));
      expect(kSurface.toARGB32(), 0xFFF7F7F5);
    });

    test('kDanger has expected ARGB value', () {
      expect(kDanger, const Color(0xFFC0392B));
      expect(kDanger.toARGB32(), 0xFFC0392B);
    });
  });

  group('buildAppTheme', () {
    late ThemeData theme;

    setUp(() {
      theme = buildAppTheme();
    });

    test('uses Material 3', () {
      expect(theme.useMaterial3, isTrue);
    });

    test('scaffoldBackgroundColor equals kSurface', () {
      expect(theme.scaffoldBackgroundColor, kSurface);
    });

    test('colorScheme is derived from kPrimary seed and is light', () {
      final expectedScheme = ColorScheme.fromSeed(seedColor: kPrimary);
      expect(theme.colorScheme.primary, expectedScheme.primary);
      expect(theme.colorScheme.brightness, Brightness.light);
    });

    group('appBarTheme', () {
      test('backgroundColor equals kPrimary', () {
        expect(theme.appBarTheme.backgroundColor, kPrimary);
      });

      test('foregroundColor equals Colors.white', () {
        expect(theme.appBarTheme.foregroundColor, Colors.white);
      });

      test('elevation equals 0', () {
        expect(theme.appBarTheme.elevation, 0);
      });
    });

    group('cardTheme', () {
      test('elevation equals 2', () {
        expect(theme.cardTheme.elevation, 2);
      });

      test('shape is a RoundedRectangleBorder with borderRadius 12', () {
        final shape = theme.cardTheme.shape;
        expect(shape, isA<RoundedRectangleBorder>());
        final roundedShape = shape as RoundedRectangleBorder;
        expect(
          roundedShape.borderRadius,
          BorderRadius.circular(12),
        );
      });
    });

    group('elevatedButtonTheme', () {
      test('backgroundColor resolves to kPrimary for default state', () {
        final style = theme.elevatedButtonTheme.style;
        expect(style, isNotNull);
        final backgroundColor = style!.backgroundColor?.resolve(<WidgetState>{});
        expect(backgroundColor, kPrimary);
      });

      test('foregroundColor resolves to Colors.white for default state', () {
        final style = theme.elevatedButtonTheme.style;
        expect(style, isNotNull);
        final foregroundColor = style!.foregroundColor?.resolve(<WidgetState>{});
        expect(foregroundColor, Colors.white);
      });
    });

    group('bottomNavigationBarTheme', () {
      test('selectedItemColor equals kPrimary', () {
        expect(theme.bottomNavigationBarTheme.selectedItemColor, kPrimary);
      });

      test('type equals BottomNavigationBarType.fixed', () {
        expect(
          theme.bottomNavigationBarTheme.type,
          BottomNavigationBarType.fixed,
        );
      });
    });
  });
}
