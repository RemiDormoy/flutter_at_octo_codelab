import 'package:codelab_flutter_at_octo/activity.dart';
import 'package:codelab_flutter_at_octo/codelab_actions.dart';
import 'package:codelab_flutter_at_octo/codelab_button.dart';
import 'package:codelab_flutter_at_octo/codelab_colors.dart';
import 'package:codelab_flutter_at_octo/codelab_state.dart';
import 'package:codelab_flutter_at_octo/codelab_view_model.dart';
import 'package:codelab_flutter_at_octo/codelabs_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';

class BasicActivityPage extends StatefulWidget {
  const BasicActivityPage({super.key});

  @override
  State<BasicActivityPage> createState() => _BasicActivityPageState();
}

class _BasicActivityPageState extends State<BasicActivityPage> {
  bool _isFilterExpanded = true;
  RangeValues _accessibilityRangeValue = const RangeValues(0, 100);
  RangeValues _priceRangeValue = const RangeValues(0, 100);
  double _participants = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StoreConnector<CodelabState, CodelabViewModel>(
        converter: (store) => CodelabViewModel.fromStore(store),
        distinct: true,
        builder: (context, vm) {
          return Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 60, left: 20, right: 20),
                child: _Filters(
                  onTap: () {
                    setState(() {
                      _isFilterExpanded = !_isFilterExpanded;
                    });
                  },
                  onAccessibilityChanged: (RangeValues values) {
                    setState(() {
                      _accessibilityRangeValue = values;
                    });
                  },
                  onPriceChanged: (RangeValues values) {
                    setState(() {
                      _priceRangeValue = values;
                    });
                  },
                  onParticipantsChanged: (double value) {
                    setState(() {
                      _participants = value;
                    });
                  },
                  isFilterExpanded: _isFilterExpanded,
                  accessibilityRangeValue: _accessibilityRangeValue,
                  priceRangeValue: _priceRangeValue,
                  participants: _participants,
                ),
              ),
              Expanded(
                child: _Content(
                  loading: vm.loading,
                  error: vm.error,
                  activity: vm.activity,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: CodelabButton(
                  onTap: () {
                    setState(() {
                      _isFilterExpanded = false;
                    });
                    StoreProvider.of<CodelabState>(context).dispatch(FindActivityAction(
                      currentParticipantsFilter: _participants.toInt(),
                      currentAccessibilityFilter: _accessibilityRangeValue,
                      currentPriceFilter: _priceRangeValue,
                    ));
                  },
                  label: 'Search your activity',
                ),
              ),
            ],
          );
        }
      ),
    );
  }
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

String _getPriceLabel(double value) {
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

class TypeItem {
  final String label;
  bool isSelected;

  TypeItem(this.label, this.isSelected);
}

class _Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        height: 60,
        width: 60,
        child: CircularProgressIndicator(),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: Center(
          child: Text(
        'No activity found with the specified parameters',
        style: CodelabTextStyles.text20_black,
        textAlign: TextAlign.center,
      )),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text(
      'What will you do today ?',
      style: CodelabTextStyles.text20_black,
    ));
  }
}

class _Content extends StatelessWidget {
  final bool error;
  final bool loading;
  final Activity? activity;

  const _Content({
    required this.error,
    required this.loading,
    required this.activity,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) return _Loading();
    if (error) return _Error();
    if (activity == null) return _Empty();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: CodelabColors.primaryLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                    child: Text(
                  activity!.label,
                  style: CodelabTextStyles.text24_bold_black,
                )),
                _ContentRow('Type', activity!.type),
                _ContentRow('Participants', activity!.participants.toString()),
                _ContentRow('Accessibility', getAccessibilityLabel(activity!.accessibility)),
                _ContentRow('Price', _getPriceLabel(activity!.price)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContentRow extends StatelessWidget {
  final String title;
  final String value;

  const _ContentRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: CodelabTextStyles.text18_bold_black),
          Text(value, style: CodelabTextStyles.text18_black)
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  final void Function() onTap;
  final void Function(RangeValues) onAccessibilityChanged;
  final void Function(RangeValues) onPriceChanged;
  final void Function(double) onParticipantsChanged;
  final bool isFilterExpanded;
  final RangeValues accessibilityRangeValue;
  final RangeValues priceRangeValue;
  final double participants;

  const _Filters({
    required this.onTap,
    required this.onAccessibilityChanged,
    required this.onPriceChanged,
    required this.onParticipantsChanged,
    required this.isFilterExpanded,
    required this.accessibilityRangeValue,
    required this.priceRangeValue,
    required this.participants,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Material(
        color: CodelabColors.primaryLight,
        child: AnimatedSize(
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 300),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text('Filter your activity', style: CodelabTextStyles.text18_black),
                      Expanded(child: Container()),
                      Icon(isFilterExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                    ],
                  ),
                  if (isFilterExpanded) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Container(
                        decoration:
                            BoxDecoration(color: CodelabColors.primary, borderRadius: BorderRadius.circular(10)),
                        height: 2,
                      ),
                    ),
                    const Text('Accessibility', style: CodelabTextStyles.text16_black),
                    RangeSlider(
                      values: accessibilityRangeValue,
                      max: 100,
                      divisions: 5,
                      labels: RangeLabels(
                        getAccessibilityLabel(accessibilityRangeValue.start),
                        getAccessibilityLabel(accessibilityRangeValue.end),
                      ),
                      onChanged: onAccessibilityChanged,
                    ),
                    const Text('Price', style: CodelabTextStyles.text16_black),
                    const SizedBox(height: 5),
                    RangeSlider(
                      values: priceRangeValue,
                      max: 100,
                      divisions: 5,
                      labels: RangeLabels(
                        _getPriceLabel(priceRangeValue.start),
                        _getPriceLabel(priceRangeValue.end),
                      ),
                      onChanged: onPriceChanged,
                    ),
                    const Text('Number of participants', style: CodelabTextStyles.text16_black),
                    Slider(
                      value: participants,
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: participants.round().toString(),
                      onChanged: onParticipantsChanged,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
