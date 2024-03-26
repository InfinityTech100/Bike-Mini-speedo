import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lcd_led/lcd_led.dart';
import 'package:location/location.dart';
import 'package:urad3/pages/DevicePage.dart';
import 'package:urad3/pages/GalleryPage.dart';
import 'package:urad3/pages/SettingPage.dart';
import 'package:urad3/widgets/Btn.dart';
import 'package:urad3/widgets/Car.dart';
import 'package:urad3/widgets/devicesDialog.dart';

import '../widgets/Battery.dart';
import '../widgets/BikeIndicator.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart'; // Import ChangeNotifier class
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

class BlueCam extends GetxController {
  // FlutterBluePlus fble=FlutterBluePlus.instance;
}

class HomePge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Start scanning
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        //accentColor: Color(0xFF3BB5EA),
        scaffoldBackgroundColor: Colors.black,
        textTheme: const TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
        ),
      ),
      home: CenteredTextPage(),
    );
  }
}

class CenteredTextPage extends StatefulWidget {
  @override
  _CenteredTextPageState createState() => _CenteredTextPageState();
}

class _CenteredTextPageState extends State<CenteredTextPage> {
  String SDevice = "";
  String SDeviceA = "";
  double sw = 0;
  double sh = 0;
  List<String> drawerItems = [];
  List<String> drawerItems2 = [];
  Timer? timer;
  Timer? timer2;
  var myBLT;
  List<double> objectsDist = [];
  List<Widget> cars = [];
  String st = "safe";
  late LocationData _currentLocation;
  late Location location;
  double dbgMsg = 0.0;
  BatteryLevelWidget mybattery = BatteryLevelWidget(
    batteryLevel: 0.80,
    frameWidth: 50,
    frameHeight: 20,
  );
  void initPermessions() async {
    WidgetsFlutterBinding.ensureInitialized();
    [
      Permission.location,
      Permission.storage,
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan
    ].request();
    await FlutterBluePlus.turnOn();
    location = Location();
    location.enableBackgroundMode(enable: true);
    bool serviceEnabled;
    // try{
    //   serviceEnabled = await location.serviceEnabled();
    //   if (!serviceEnabled) {
    //     serviceEnabled = await location.requestService();
    //
    //   }
    // }
    // catch(e)
    // {
    //
    // }
    location.onLocationChanged.listen((LocationData currentLocation) {
      //   // Use current location
      _currentLocation = currentLocation;
    });
    // WidgetsFlutterBinding.ensureInitialized(); // Initialize the Flutter binding
    // PermissionStatus st3 = await Permission.bluetooth.request();
    // PermissionStatus st2 = await Permission.location.request();
    // PermissionStatus st4 = await Permission.bluetoothConnect.request();
    // PermissionStatus st5 = await Permission.bluetoothScan.request();
    // PermissionStatus st = await Permission.storage.request();
  }

  @override
  void initState() {
    super.initState();
    initPermessions();
    // myBLT=AbstractBLT(
    //   onDataRecieved:Brecieved_callback,
    // );

      /* startTimer(); */
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the state is disposed
    // timer2?.cancel();
    super.dispose();
  }

/*   void startTimer() {
    timer = Timer.periodic(Duration(milliseconds: 100), (Timer timer) {
      setState(() {
        //drawerItems = myBLT.getDevice_Names();
      });
    });
    timer2 = Timer.periodic(Duration(milliseconds: 10000), (Timer timer) {});
  }
 */

  void Brecieved_callback(List<int> data) {
    double? mySpeed = 0;
    try {
      mySpeed = _currentLocation.speed;
    } catch (e) {
      print("failed to get device speed ,maybe un initialized .!");
    }
    //double? mySpeed =10; //for dbg purpose
    setState(() {
      dbgMsg = mySpeed!;
    });

    print(data);
    objectsDist.clear();
    if (data[0] == 0xfd) {
      int objsz = data[1];
      for (int i = 0; i < objsz * 3; i = i + 3) {
        if ((data[i + 3] > 0) && (data[i + 4].toDouble() > mySpeed!)) {
          objectsDist.add(data[i + 2].toDouble() / 2);
        }
        // objectsDist.add(data[i + 2].toDouble());
      }
    }
    print(objectsDist);
    if ((data[0] == 0xfd) && (data[1] == objectsDist.length)) {
      print("displaying objects");
      objectsDist.sort();
      // 2-translate distances
      for (int i = 0; i < objectsDist.length; i++) {
        double distance = objectsDist[i];
        if (distance < 30) {
          led1state = true;
        } else if (distance >= 31 && distance <= 60) {
          led2state = true;
        } else if (distance >= 61 && distance <= 90) {
          led3state = true;
        } else if (distance >= 91 && distance <= 120) {
          led4state = true;
        } else {
          led5state = true;
        }
      }
      double of = 0;
      if (sh > 600) {
        of = (sh / 24);
      } else {
        of = ((sh / 18) - 30);
      }
      double offset = 176 + of;
      cars.clear();
      double sum = 0;
      for (int i = 0; i < objectsDist.length; i++) {
        if (objectsDist[i] < 50) {
          sum = 0;
          double y = ((objectsDist[i] * (sh - offset) / 60));
          // show the cars
          cars.add(Car(displacement: y, visible: true));
        }
      }
      // show bike status
      if (objectsDist[0] < 10) {
        setState(() {
          st = "danger";
        });
      } else if (objectsDist[0] < 30) {
        setState(() {
          st = "warning";
        });
      } else {
        setState(() {
          st = "safe";
        });
      }
    } else {
      setState(() {
        cars.clear();
        st = "safe";
      });
    }

    // print("data" + objectsDist.toString());
  }

  void setDrawerItems(List<String> newItems, List<String> newItems2) {
    drawerItems.clear();
    drawerItems.addAll(newItems);
    drawerItems2.clear();
    drawerItems2.addAll(newItems2);
  }

  /**
   *  serviceUuids: [4fafc201-1fb5-459e-8fcc-c5c9c331914b]}, rssi: -63, timeStamp: 2023-08-16 20:20:11.098165}
   */
  void SelectDevice(String sd, String sda) async {
    BluetoothDevice selectedBLE = BluetoothDevice(
      remoteId: DeviceIdentifier(sda),
      //  localName: sd,
      //type: BluetoothDeviceType.le);
    );
    await selectedBLE.connect(
        timeout: const Duration(seconds: 3), autoConnect: true);
    print("characterestics=");
    var x2 = await selectedBLE.discoverServices(timeout: 15);
    BluetoothCharacteristic x3;
    for (var i in x2) {
      if (i.serviceUuid.toString() == '4fafc201-1fb5-459e-8fcc-c5c9c331914b') {
        print("object");
        List<BluetoothCharacteristic> mc = i.characteristics;
        for (var j in mc) {
          if (j.characteristicUuid.toString() ==
              'beb5483e-36e1-4688-b7f5-ea07361b26a8') {
            x3 = j;
            x3.setNotifyValue(true, timeout: 15);
            // List<int> ss=await x3.read(timeout: 15);
            // x3.onValueReceived.listen((event) { print("ss=");print(event);});
            x3.onValueReceived.listen(Brecieved_callback);
          }
        }
      }
      print(i.serviceUuid);
      print("****************************************************************");
      print("****************************************************************");
    }

    // Get the characteristic that will be used to receive data
    // BluetoothCharacteristic characteristic =

// Enable notifications for the characteristic
    //selectedBLE.
    // Get the BluetoothConnection object for the device.

    // SDevice=sd;
    // SDeviceA=sda;
    // print(" Selected dev "+ SDevice+"  Selected dev address "+ SDeviceA);
    // myBLT.connect(sda);
  }

  void RefreshBluetooth() async {
    print("hello2");
    setState(() {
      drawerItems.clear();
      drawerItems2.clear();
    });
/*     var x = [];
    x=await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));

    List<BluetoothDevice> mdevices = [];
    for (var i in x) {
      mdevices.add(i.device);
    }
    print("devices=");
    print(x);
 */
/*     setState(() {
      drawerItems.clear();
      drawerItems2.clear();

      for (var i in mdevices) {
        drawerItems.add(i.localName);
        drawerItems2.add(i.remoteId.toString());
      }
      // myBLT.search();
      // drawerItems = myBLT.getDevice_Names();
      // drawerItems2 = myBLT.getDevice_Adresses();
    }); */
  }

  Widget Battery() {
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mybattery,

            const SizedBox(height: 16),
            // Other widgets
          ],
        ),
      ),
    );
  }
  void pressed() {
    print("pressed...");
  }
  Widget MyAppBar(double space1, double space2, double space3) {
    return Row(
      children: [
        Battery(),
        // Device Settings
        Container(
          margin: EdgeInsets.only(left: space1),
          height: 50,
          width: 50,
          child: BTN(
            icon: Icons.devices_other,
            size: 50,
            //onPressed:pressed,
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DevicePage()),
              )
            },
          ),
        ),
        // Gallery
        Container(
          margin: const EdgeInsets.only(left: 20),
          height: 30,
          width: 30,
          child: BTN(
            icon: Icons.image,
            size: 30,
            //onPressed:pressed,
            onPressed: () => {
              print("aaa"),
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GalleryPage()),
              )
            },
          ),
        ),
        // General Setting
        Container(
          margin: EdgeInsets.only(left: space3),
          height: 40,
          width: 40,
          child: BTN(
            icon: Icons.settings,
            size: 40,
            //onPressed:pressed,
            onPressed: () => {
              print("General setting"),
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              )
            },
          ),
        )
      ],
    );
  }

  Widget MyFooter(double ht, double wd) {
    return Row(children: [
      Container(
        margin: EdgeInsets.only(top: ht - 80, left: 20),
        height: 60,
        width: 60,
        // color: Colors.lightBlue,
        child: BTN(
          icon: Icons.camera_alt,
          size: 60,
          //onPressed:pressed,
          onPressed: () => {print("aaa2")},
        ),
      ),
      Container(
        margin: EdgeInsets.only(top: ht - 80, left: wd - 20 - 60 - 80),
        height: 60,
        width: 60,
        // color: Colors.lightBlue,
        child: BTN(
          icon: Icons.video_call,
          size: 60,
          //onPressed:pressed,
          onPressed: () => {print("aaa3")},
        ),
      )
    ]);
  }

  Color nightButtonColor = Colors.grey;
  Color dayButtonColor = Colors.grey;
  Color offButtonColor = Colors.grey;
  Color iconColor = Colors.grey;
  bool led1state = false;
  bool led2state = false;
  bool led3state = false;
  bool led4state = false;
  bool led5state = false;
// ignore: non_constant_identifier_names
  PreferredSizeWidget _Urad3AppBar() {
    return AppBar(
      //leading:
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SettingsPage()),
            );
          },
        ),
      ],
      title: IconButton(
        icon: SvgPicture.asset(
          'assets/icons/Circled menu.svg',
          // You can adjust the size of the SVG icon as needed
          height: 25,
          width: 24,
          // ignore: deprecated_member_use
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DevicePage()),
          );
        },
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
            setState(() {
              nightButtonColor = Colors.white;
              dayButtonColor = Colors.grey;
              offButtonColor = Colors.grey;
              iconColor = Colors.green;
            });
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
            setState(() {
              nightButtonColor = Colors.grey;
              dayButtonColor = Colors.white;
              offButtonColor = Colors.grey;
              iconColor = Colors.green;
            });
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
            setState(() {
              nightButtonColor = Colors.grey;
              dayButtonColor = Colors.grey;
              offButtonColor = Colors.white;
              iconColor = Colors.grey;
            });
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
          onPressed: () {},
          child: SvgPicture.asset(
            'assets/icons/flashlight.svg', // Replace 'your_icon.svg' with the path to your SVG icon
            height: 70, // Adjust the height of the icon as needed
            width: 10, // Adjust the width of the icon as needed
            // ignore: deprecated_member_use
            color: iconColor,
          ),
        )
      ],
    );
  }

  Widget ledElement(
      double screenHeight, double screenWidth, Color color, String text) {
    double circleSize =
        screenWidth / 4.7; // Adjust as needed for the circle size
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
        Center(
            child: SizedBox(
          width: 100,
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ))
      ],
    );
  }

  Widget _rightSideWidget(double screenHeight, double screenWidth) {
    return Column(
      children: [
        SizedBox(
          height: screenHeight / 25,
        ),
        ledElement(
            screenHeight,
            screenWidth,
            (led1state == true)
                ? const Color.fromARGB(255, 255, 0, 0)
                : Colors.grey,
            '<30 m     '),
        const SizedBox(
          height: 30,
        ),
        ledElement(
            screenHeight,
            screenWidth,
            (led2state == true)
                ? const Color.fromARGB(255, 255, 92, 0)
                : Colors.grey,
            '31 - 60m'),
        const SizedBox(
          height: 30,
        ),
        ledElement(
            screenHeight,
            screenWidth,
            (led3state == true)
                ? const Color.fromARGB(255, 208, 222, 49)
                : Colors.grey,
            '61 - 90m'),
        const SizedBox(
          height: 30,
        ),
        ledElement(
            screenHeight,
            screenWidth,
            (led4state == true)
                ? const Color.fromARGB(255, 20, 255, 0)
                : Colors.grey,
            '91 - 120m'),
        const SizedBox(
          height: 30,
        ),
        ledElement(
            screenHeight,
            screenWidth,
            (led5state == true)
                ? const Color.fromARGB(255, 66, 171, 89)
                : Colors.grey,
            '> 120 m'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    CustomDrawer DevicesDrawer = CustomDrawer(
      items: drawerItems,
      items_description: drawerItems2,
      selectedSetter: SelectDevice,
      rfrsh: RefreshBluetooth,
      setItems: setDrawerItems,
    );
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    return Stack(
      children: [
        Scaffold(
          appBar: _Urad3AppBar(),
          body: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 24),
                  BikeIndicator(
                    state: 'danger',
                  ),
                  const SizedBox(
                      height:
                          24), // Add spacing between the bar and the LED digits
                  _spedometerWidget(88),
                  Row(children: [
                    _leftSideWidget(screenHeight, screenWidth),
                    _rightSideWidget(screenHeight, screenWidth)
                  ])
                ],
              ),
            ],
          ),
          backgroundColor: Colors.grey[800],
        ),
        Row(
          children: [
            Container(
              //  width: 50,
              margin: const EdgeInsets.only(left: 20, top: 65),
              child: BatteryLevelWidget(
                batteryLevel: 0.50,
                frameHeight: 30,
                frameWidth: 60,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
//  vLines(),
/*   Column(
              children: [
                const SizedBox(height: 40), // Add spacing
                MyAppBar(space1, space2, space3),
                SizedBox(
                  height: (sh > 600) ? ((sh / 24)) : ((sh / 18) - 30),
                ), // Add spacing
                BikeIndicator(state: st),
                Stack(
                  children: cars,
                )
              ],
            ), */
//  MyFooter(sh, sw),
