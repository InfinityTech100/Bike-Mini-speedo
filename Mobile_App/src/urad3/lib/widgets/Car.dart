import 'package:flutter/material.dart';

class Car extends StatelessWidget {
  final double displacement;
  final bool visible;

  Car({required this.displacement, required this.visible});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: displacement),
        Stack(
          alignment: Alignment.center,
          children: [
            // Horizontal line (only visible when car is visible)
            if (visible)
              Container(
                height: 2,
                width: double.infinity,
                color: Colors.white,
              ),
            // Car image
            AnimatedOpacity(
              opacity: visible ? 1.0 : 0.0,
              duration: Duration(milliseconds: 500),
              child: Container(
                width: 80,
                height: 50,
                child: Image.asset('assets/images/car.png'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
