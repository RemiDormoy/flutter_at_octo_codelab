import 'package:codelab_flutter_at_octo/activity.dart';
import 'package:codelab_flutter_at_octo/activity_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';

main() {
  test('Success case', () async {
    // Given
    String? path;
    final client = MockClient((request) async {
      path = request.url.toString();
      return Response(
        """
        {
          "activity": "Learn how to iceskate or rollerskate",
          "type": "recreational",
          "participants": 1,
          "price": 0.1,
          "link": "",
          "key": "5947957",
          "accessibility": 0.25
        }
        """,
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final repository = ActivityRepository(client);

    // When
    final result = await repository.getActivity(
      const RangeValues(0.3, 0.7),
      const RangeValues(0.2, 0.9),
      12,
    );

    // Then
    expect(path,
        "https://www.boredapi.com/api/activity?participants=12&minprice=0.003&maxprice=0.006999999999999999&minaccessibility=0.002&maxaccessibility=0.009000000000000001");
    expect(
      result,
      Activity(
        label: "Learn how to iceskate or rollerskate",
        type: "recreational",
        participants: 1,
        price: 10,
        accessibility: 25,
      ),
    );
  });

  test('Error case', () async {
    // Given
    final client = MockClient((request) async {
      return Response(
        """{"error": "Ceci est une erreur"}""",
        400,
        headers: {'content-type': 'application/json'},
      );
    });
    final repository = ActivityRepository(client);

    // When
    final result = await repository.getActivity(
      const RangeValues(0.3, 0.7),
      const RangeValues(0.2, 0.9),
      12,
    );

    // Then
    expect(result, null);
  });
}
