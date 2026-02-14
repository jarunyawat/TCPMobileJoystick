import 'package:flutter/material.dart';

class ArrowButton extends StatefulWidget {
  final IconData icon;
  final double angularVelocity;
  final VoidCallback startHold;
  final VoidCallback stopHold;

  const ArrowButton({
    super.key,
    required this.icon,
    required this.angularVelocity,
    required this.startHold,
    required this.stopHold,
  });

  @override
  State<ArrowButton> createState() => _ArrowButtonState();
}

class _ArrowButtonState extends State<ArrowButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => widget.startHold(),
      onTapUp: (_) => widget.stopHold(),
      onTapCancel: () => widget.stopHold(),

      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 40, color: Colors.white),

            const SizedBox(height: 6),

            Text(
              widget.angularVelocity.toStringAsFixed(2),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TurnButtons extends StatelessWidget {
  final double angularVelocity;
  final VoidCallback onLeft;
  final VoidCallback onLeftEnd;
  final VoidCallback onRight;
  final VoidCallback onRightEnd;

  const TurnButtons({
    super.key,
    required this.angularVelocity,
    required this.onLeft,
    required this.onLeftEnd,
    required this.onRight,
    required this.onRightEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        /// LEFT ARROW
        ArrowButton(
          icon: Icons.arrow_left,
          angularVelocity: angularVelocity,
          startHold: onLeft,
          stopHold: onLeftEnd,
        ),

        const SizedBox(width: 40),

        /// RIGHT ARROW
        ArrowButton(
          icon: Icons.arrow_right,
          angularVelocity: -angularVelocity,
          startHold: onRight,
          stopHold: onRightEnd,
        ),
      ],
    );
  }
}
