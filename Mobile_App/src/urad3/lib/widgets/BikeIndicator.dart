import 'package:flutter/material.dart';

enum BikeIndicatorState { safe, danger, warning }

class BikeIndicator extends StatelessWidget {
  Color stateColor = Colors.green;
  BikeIndicatorState status;
  BikeIndicator({required this.status});
  void setState() {
    if (status == BikeIndicatorState.danger) {
      stateColor = Colors.red;
    } else if (status == BikeIndicatorState.warning) {
      stateColor = Colors.orange;
    } else {
      stateColor = Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    setState();
    return SizedBox(
      width: double.infinity, // Full width of the screen
      height: 55,
      child: Container(
        width: double.infinity,
        height: 80,
        color: stateColor,
        child: const Center(
          child: Icon(Icons.directions_bike, size: 40),
        ),
      ),
    );
  }
}

/* 'package:flutter/material.dart';

class BikeIndicator extends StatefulWidget {
   String state;

  BikeIndicator({ required this.state}) ;

  @override
  _BikeIndicatorState createState() => _BikeIndicatorState();
}

class _BikeIndicatorState extends State<BikeIndicator> {
  late Color stateColor;

  @override
  void initState() {
    super.initState();
    setStateColor();
  }

  void setStateColor() {
    if (widget.state == "danger") {
      stateColor = Colors.red;
    } else if (widget.state == "warning") {
      stateColor = Colors.orange;
    } else {
      stateColor = Colors.green;
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
        icon: const Icon(Icons.directions_bike, size: 40),
        label: const Text(''),
        style: ElevatedButton.styleFrom(
          shadowColor: stateColor,
        ),
      ),
    );
  }
}

 */