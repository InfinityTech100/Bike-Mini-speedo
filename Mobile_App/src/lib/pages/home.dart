import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lcd_led/lcd_led.dart';

// ignore: non_constant_identifier_names
PreferredSizeWidget _Urad3AppBar() {
  return AppBar(
    leading: IconButton(
      icon: SvgPicture.asset(
        'assets/icons/battery.svg',
        // You can adjust the size of the SVG icon as needed
        height: 35,
        width: 24,
        // ignore: deprecated_member_use
        color: Colors.white,
      ),
      onPressed: () {
        // Add your onPressed logic here
      },
    ),
    actions: [
      IconButton(
        icon: SvgPicture.asset(
          'assets/icons/settings.svg',
          // You can adjust the size of the SVG icon as needed
          height: 25,
          width: 24,
          // ignore: deprecated_member_use
          color: Colors.white,
        ),
        onPressed: () {
          // Add your onPressed logic here
        },
      ),
    ],
    title: SvgPicture.asset(
      'assets/icons/Circled menu.svg',
      // You can adjust the size of the SVG icon as needed
      height: 25,
      width: 24,
      // ignore: deprecated_member_use
      color: Colors.white,
    ),
    centerTitle: true,
    backgroundColor: Colors.grey[800],
  );
}

// ignore: non_constant_identifier_names
Widget _BikeWidget() {
  return Container(
    height: 50, // Adjust the height of the bar as needed
    color: const Color.fromARGB(
        255, 85, 183, 112), // Set the background color of the bar
    child: Center(
      child: SvgPicture.asset(
        'assets/icons/cycling.svg',
        height: 30,
        width: 35,
        // ignore: deprecated_member_use
        color: Colors.white, // Set the color of the icon
      ),
    ),
  );
}

Widget _spedometerWidget(int speed) {
  String n = speed.toString();
  return SizedBox(
    height: 50, // Adjust the height of the bar as needed
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Speed: ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 5), // Add spacing between text and LED digits
        SizedBox(
          width: 90,
          height: 90,
          child: LedDigits(
            backgroundColor: const Color.fromARGB(255, 82, 81, 81),
            onColor: Colors.white,
            string: n,
            numberOfLeds: n.length,
          ),
        ),
        const SizedBox(width: 5), // Add spacing between LED digits and units
        const Text(
          'km/h',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

Widget _leftSideWidget(double screenHeight, double screenWidth) {
  // Local variables to control button and icon colors
  Color nightButtonColor = Colors.grey;
  Color dayButtonColor = Colors.grey;
  Color offButtonColor = Colors.grey;
  Color iconColor = Colors.grey;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        height: screenHeight / 3,
        width: screenWidth / 2.5,
      ),
      const SizedBox(
        height: 25,
      ), // Adjust the space between the text and buttons
      TextButton(
        onPressed: () {
          // Add onPressed logic for the first button
          nightButtonColor = Colors.white;
        },
        child: Text(
          'NIGHT',
          style: TextStyle(
            color: nightButtonColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      TextButton(
        onPressed: () {
          // Add onPressed logic for the second button
          dayButtonColor = Colors.white;
        },
        child: Text(
          'DAY',
          style: TextStyle(
            color: dayButtonColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      TextButton(
        onPressed: () {
          // Add onPressed logic for the third button
          offButtonColor = Colors.white;
        },
        child: Text(
          'OFF',
          style: TextStyle(
            color: offButtonColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(
          height: 25), // Adjust the space between the buttons and the icon
      TextButton(
        onPressed: () {
          iconColor = Colors.green;
        },
        child: SvgPicture.asset(
          'assets/icons/flashlight.svg', // Replace 'your_icon.svg' with the path to your SVG icon
          height: 70, // Adjust the height of the icon as needed
          width: 10, // Adjust the width of the icon as needed
          color: iconColor,
        ),
      )
    ],
  );
}

Widget ledElement(
    double screenHeight, double screenWidth, Color color, String text) {
  double circleSize = screenWidth / 4.7; // Adjust as needed for the circle size
  return Row(
    children: [
      Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color, // Use the color parameter here
        ),
      ),
      const SizedBox(
          width: 15), // Adjust the space between the circle and the text
      Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ],
  );
}

Widget _rightSideWidget(double screenHeight, double screenWidth) {
  return Column(
    children: [
      SizedBox(
        height: screenHeight / 25,
      ),
      ledElement(screenHeight, screenWidth,
          const Color.fromARGB(255, 255, 0, 0), '61 - 90m'),
      const SizedBox(
        height: 30,
      ),
      ledElement(screenHeight, screenWidth,
          const Color.fromARGB(255, 255, 92, 0), '61 - 90m'),
      const SizedBox(
        height: 30,
      ),
      ledElement(screenHeight, screenWidth,
          const Color.fromARGB(255, 208, 222, 49), '61 - 90m'),
      const SizedBox(
        height: 30,
      ),
      ledElement(screenHeight, screenWidth,
          const Color.fromARGB(255, 20, 255, 0), '91 - 120m'),
      const SizedBox(
        height: 30,
      ),
      ledElement(screenHeight, screenWidth,
          const Color.fromARGB(255, 66, 171, 89), '    > 120 m'),
    ],
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Scaffold(
      appBar: _Urad3AppBar(),
      body: Column(
        children: [
          const SizedBox(height: 24),
          // bike widget
          _BikeWidget(),
          const SizedBox(
              height: 24), // Add spacing between the bar and the LED digits
          // 7 segment spedometer widget
          _spedometerWidget(88),
          Row(children: [
            _leftSideWidget(screenHeight, screenWidth),
            _rightSideWidget(screenHeight, screenWidth)
          ])
        ],
      ),
      backgroundColor: Colors.grey[800],
    );
  }
}
