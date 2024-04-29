import 'package:flutter/material.dart';
import '../widgets/FullWidthBTN.dart';

class GalleryPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<GalleryPage> {
  String template =
      "Wi-Fi, short for Wireless Fidelity, is a technology that allows wireless communication between devices using radio waves. It provides a means to connect devices to the internet and to each other without the need for physical cables.";

  Widget FooterButtons() {
    return Column(
      children: [
        FWBTN(
          icon: Icons.camera_alt,
          text: "camera",
          size: 24,
          onPressed: () => {print("hello")},
        ),
        SizedBox(height: 20.0),
        FWBTN(
          icon: Icons.sd_card,
          text: "Storage",
          size: 24,
          onPressed: () => {print("help")},
        ),
        SizedBox(height: 20.0),
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
        title: const Text('Device Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.topCenter,
              child: Container(
                width: 200,
                height: 200,
                child: Image.asset(
                    'assets/images/wifi.png'), // Replace 'assets/device.png' with the path to your image
              ),
            ),
            const SizedBox(height: 26.0),
            Center(
                child: Column(
              children: [
                // Text(
                //   template,
                //   style: TextStyle(
                //       fontSize: 18.0,
                //       fontWeight: FontWeight.bold,
                //       color: Colors.white),
                // ),
                const SizedBox(height: 5.0),
                Container(
                  margin: EdgeInsets.only(left: 50, right: 50),
                  child: Text(
                    template,
                    style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70),
                  ),
                )
              ],
            )),
            const SizedBox(height: 16.0),

            const SizedBox(height: 26.0),

            // FooterButtons()
          ],
        ),
      ),
    );
  }
}
