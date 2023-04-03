import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BasicActivityPage extends StatefulWidget {
  const BasicActivityPage({super.key});

  @override
  State<BasicActivityPage> createState() => _BasicActivityPageState();
}

class _BasicActivityPageState extends State<BasicActivityPage> {
  bool _isFilterExpanded = true;
  bool _loading = false;
  bool _error = false;
  RangeValues _accessibilityRangeValue = const RangeValues(0, 100);
  RangeValues _priceRangeValue = const RangeValues(0, 100);
  double _participants = 1;
  Activity? _activity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Material(
                color: Colors.deepPurple.shade50,
                child: AnimatedSize(
                  alignment: Alignment.topCenter,
                  duration: const Duration(milliseconds: 300),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _isFilterExpanded = !_isFilterExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Text('Filter your activity', style: TextStyle(fontSize: 18)),
                              Expanded(child: Container()),
                              Icon(_isFilterExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                            ],
                          ),
                          if (_isFilterExpanded) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Container(
                                decoration:
                                    BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(10)),
                                height: 2,
                              ),
                            ),
                            const Text('Accessibility', style: TextStyle(fontSize: 16)),
                            RangeSlider(
                              values: _accessibilityRangeValue,
                              max: 100,
                              divisions: 5,
                              labels: RangeLabels(
                                getAccessibilityLabel(_accessibilityRangeValue.start),
                                getAccessibilityLabel(_accessibilityRangeValue.end),
                              ),
                              onChanged: (RangeValues values) {
                                setState(() {
                                  _accessibilityRangeValue = values;
                                });
                              },
                            ),
                            const Text('Price', style: TextStyle(fontSize: 16)),
                            const SizedBox(height: 5),
                            RangeSlider(
                              values: _priceRangeValue,
                              max: 100,
                              divisions: 5,
                              labels: RangeLabels(
                                getPriceLabel(_priceRangeValue.start),
                                getPriceLabel(_priceRangeValue.end),
                              ),
                              onChanged: (RangeValues values) {
                                setState(() {
                                  _priceRangeValue = values;
                                });
                              },
                            ),
                            const Text('Number of participants', style: TextStyle(fontSize: 16)),
                            Slider(
                              value: _participants,
                              min: 1,
                              max: 10,
                              divisions: 9,
                              label: _participants.round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  _participants = value;
                                });
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
              child: _loading
                  ? Center(child: Container(height: 60, width: 60, child: const CircularProgressIndicator()))
                  : _error
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Center(
                              child: Text(
                            'No activity found with the specified parameters',
                            style: TextStyle(fontSize: 20),
                            textAlign: TextAlign.center,
                          )),
                        )
                      : _activity == null
                          ? const Center(
                              child: Text(
                              'What will you do today ?',
                              style: TextStyle(fontSize: 20),
                            ))
                          : Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.deepPurple.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Center(
                                            child: Text(
                                          _activity!.label,
                                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                                        )),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Type',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            Text(_activity!.type, style: const TextStyle(fontSize: 18))
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Participants',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            Text(_activity!.participants.toString(),
                                                style: const TextStyle(fontSize: 18))
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Accessibility',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            Text(getAccessibilityLabel(_activity!.accessibility),
                                                style: const TextStyle(fontSize: 18))
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Price',
                                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                            Text(getPriceLabel(_activity!.price), style: const TextStyle(fontSize: 18))
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(60),
              child: Material(
                color: Colors.deepPurple,
                child: InkWell(
                  onTap: () async {
                    setState(() {
                      _loading = true;
                      _isFilterExpanded = false;
                    });
                    final priceSuffix =
                        '&minprice=${_priceRangeValue.start / 100}&maxprice=${_priceRangeValue.end / 100}';
                    final accessibilitySuffix =
                        '&minaccessibility=${_accessibilityRangeValue.start / 100}&maxaccessibility=${_accessibilityRangeValue.end / 100}';
                    var uri =
                        'https://www.boredapi.com/api/activity?participants=${_participants.toString()}$priceSuffix$accessibilitySuffix';
                    print(uri);
                    final url = Uri.parse(uri);
                    final response = await http.get(url);
                    setState(() {
                      final jsonDecode2 = jsonDecode(response.body);
                      _loading = false;
                      print(jsonDecode2);
                      try {
                        _activity = Activity.fromJson(jsonDecode2);
                        _error = false;
                      } catch (e) {
                        print(e.toString());
                        _error = true;
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: const Center(
                      child: Text(
                        'Search your activity',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String getAccessibilityLabel(double value) {
    if (value < 19) {
      return 'Very easy';
    }
    if (value < 39) {
      return 'Easy';
    }
    if (value < 59) {
      return 'Medium';
    }
    if (value < 79) {
      return 'Hard';
    }
    if (value < 99) {
      return 'Very hard';
    }
    return 'For experts';
  }

  String getPriceLabel(double value) {
    if (value < 19) {
      return 'Free';
    }
    if (value < 39) {
      return 'Cheap';
    }
    if (value < 59) {
      return 'Affordable';
    }
    if (value < 79) {
      return 'Medium';
    }
    if (value < 99) {
      return 'Expensive';
    }
    return 'Very expensive';
  }
}

class TypeItem {
  final String label;
  bool isSelected;

  TypeItem(this.label, this.isSelected);
}

class Activity {
  final String label;
  final String type;
  final int participants;
  final double price;
  final double accessibility;

  Activity({
    required this.label,
    required this.type,
    required this.participants,
    required this.price,
    required this.accessibility,
  });

  factory Activity.fromJson(dynamic json) {
    return Activity(
      label: json['activity'] as String,
      type: json['type'] as String,
      participants: (json['participants'] as num).toInt(),
      price: (json['price'] as num).toDouble() * 100,
      accessibility: (json['accessibility'] as num).toDouble() * 100,
    );
  }
}
