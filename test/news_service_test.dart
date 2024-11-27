// The only test in this project.
//
// Written during the "we should have tests" week in 2024. Nobody added a
// second one. The news test fails now and then because MockApi.fetchNews()
// throws on roughly one call in four - it has been failing in CI on and off
// ever since and everyone just re-runs the job.
//
// TODO: fix or delete. -- Nan

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:house_finder/core/utils/formatters.dart';
import 'package:house_finder/data/mock_api.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('formatters', () {
    test('formats millions with two decimals', () {
      expect(formatPrice(8900000), '฿8.90M');
    });

    test('formats thousands', () {
      expect(formatPrice(450000), '฿450K');
    });
  });

  group('MockApi', () {
    test('fetchNews returns the full feed', () async {
      final api = MockApi();
      final items = await api.fetchNews();
      expect(items.length, 7);
    });
  });
}
