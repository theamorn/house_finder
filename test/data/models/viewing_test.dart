import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/data/models/viewing.dart';

void main() {
  Map<String, dynamic> buildJson({
    String id = 'v1',
    String propertyId = 'p1',
    String propertyTitle = 'Cozy Cottage',
    String propertyImageUrl = 'https://example.com/image.jpg',
    String scheduledAt = '2026-01-15T10:30:00',
    String status = 'pending',
    String agentName = 'Jane Doe',
    String agentPhone = '555-1234',
    String? notes = 'Bring keys',
  }) {
    return {
      'id': id,
      'property_id': propertyId,
      'property_title': propertyTitle,
      'property_image_url': propertyImageUrl,
      'scheduled_at': scheduledAt,
      'status': status,
      'agent_name': agentName,
      'agent_phone': agentPhone,
      'notes': notes,
    };
  }

  group('Viewing.fromJson', () {
    test('maps all snake_case fields to camelCase fields', () {
      final json = buildJson();

      final viewing = Viewing.fromJson(json);

      expect(viewing.id, 'v1');
      expect(viewing.propertyId, 'p1');
      expect(viewing.propertyTitle, 'Cozy Cottage');
      expect(viewing.propertyImageUrl, 'https://example.com/image.jpg');
      expect(viewing.scheduledAt, '2026-01-15T10:30:00');
      expect(viewing.status, 'pending');
      expect(viewing.agentName, 'Jane Doe');
      expect(viewing.agentPhone, '555-1234');
      expect(viewing.notes, 'Bring keys');
    });

    test('handles null notes', () {
      final json = buildJson(notes: null);

      final viewing = Viewing.fromJson(json);

      expect(viewing.notes, isNull);
    });
  });

  group('Viewing.toJson', () {
    test('round-trips through fromJson/toJson', () {
      final original = buildJson();

      final viewing = Viewing.fromJson(original);
      final result = viewing.toJson();

      expect(result, original);
    });

    test('round-trips with null notes', () {
      final original = buildJson(notes: null);

      final viewing = Viewing.fromJson(original);
      final result = viewing.toJson();

      expect(result, original);
      expect(result['notes'], isNull);
    });
  });

  group('Viewing.copyWith', () {
    late Viewing viewing;

    setUp(() {
      viewing = Viewing.fromJson(buildJson());
    });

    test('with no arguments returns equivalent field values', () {
      final copy = viewing.copyWith();

      expect(copy.id, viewing.id);
      expect(copy.propertyId, viewing.propertyId);
      expect(copy.propertyTitle, viewing.propertyTitle);
      expect(copy.propertyImageUrl, viewing.propertyImageUrl);
      expect(copy.scheduledAt, viewing.scheduledAt);
      expect(copy.status, viewing.status);
      expect(copy.agentName, viewing.agentName);
      expect(copy.agentPhone, viewing.agentPhone);
      expect(copy.notes, viewing.notes);
    });

    test('overrides only status when status is provided', () {
      final copy = viewing.copyWith(status: 'confirmed');

      expect(copy.status, 'confirmed');
      expect(copy.scheduledAt, viewing.scheduledAt);
      expect(copy.notes, viewing.notes);
      expect(copy.id, viewing.id);
      expect(copy.propertyId, viewing.propertyId);
      expect(copy.propertyTitle, viewing.propertyTitle);
      expect(copy.propertyImageUrl, viewing.propertyImageUrl);
      expect(copy.agentName, viewing.agentName);
      expect(copy.agentPhone, viewing.agentPhone);
    });

    test('overrides only scheduledAt when scheduledAt is provided', () {
      const newScheduledAt = '2027-05-20T09:00:00';

      final copy = viewing.copyWith(scheduledAt: newScheduledAt);

      expect(copy.scheduledAt, newScheduledAt);
      expect(copy.status, viewing.status);
      expect(copy.notes, viewing.notes);
      expect(copy.id, viewing.id);
      expect(copy.propertyId, viewing.propertyId);
      expect(copy.propertyTitle, viewing.propertyTitle);
      expect(copy.propertyImageUrl, viewing.propertyImageUrl);
      expect(copy.agentName, viewing.agentName);
      expect(copy.agentPhone, viewing.agentPhone);
    });

    test('overrides only notes when notes is provided', () {
      final copy = viewing.copyWith(notes: 'Updated notes');

      expect(copy.notes, 'Updated notes');
      expect(copy.status, viewing.status);
      expect(copy.scheduledAt, viewing.scheduledAt);
      expect(copy.id, viewing.id);
      expect(copy.propertyId, viewing.propertyId);
      expect(copy.propertyTitle, viewing.propertyTitle);
      expect(copy.propertyImageUrl, viewing.propertyImageUrl);
      expect(copy.agentName, viewing.agentName);
      expect(copy.agentPhone, viewing.agentPhone);
    });

    test(
      'passing null explicitly for notes does not clear existing notes '
      '(existing behavior: notes ?? this.notes)',
      () {
        final copy = viewing.copyWith(notes: null);

        expect(copy.notes, viewing.notes);
        expect(copy.notes, isNotNull);
      },
    );
  });

  group('Viewing.scheduledDate', () {
    test('parses the ISO8601 scheduledAt string into a DateTime', () {
      final viewing = Viewing.fromJson(
        buildJson(scheduledAt: '2026-03-22T14:45:00'),
      );

      final date = viewing.scheduledDate;

      expect(date, isA<DateTime>());
      expect(date.year, 2026);
      expect(date.month, 3);
      expect(date.day, 22);
      expect(date.hour, 14);
      expect(date.minute, 45);
    });
  });

  group('Viewing.isUpcoming', () {
    test('is true when scheduledAt is far in the future', () {
      final futureIso = DateTime.now()
          .add(const Duration(days: 365))
          .toIso8601String();
      final viewing = Viewing.fromJson(buildJson(scheduledAt: futureIso));

      expect(viewing.isUpcoming, isTrue);
    });

    test('is false when scheduledAt is far in the past', () {
      final pastIso = DateTime.now()
          .subtract(const Duration(days: 365 * 26))
          .toIso8601String();
      final viewing = Viewing.fromJson(buildJson(scheduledAt: pastIso));

      expect(viewing.isUpcoming, isFalse);
    });
  });
}
