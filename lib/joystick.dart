import 'package:flutter/material.dart';

class Joystick extends StatefulWidget {
  final double size;
  final double linearVelocity;
  final Function(Offset) onChanged;
  final VoidCallback onHoldStart;
  final VoidCallback onHoldEnd;

  const Joystick({
    super.key,
    required this.size,
    required this.onChanged,
    required this.onHoldStart,
    required this.onHoldEnd,
    required this.linearVelocity,
  });

  @override
  State<Joystick> createState() => _JoystickState();
}

class _JoystickState extends State<Joystick> {
  Offset stickOffset = Offset.zero;

  late double radius;
  late double stickRadius;

  @override
  void initState() {
    super.initState();
    radius = widget.size / 2;
    stickRadius = widget.size / 6;
  }

  void updateStick(Offset localPosition) {
    Offset center = Offset(radius, radius);
    Offset delta = localPosition - center;

    // limit stick inside circle
    if (delta.distance > radius - stickRadius) {
      delta = Offset.fromDirection(delta.direction, radius - stickRadius);
    }

    setState(() {
      stickOffset = delta;
    });

    // normalized output (-1 → 1)
    widget.onChanged(
      Offset(
        delta.dx / (radius - stickRadius),
        delta.dy / (radius - stickRadius),
      ),
    );
  }

  void resetStick() {
    setState(() {
      stickOffset = Offset.zero;
    });

    widget.onChanged(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size + 80,
      height: widget.size + 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          /// ===== TOP TEXT =====
          Positioned(
            top: 0,
            child: Text(
              widget.linearVelocity.toStringAsFixed(2),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          /// ===== BOTTOM TEXT =====
          Positioned(
            bottom: 0,
            child: Text(
              "-${widget.linearVelocity.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 14),
            ),
          ),

          /// ===== LEFT TEXT =====
          Positioned(
            left: 0,
            child: Text(
              widget.linearVelocity.toStringAsFixed(2),
              style: const TextStyle(fontSize: 14),
            ),
          ),

          /// ===== RIGHT TEXT =====
          Positioned(
            right: 0,
            child: Text(
              "-${widget.linearVelocity.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          GestureDetector(
            onPanDown: (d) {
              widget.onHoldStart();
              updateStick(d.localPosition);
            },
            onPanUpdate: (d) {
              updateStick(d.localPosition);
            },
            onPanEnd: (d) {
              widget.onHoldEnd();
              resetStick();
            },

            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: radius + stickOffset.dx - stickRadius,
                    top: radius + stickOffset.dy - stickRadius,
                    child: Container(
                      width: stickRadius * 2,
                      height: stickRadius * 2,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
