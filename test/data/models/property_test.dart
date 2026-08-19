import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/data/models/property.dart';

Map<String, dynamic> buildJson({
  String id = 'p-001',
  String title = 'Modern 3-Bed House with Garden',
  String type = 'house',
  int price = 8900000,
  int bedrooms = 3,
  int bathrooms = 3,
  Object areaSqm = 210.5,
  String address = '42/7 Soi Ekkamai 12',
  String district = 'Watthana',
  String imageUrl = 'https://images.housefinder.local/p-001.jpg',
  bool isFeatured = true,
  String listedAt = '2026-07-14T09:30:00Z',
  String agentName = 'Nuch Sirikul',
  String agentPhone = '+66 81 234 5678',
  String description = 'A bright detached house on a quiet soi.',
  List<String> amenities = const ['Garden', 'Parking', 'Security'],
}) {
  return {
    'id': id,
    'title': title,
    'type': type,
    'price': price,
    'bedrooms': bedrooms,
    'bathrooms': bathrooms,
    'area_sqm': areaSqm,
    'address': address,
    'district': district,
    'image_url': imageUrl,
    'is_featured': isFeatured,
    'listed_at': listedAt,
    'agent': {'name': agentName, 'phone': agentPhone},
    'description': description,
    'amenities': amenities,
  };
}

void main() {
  group('Property.fromJson', () {
    test('extracts all fields correctly, including nested agent', () {
      final json = buildJson();

      final property = Property.fromJson(json);

      expect(property.id, 'p-001');
      expect(property.title, 'Modern 3-Bed House with Garden');
      expect(property.type, 'house');
      expect(property.price, 8900000);
      expect(property.bedrooms, 3);
      expect(property.bathrooms, 3);
      expect(property.areaSqm, 210.5);
      expect(property.address, '42/7 Soi Ekkamai 12');
      expect(property.district, 'Watthana');
      expect(property.imageUrl, 'https://images.housefinder.local/p-001.jpg');
      expect(property.isFeatured, true);
      expect(property.listedAt, '2026-07-14T09:30:00Z');
      expect(property.agentName, 'Nuch Sirikul');
      expect(property.agentPhone, '+66 81 234 5678');
      expect(property.description, 'A bright detached house on a quiet soi.');
      expect(property.amenities, ['Garden', 'Parking', 'Security']);
    });

    test('areaSqm is a double even when JSON value is an int', () {
      final json = buildJson(areaSqm: 88);

      final property = Property.fromJson(json);

      expect(property.areaSqm, isA<double>());
      expect(property.areaSqm, 88.0);
    });
  });

  group('Property.toJson', () {
    test('round-trips through fromJson with equivalent field values', () {
      final original = Property.fromJson(buildJson(
        id: 'p-002',
        title: 'Riverside Condo, High Floor',
        type: 'condo',
        price: 12500000,
        bedrooms: 2,
        bathrooms: 2,
        areaSqm: 88.0,
        address: 'Charoen Nakhon 13, 34th floor',
        district: 'Khlong San',
        imageUrl: 'https://images.housefinder.local/p-002.jpg',
        isFeatured: false,
        listedAt: '2026-07-20T14:00:00Z',
        agentName: 'Peerapat Wong',
        agentPhone: '+66 89 111 2233',
        description: 'Unobstructed river views from the 34th floor.',
        amenities: const ['Pool', 'Gym', 'Co-working', 'River view'],
      ));

      final roundTripped = Property.fromJson(original.toJson());

      expect(roundTripped.id, original.id);
      expect(roundTripped.title, original.title);
      expect(roundTripped.type, original.type);
      expect(roundTripped.price, original.price);
      expect(roundTripped.bedrooms, original.bedrooms);
      expect(roundTripped.bathrooms, original.bathrooms);
      expect(roundTripped.areaSqm, original.areaSqm);
      expect(roundTripped.address, original.address);
      expect(roundTripped.district, original.district);
      expect(roundTripped.imageUrl, original.imageUrl);
      expect(roundTripped.isFeatured, original.isFeatured);
      expect(roundTripped.listedAt, original.listedAt);
      expect(roundTripped.agentName, original.agentName);
      expect(roundTripped.agentPhone, original.agentPhone);
      expect(roundTripped.description, original.description);
      expect(roundTripped.amenities, original.amenities);
    });

    test('nests agentName/agentPhone back under an "agent" map', () {
      final property = Property.fromJson(buildJson());

      final json = property.toJson();

      expect(json['agent'], isA<Map<String, dynamic>>());
      expect(json['agent'], {
        'name': 'Nuch Sirikul',
        'phone': '+66 81 234 5678',
      });
      expect(json.containsKey('agentName'), isFalse);
      expect(json.containsKey('agentPhone'), isFalse);
    });
  });

  group('Property.typeEnum', () {
    test("'house' maps to PropertyType.house", () {
      final property = Property.fromJson(buildJson(type: 'house'));
      expect(property.typeEnum, PropertyType.house);
    });

    test("'condo' maps to PropertyType.condo", () {
      final property = Property.fromJson(buildJson(type: 'condo'));
      expect(property.typeEnum, PropertyType.condo);
    });

    test("'apartment' maps to PropertyType.apartment", () {
      final property = Property.fromJson(buildJson(type: 'apartment'));
      expect(property.typeEnum, PropertyType.apartment);
    });

    test('an unrecognized type string falls back to PropertyType.apartment',
        () {
      final property = Property.fromJson(buildJson(type: 'townhouse'));
      expect(property.typeEnum, PropertyType.apartment);
    });
  });

  group('Property.pricePerSqm', () {
    test('computes price divided by areaSqm', () {
      final property = Property.fromJson(buildJson(
        price: 1000000,
        areaSqm: 100.0,
      ));

      expect(property.pricePerSqm, closeTo(10000.0, 0.0001));
    });

    test('computes correctly for non-integer results', () {
      final property = Property.fromJson(buildJson(
        price: 8900000,
        areaSqm: 210.5,
      ));

      expect(property.pricePerSqm, closeTo(42280.2851, 0.001));
    });
  });

  group('properties.json fixture', () {
    test('every entry parses into a valid Property with a positive price',
        () {
      final file = File('assets/fixtures/properties.json');
      final raw = file.readAsStringSync();
      final decoded = jsonDecode(raw) as List<dynamic>;

      final properties = decoded
          .map((entry) => Property.fromJson(entry as Map<String, dynamic>))
          .toList();

      expect(properties, isNotEmpty);
      for (final property in properties) {
        expect(property.price, greaterThan(0));
      }
    });
  });
}
