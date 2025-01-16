import 'package:flutter/material.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;

  const StepIndicator({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircle(0),
        _buildLine(1),
        _buildCircle(1),
        _buildLine(2),
        _buildCircle(2),
      ],
    );
  }

  Widget _buildCircle(int step) {
    bool isCompleted = currentStep >= step;
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? Colors.teal : Colors.white,
        border: Border.all(
            color: isCompleted ? Colors.teal : Colors.grey, width: 2),
      ),
    );
  }

  Widget _buildLine(int step) {
    return Expanded(
      child: Container(
        height: 2,
        color: currentStep >= step ? Colors.teal : Colors.grey[300],
      ),
    );
  }
}
