import 'package:flutter/material.dart';

class BatteryLevelWidget extends StatelessWidget {
  double batteryLevel;
  final double frameWidth;
  final double frameHeight;


  BatteryLevelWidget({
    required this.batteryLevel,
    required this.frameWidth,
    required this.frameHeight,
  });
  void setLevel(double lvl)
  {
    batteryLevel=lvl;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Battery frame image
        Container(
          width: frameWidth,
          height: frameHeight,
          child:   Image.asset(
            'assets/images/empty-battery.png',
            fit: BoxFit.fill,
          ),
        ),

        //Rectangle for battery level
        Positioned(
          left: 4,
          //bottom: 4,
          child: Container(
            margin: const EdgeInsets.only(top: 5),
            width: (frameWidth - 12) * batteryLevel,
            height: frameHeight-10 ,
            color:(batteryLevel>0.75)? Colors.green : (batteryLevel>0.40)?Colors.orange:Colors.red ,
          ),
        ),
      ],
    );
  }
}
