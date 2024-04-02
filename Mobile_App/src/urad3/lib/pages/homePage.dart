// ignore: file_names
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
//import 'package:lcd_led/lcd_led.dart';
import 'package:location/location.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:segment_display/segment_display.dart';
import 'package:urad3/pages/DevicePage.dart';
import 'package:urad3/pages/GalleryPage.dart';
import 'package:urad3/pages/SettingPage.dart';
import 'package:urad3/widgets/Btn.dart';
import 'package:urad3/widgets/devicesDialog.dart';

import '../widgets/Battery.dart';
import '../widgets/BikeIndicator.dart';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/foundation.dart'; // Import ChangeNotifier class
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';

String DevName = "";
String DevNo = "";

class BlueCam extends GetxController {
  // FlutterBluePlus fble=FlutterBluePlus.instance;
}

class HomePge extends StatelessWidget {
  const HomePge({Key? key}) : super(key: key);

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
      home: const CenteredTextPage(),
    );
  }
}

class CenteredTextPage extends StatefulWidget {
  const CenteredTextPage({Key? key}) : super(key: key);

  @override
  _CenteredTextPageState createState() => _CenteredTextPageState();
}

class _CenteredTextPageState extends State<CenteredTextPage> {
  // String SDeviceA = "";
  double? mySpeed = 0;
  double sw = 0;
  double sh = 0;
  List<String> drawerItems = [];
  List<String> drawerItems2 = [];
  Timer? timer;
  Timer? timer2;
  var myBLT;
  List<double> objectsDist = [];
  List<Widget> cars = [];
  BikeIndicatorState st = BikeIndicatorState.safe;
  bool refrshen = false;
  String connDevicen = "";
  late LocationData _currentLocation;
  late Location location;
  double dbgMsg = 0.0;
  BatteryLevelWidget mybattery = BatteryLevelWidget(
    batteryLevel: 0.87,
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
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
    }
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
    //   onDataRecieved:_brecieved_callback,
    // );

    startTimer();
  }

  @override
  void dispose() {
    timer?.cancel(); // Cancel the timer when the state is disposed
    // timer2?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(milliseconds: 1000), (Timer timer) async {
      setState(() {
        mySpeed = _currentLocation.speed;
      });

      print(mySpeed);
    });
    /* timer2 = Timer.periodic(Duration(milliseconds: 10000), (Timer timer) {}); */
  }

  void _brecieved_callback(List<int> data) {
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

    if (kDebugMode) {
      print(data);
    }
    objectsDist.clear();
    if (data[0] == 0xfd) {
      int objsz = data[1];
      for (int i = 0; i < objsz * 3; i = i + 3) {
        if ((data[i + 3] > 0) && (data[i + 4].toDouble() > mySpeed!)) {
          objectsDist.add(data[i + 2].toDouble());
        }
        // objectsDist.add(data[i + 2].toDouble());

      }
    }
    if (kDebugMode) {
      print(objectsDist);
    }
    if ((data[0] == 0xfd) && (data[1] == objectsDist.length)) {
      if (kDebugMode) {
        print("displaying objects");
      }
      objectsDist.sort();
      led1state = false;
      led2state = false;
      led3state = false;
      led4state = false;
      led5state = false;
      for (int i = 0; i < objectsDist.length; i++) {
        double distance = objectsDist[i];
        /*print("****************************************");
        print(distance);
        print("Distance debugg******************");*/
        if ((distance) <= 30) {
          led1state = true;
        } else if ((distance) >= 31 && distance <= 60) {
          led2state = true;
        } else if ((distance) >= 61 && distance <= 90) {
          led3state = true;
        } else if ((distance) >= 91 && distance <= 120) {
          led4state = true;
        } else {
          led5state = true;
        }
      }
      // show bike status
      if (objectsDist[0] < 10) {
        print("state is : danger");
        setState(() {
          st = BikeIndicatorState.danger;
        });
      } else if (objectsDist[0] < 30) {
        print("state is : warning");
        setState(() {
          st = BikeIndicatorState.warning;
        });
      } else {
        print("state is : safe");

        setState(() {
          st = BikeIndicatorState.safe;
        });
      }
    } else {
      setState(() {
        cars.clear();
        st = BikeIndicatorState.safe;
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

  ///  serviceUuids: [4fafc201-1fb5-459e-8fcc-c5c9c331914b]}, rssi: -63, timeStamp: 2023-08-16 20:20:11.098165}
  // ignore: non_constant_identifier_names
  void SelectDevice(String sd, String sda) async {
    print("connecting to $sd $sda *******************");
    await FlutterBluePlus.stopScan();

    BluetoothDevice selectedBLE = BluetoothDevice(
      remoteId: DeviceIdentifier(sda),
    );
    try {
      await selectedBLE.connect(timeout: const Duration(seconds: 3));

      if (selectedBLE.isConnected) {
        setState(() {
          connDevicen = sd;
          DevName = sd;
          DevNo = sda;
        });
        var x2 = await selectedBLE.discoverServices(timeout: 15);
        BluetoothCharacteristic x3;

        for (var i in x2) {
          if (kDebugMode) {
            print("service is ${i.toString()}");
          }
          if (i.serviceUuid.toString() ==
              '4fafc201-1fb5-459e-8fcc-c5c9c331914b') {
            List<BluetoothCharacteristic> mc = i.characteristics;
            for (var j in mc) {
              if (j.characteristicUuid.toString() ==
                  'beb5483e-36e1-4688-b7f5-ea07361b26a8') {
                x3 = j;
                x3.setNotifyValue(true, timeout: 15);
                // List<int> ss=await x3.read(timeout: 15);
                // x3.onValueReceived.listen((event) { print("ss=");print(event);});
                x3.onValueReceived.listen(_brecieved_callback);
              }
            }
          }
        }
      }
    } catch (e) {
      print("invalid opereation  ??  $e");
    }

    // print(i.serviceUuid);
    // print("****************************************************************");
    // print("****************************************************************");

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

  // ignore: non_constant_identifier_names
  void DisconnectDevice(String sd, String sda) async {
    setState(() {
      cars.clear();
      DevName = "";
      DevNo = "";
    });
    BluetoothDevice selectedBLE = BluetoothDevice(
      remoteId: DeviceIdentifier(sda),
    );

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
            x3.setNotifyValue(false, timeout: 15);

            // List<int> ss=await x3.read(timeout: 15);
            // x3.onValueReceived.listen((event) { print("ss=");print(event);});
            // x3.onValueReceived.listen(_brecieved_callback);
          }
        }
      }
    }
    await selectedBLE.disconnect(timeout: 55);
    setState(() {
      connDevicen = "";
    });
    // ignore: deprecated_member_use
    await FlutterBluePlus.turnOff();
    await FlutterBluePlus.turnOn(timeout: 50);
    setState(() {
      cars.clear();
      st = BikeIndicatorState.safe;
    });
  }

  // ignore: non_constant_identifier_names
  void RefreshBluetooth() async {
    // print("hello2");
    setState(() {
      refrshen = true;
      drawerItems.clear();
      drawerItems2.clear();
    });
    // cleanup: cancel subscription when scanning stops

    var x;
    var y = FlutterBluePlus.onScanResults.listen(
      (results) {
        x = results;
        List<BluetoothDevice> mdevices = [];
        for (var i in x) {
          mdevices.add(i.device);
          /*           print("*****************************");
          print("Discovered:$i       ******");
          print("*****************************"); */
        }
        // print("devices=");
        // print(x);

        setState(() {
          drawerItems.clear();
          drawerItems2.clear();
          refrshen = false;
          for (var i in mdevices) {
            // ignore: deprecated_member_use
            drawerItems.add(i.localName);
            drawerItems2.add(i.remoteId.toString());
          }
          // myBLT.search();
          // drawerItems = myBLT.getDevice_Names();
          // drawerItems2 = myBLT.getDevice_Adresses();
        });
        if (results.isNotEmpty) {
          ScanResult r = results.last; // the most recently found device

          if (kDebugMode) {
            print(
                '${r.device.remoteId}: "${r.advertisementData.advName}" found!');
          }
        }
      },
      onError: (e) => print(e),
    );
    FlutterBluePlus.cancelWhenScanComplete(y);
    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 5));
  }

  // ignore: non_constant_identifier_names
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
    if (kDebugMode) {
      print("pressed...");
    }
  }

  // ignore: non_constant_identifier_names
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

  // ignore: non_constant_identifier_names
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
          // ignore: avoid_print
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
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 15, top: 15),
        child: SizedBox(
          child: BatteryLevelWidget(
            batteryLevel: .1,
            frameHeight: 30,
            frameWidth: 45,
          ),
        ),
      ),
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

  Widget _spedometerWidget(double speed) {
    final String n = speed.toString(); // Change const to final
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
          const SizedBox(width: 5),
          SizedBox(
            width: 120,
            height: 90,
            child: SevenSegmentDisplay(
              value: n,
              size: 4.5,
              characterSpacing: 10.0,
              backgroundColor: Colors.transparent,
              segmentStyle: const HexSegmentStyle(
                enabledColor: Colors.white,
                disabledColor: Color.fromARGB(255, 82, 81, 81),
              ),
            ),
          ),
          const SizedBox(width: 15), // Add spacing between LED digits and units
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
        Padding(
          padding: const EdgeInsets.only(
              left: 15), // Adjust the left padding as needed
          child: TextButton(
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
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 15), // Adjust the left padding as needed
          child: TextButton(
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
        ),
        Padding(
          padding: const EdgeInsets.only(
              left: 15), // Adjust the left padding as needed
          child: TextButton(
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
        ),
        const SizedBox(
            height: 20), // Adjust the space between the buttons and the icon
        Padding(
          padding: const EdgeInsets.only(
              left: 15), // Adjust the left padding as needed
          child: TextButton(
            onPressed: () {},
            child: SvgPicture.asset(
              'assets/icons/flashlight.svg', // Replace 'your_icon.svg' with the path to your SVG icon
              height: 65, // Adjust the height of the icon as needed
              width: 10, // Adjust the width of the icon as needed
              // ignore: deprecated_member_use
              color: iconColor,
            ),
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
          height: screenHeight / 50,
        ),
        ledElement(
            screenHeight,
            screenWidth,
            (led1state == true)
                ? const Color.fromARGB(255, 255, 0, 0)
                : Colors.grey,
            '<30 m     '),
        const SizedBox(
          height: 25,
        ),
        ledElement(
            screenHeight,
            screenWidth,
            (led2state == true)
                ? const Color.fromARGB(255, 255, 92, 0)
                : Colors.grey,
            '31 - 60m'),
        const SizedBox(
          height: 25,
        ),
        ledElement(
            screenHeight,
            screenWidth,
            (led3state == true)
                ? const Color.fromARGB(255, 208, 222, 49)
                : Colors.grey,
            '61 - 90m'),
        const SizedBox(
          height: 25,
        ),
        ledElement(
            screenHeight,
            screenWidth,
            (led4state == true)
                ? const Color.fromARGB(255, 20, 255, 0)
                : Colors.grey,
            '91 - 120m'),
        const SizedBox(
          height: 25,
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

  Widget getBikeIndicator() {
    return BikeIndicator(status: st);
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool DrawerState = false;
  @override
  Widget build(BuildContext context) {
    // ignore: non_constant_identifier_names
    CustomDrawer devicesDrawer = CustomDrawer(
      items: drawerItems,
      items_description: drawerItems2,
      selectedSetter: SelectDevice,
      rfrsh: RefreshBluetooth,
      connectedDevice: connDevicen,
      first: refrshen,
      spd: dbgMsg,
      onDiscnnct: DisconnectDevice,
      setItems: setDrawerItems,
      color: Colors.grey,
    );
    Size screenSize = MediaQuery.of(context).size;
    double screenWidth = screenSize.width;
    double screenHeight = screenSize.height;
    bool isDrawerOpen = scaffoldKey.currentState?.isDrawerOpen ?? false;
    return Stack(
      children: [
        Scaffold(
          key: scaffoldKey, // Assign the key to the Scaffold
          appBar: _Urad3AppBar(),
          body: Stack(
            children: [
              Column(
                children: [
                  const SizedBox(height: 5),
                  BikeIndicator(status: st),
                  const SizedBox(
                      height:
                          24), // Add spacing between the bar and the LED digits
                  _spedometerWidget(mySpeed!),
                  Row(
                    children: [
                      _leftSideWidget(screenHeight, screenWidth),
                      _rightSideWidget(screenHeight, screenWidth)
                    ],
                  )
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    height: screenHeight / 2.3,
                  ),
                  IconButton(
                      onPressed: () {
                        // Programmatically open the drawer
                        scaffoldKey.currentState?.openDrawer();
                        setState(() {});
                      },
                      icon: const Icon(Icons.search))
                ],
              )
            ],
          ),
          backgroundColor: Colors.grey[800],
          drawerEnableOpenDragGesture: false,
          drawer: devicesDrawer,
        ),
      ],
    );
  }
}
        /*Row(
          children: [
            (!isDrawerOpen)
                ? Container(
                    //  width: 50,
                    margin: const EdgeInsets.only(left: 15, top: 40),
                    child: BatteryLevelWidget(
                      batteryLevel: 1.0,
                      frameHeight: 30,
                      frameWidth: 60,
                    ),
                  )
                : Container()
          ],
        ),*/
