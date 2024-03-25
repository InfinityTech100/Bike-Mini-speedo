import 'package:flutter/material.dart';
import '../widgets/FullWidthBTN.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String version = " 1.0.1";

  void SetSWVersion(String swv) {
    version = swv;
  }

  Widget MainButtons() {
    return Column(
      children: [
        FWBTN(
          icon: Icons.notification_important_rounded,
          text: "Sounds And Alerts",
          size: 24,
          onPressed: () => {print("hello")},
        ),
        SizedBox(height: 20.0),
        FWBTN(
          icon: Icons.info_outline,
          text: "Help",
          size: 24,
          onPressed: () => {print("help")},
        ),
        SizedBox(height: 20.0),
        FWBTN(
          icon: Icons.bug_report_outlined,
          text: "Diagnostic Reports",
          size: 24,
          onPressed: () => {print("help")},
        ),
      ],
    );
  }
  Widget LegalsButtons() {
    return Column(
      children: [
        FWBTN(
          icon: Icons.warning_amber,
          text: "User Warnings",
          size: 24,
          onPressed: () => {print("hello")},
        ),
        SizedBox(height: 20.0),
        FWBTN(
          icon: Icons.local_police_outlined,
          text: "Privacy Policy",
          size: 24,
          onPressed: () => {print("help")},
        ),
        SizedBox(height: 20.0),
        FWBTN(
          icon: Icons.copyright_outlined,
          text: "Copyrights",
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
        title: Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MainButtons(),
            const SizedBox(height: 26.0),
            const Text(
              'App Info',
              style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
            ),
            const SizedBox(height: 16.0),
            Container(
              margin: const EdgeInsets.only(left: 45),
              child: const Text(
                'Software Version',
                style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 45, top: 5),
              child: Text(
                version,
                style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
              ),
            ),

        const SizedBox(height: 26.0),

        const Text(
          'Legals',
          style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey),
        ),
            const SizedBox(height: 20.0),
            LegalsButtons()


          ],
        ),
      ),
    );
  }
}
