import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/data/models/news_item.dart';

void main() {
  group('NewsItem.fromJson', () {
    test('maps all fields from a full JSON map, including snake_case keys',
        () {
      final json = <String, dynamic>{
        'id': 'n-001',
        'title': 'Bangkok condo prices flatten in Q2',
        'summary': 'Average asking prices moved less than 1% quarter on '
            'quarter.',
        'body': 'After two years of steady growth, prices have flattened.',
        'category': 'Market',
        'image_url': 'https://images.housefinder.local/n-001.jpg',
        'published_at': '2026-07-28T08:00:00Z',
        'is_promotion': true,
        'promo_code': 'FIRSTVIEW',
        'discount_percent': 100,
      };

      final item = NewsItem.fromJson(json);

      expect(item.id, 'n-001');
      expect(item.title, 'Bangkok condo prices flatten in Q2');
      expect(
        item.summary,
        'Average asking prices moved less than 1% quarter on quarter.',
      );
      expect(item.body, 'After two years of steady growth, prices have '
          'flattened.');
      expect(item.category, 'Market');
      expect(item.imageUrl, 'https://images.housefinder.local/n-001.jpg');
      expect(item.publishedAt, '2026-07-28T08:00:00Z');
      expect(item.isPromotion, true);
      expect(item.promoCode, 'FIRSTVIEW');
      expect(item.discountPercent, 100);
    });

    test('parses promoCode and discountPercent as null when omitted', () {
      final json = <String, dynamic>{
        'id': 'n-003',
        'title': 'New Pink Line stations open next month',
        'summary': 'Four additional stations will open next month.',
        'body': 'The extension adds four stations.',
        'category': 'Transport',
        'image_url': 'https://images.housefinder.local/n-003.jpg',
        'published_at': '2026-07-21T09:30:00Z',
        'is_promotion': false,
        // promo_code and discount_percent intentionally omitted.
      };

      expect(() => NewsItem.fromJson(json), returnsNormally);

      final item = NewsItem.fromJson(json);
      expect(item.promoCode, isNull);
      expect(item.discountPercent, isNull);
      expect(item.isPromotion, false);
    });

    test('parses promoCode and discountPercent as null when explicitly null',
        () {
      final json = <String, dynamic>{
        'id': 'n-004',
        'title': 'Title',
        'summary': 'Summary',
        'body': 'Body',
        'category': 'Category',
        'image_url': 'https://images.housefinder.local/n-004.jpg',
        'published_at': '2026-07-21T09:30:00Z',
        'is_promotion': false,
        'promo_code': null,
        'discount_percent': null,
      };

      final item = NewsItem.fromJson(json);
      expect(item.promoCode, isNull);
      expect(item.discountPercent, isNull);
    });
  });

  group('NewsItem constructor', () {
    test('assigns all required fields directly', () {
      final item = NewsItem(
        id: 'n-100',
        title: 'Title',
        summary: 'Summary',
        body: 'Body',
        category: 'Category',
        imageUrl: 'https://example.com/image.jpg',
        publishedAt: '2026-01-01T00:00:00Z',
        isPromotion: true,
        promoCode: 'SAVE10',
        discountPercent: 10,
      );

      expect(item.id, 'n-100');
      expect(item.title, 'Title');
      expect(item.summary, 'Summary');
      expect(item.body, 'Body');
      expect(item.category, 'Category');
      expect(item.imageUrl, 'https://example.com/image.jpg');
      expect(item.publishedAt, '2026-01-01T00:00:00Z');
      expect(item.isPromotion, true);
      expect(item.promoCode, 'SAVE10');
      expect(item.discountPercent, 10);
    });

    test('promoCode and discountPercent default to null when omitted', () {
      final item = NewsItem(
        id: 'n-101',
        title: 'Title',
        summary: 'Summary',
        body: 'Body',
        category: 'Category',
        imageUrl: 'https://example.com/image.jpg',
        publishedAt: '2026-01-01T00:00:00Z',
        isPromotion: false,
      );

      expect(item.promoCode, isNull);
      expect(item.discountPercent, isNull);
    });
  });

  group('NewsItem.fromJson against real fixture', () {
    test('parses the first entry of assets/fixtures/news.json without '
        'throwing', () {
      final file = File('assets/fixtures/news.json');
      final contents = file.readAsStringSync();
      final decoded = jsonDecode(contents) as List<dynamic>;

      expect(decoded, isNotEmpty);

      final firstJson = decoded.first as Map<String, dynamic>;

      late NewsItem item;
      expect(() => item = NewsItem.fromJson(firstJson), returnsNormally);
      expect(item.id, isNotEmpty);
    });
  });
}
