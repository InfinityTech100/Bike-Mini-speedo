import 'package:flutter/material.dart';

class BikeIndicator extends StatelessWidget {
  Color stateColor=Colors.green;
  final String state;
  BikeIndicator({Key? key, required this.state}) : super(key: key);
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
    return SizedBox(
      width: double.infinity, // Full width of the screen
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () {
          // Button press logic
        },
        icon: const Icon(Icons.directions_bike,size: 40),
        label: const Text(''),
        style: ElevatedButton.styleFrom(
        shadowColor: (state=="danger")?Colors.red:(state=="warning")?Colors.orange:Colors.green ,
        ),
      ),
    );
  }
}
