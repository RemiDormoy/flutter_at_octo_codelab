import 'dart:convert';

import 'package:codelab_flutter_at_octo/activity.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ActivityRepository {
  final Client httpClient;

  ActivityRepository(this.httpClient);

  /// Will return null in case of error
  Future<Activity?> getActivity(RangeValues priceRangeValue, RangeValues accessibilityRangeValue, int participants) async {
    try {
      final priceSuffix = '&minprice=${priceRangeValue.start / 100}&maxprice=${priceRangeValue.end / 100}';
      final accessibilitySuffix =
          '&minaccessibility=${accessibilityRangeValue.start / 100}&maxaccessibility=${accessibilityRangeValue.end /
          100}';
      var uri =
          'https://www.boredapi.com/api/activity?participants=${participants
          .toString()}$priceSuffix$accessibilitySuffix';
      final url = Uri.parse(uri);
      final response = await httpClient.get(url);
      final json = jsonDecode(response.body);
      return Activity(
        label: json['activity'] as String,
        type: json['type'] as String,
        participants: (json['participants'] as num).toInt(),
        price: (json['price'] as num).toDouble() * 100,
        accessibility: (json['accessibility'] as num).toDouble() * 100,
      );
    } catch (e) {
      return null;
    }
  }
}
