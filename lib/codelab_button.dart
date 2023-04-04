import 'package:flutter/material.dart';

class CodelabButton extends StatelessWidget {
  final void Function() onTap;
  final String label;

  const CodelabButton({
    super.key,
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(60),
      child: Material(
        color: Colors.deepPurple,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
