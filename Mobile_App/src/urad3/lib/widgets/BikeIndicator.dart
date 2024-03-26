import 'package:flutter/material.dart';

// ignore: must_be_immutable
class BikeIndicator extends StatelessWidget {
  Color stateColor=Colors.green;
  final String state;
  BikeIndicator({required this.state});
  void setState()
  {
     if(state=="danger")
     {

         stateColor=Colors.red;
     }
     else if(state=="warning")
     {
         stateColor=Colors.orange;
     }
     else
     {
         stateColor=Colors.green;
     }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // Full width of the screen
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          // Button press logic
        },
        icon: Icon(Icons.directions_bike,size: 40),
        label: Text(''),
        style: ElevatedButton.styleFrom(
          backgroundColor: (state=="danger")?Colors.red:(state=="warning")?Colors.orange:Colors.green ,
        ),
      ),
    );
  }
}
