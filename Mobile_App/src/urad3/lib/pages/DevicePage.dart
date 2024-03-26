import 'package:flutter/material.dart';
import '../widgets/FullWidthBTN.dart';

class DevicePage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<DevicePage> {
  String version = " 1.0.1";



  Widget FooterButtons() {
    return Column(
      children: [
        FWBTN(
          icon: Icons.camera_alt,
          text: "camera",
          size: 24,
          onPressed: () => {print("hello")},
        ),
        const SizedBox(height: 20.0),
        FWBTN(
          icon: Icons.sd_card,
          text: "Storage",
          size: 24,
          onPressed: () => {print("help")},
        ),
        const SizedBox(height: 20.0),
        FWBTN(
          icon: Icons.update,
          text: "Software Updates",
          size: 24,
          onPressed: () => {print("help")},
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:const Text('Device Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Image.asset('assets/images/device.png'), // Replace 'assets/device.png' with the path to your image
          ),
        ),
            const SizedBox(height: 26.0),
            const Center(
              child: Column(
                children:  [
                 Text(
                    'Device Name',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  SizedBox(height: 5.0),
                  Text(
                    'Model Number',
                    style: TextStyle(
                        fontSize: 10.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70),
                  ),
                ],
              )
            ),
            const SizedBox(height: 16.0),

      const SizedBox(height: 26.0),

            FooterButtons()


          ],
        ),
      ),
    );
  }
}
