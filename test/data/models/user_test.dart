import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/data/models/user.dart';

void main() {
  group('AppUser.fromJson', () {
    test('maps all fields correctly when phone and avatarUrl are present', () {
      final json = {
        'id': 'user-1',
        'email': 'somchai@example.com',
        'full_name': 'Somchai Prasert',
        'phone': '0812345678',
        'avatar_url': 'https://example.com/avatar.png',
        'member_since': '2024-01-15',
      };

      final user = AppUser.fromJson(json);

      expect(user.id, 'user-1');
      expect(user.email, 'somchai@example.com');
      expect(user.fullName, 'Somchai Prasert');
      expect(user.phone, '0812345678');
      expect(user.avatarUrl, 'https://example.com/avatar.png');
      expect(user.memberSince, '2024-01-15');
    });

    test('handles null phone and avatarUrl', () {
      final json = {
        'id': 'user-2',
        'email': 'anong@example.com',
        'full_name': 'Anong Suksawat',
        'phone': null,
        'avatar_url': null,
        'member_since': '2023-06-01',
      };

      final user = AppUser.fromJson(json);

      expect(user.id, 'user-2');
      expect(user.email, 'anong@example.com');
      expect(user.fullName, 'Anong Suksawat');
      expect(user.phone, isNull);
      expect(user.avatarUrl, isNull);
      expect(user.memberSince, '2023-06-01');
    });

    test('handles absent phone and avatarUrl keys', () {
      final json = {
        'id': 'user-3',
        'email': 'cher@example.com',
        'full_name': 'Cher',
        'member_since': '2022-03-10',
      };

      final user = AppUser.fromJson(json);

      expect(user.id, 'user-3');
      expect(user.email, 'cher@example.com');
      expect(user.fullName, 'Cher');
      expect(user.phone, isNull);
      expect(user.avatarUrl, isNull);
      expect(user.memberSince, '2022-03-10');
    });
  });

  group('AppUser.toJson', () {
    test('round-trips correctly with all fields present', () {
      final original = AppUser(
        id: 'user-1',
        email: 'somchai@example.com',
        fullName: 'Somchai Prasert',
        phone: '0812345678',
        avatarUrl: 'https://example.com/avatar.png',
        memberSince: '2024-01-15',
      );

      final rebuilt = AppUser.fromJson(original.toJson());

      expect(rebuilt.id, original.id);
      expect(rebuilt.email, original.email);
      expect(rebuilt.fullName, original.fullName);
      expect(rebuilt.phone, original.phone);
      expect(rebuilt.avatarUrl, original.avatarUrl);
      expect(rebuilt.memberSince, original.memberSince);
    });

    test('round-trips correctly with null phone and avatarUrl', () {
      final original = AppUser(
        id: 'user-2',
        email: 'anong@example.com',
        fullName: 'Anong Suksawat',
        memberSince: '2023-06-01',
      );

      final rebuilt = AppUser.fromJson(original.toJson());

      expect(rebuilt.id, original.id);
      expect(rebuilt.email, original.email);
      expect(rebuilt.fullName, original.fullName);
      expect(rebuilt.phone, isNull);
      expect(rebuilt.avatarUrl, isNull);
      expect(rebuilt.memberSince, original.memberSince);
    });
  });

  group('AppUser.initials', () {
    test('returns first letter uppercased for a single-word name', () {
      final user = AppUser(
        id: 'user-1',
        email: 'cher@example.com',
        fullName: 'Cher',
        memberSince: '2022-03-10',
      );

      expect(user.initials, 'C');
    });

    test('returns first letters of first two words for a two-word name', () {
      final user = AppUser(
        id: 'user-2',
        email: 'somchai@example.com',
        fullName: 'Somchai P.',
        memberSince: '2024-01-15',
      );

      expect(user.initials, 'SP');
    });

    test('uses only the first two words for a longer multi-word name', () {
      final user = AppUser(
        id: 'user-3',
        email: 'anong@example.com',
        fullName: 'Anong Suksawat Junior',
        memberSince: '2023-06-01',
      );

      expect(user.initials, 'AS');
    });
  });
}
