import 'package:flutter/material.dart';

class BTN extends StatelessWidget {
  final IconData icon;
  final Function onPressed;
  final double size;

  BTN({required this.icon, required this.onPressed, required this.size});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          onPressed();
        },
        child: Container(
          width: size * 2.5,
          height: size * 2.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black,
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: size*0.7,
          ),
        ),
      ),
    );
  }
}
