//
// import 'dart:async';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//
// class AbstractBLT{
//
//   /****************BLUETOOTH SERIAL******************/
//   StreamSubscription<BluetoothDiscoveryResult>? _streamSubscription;
//   List<BluetoothDiscoveryResult> results =
//   List<BluetoothDiscoveryResult>.empty(growable: true);
//   bool isDiscovering = true;
//   List<String> entries = <String>[];
//   List<String> AdressEntries = <String>[];
//   var connection;
//
//   final Function onDataRecieved;
//
//   AbstractBLT({required this.onDataRecieved})
//   {
//     FlutterBluetoothSerial.instance.requestEnable();
//     if (isDiscovering) {
//       _startDiscovery();
//     }
//   }
//
//   List<String> getDevice_Names()
//   {
//     return entries;
//   }
//   List<String> getDevice_Adresses()
//   {
//     return AdressEntries;
//   }
//   void connect(String devA) async
//   {
//     List<BluetoothDevice> device =
//         await FlutterBluetoothSerial.instance.getBondedDevices();
//     connection = await BluetoothConnection.toAddress(devA);
//     connection!.input!.listen(onDataRecieved);
//   }
//
//   void _startDiscovery() async{
//     await FlutterBluetoothSerial.instance.cancelDiscovery();
//     entries.clear();
//     AdressEntries.clear();
//
//     _streamSubscription =
//         FlutterBluetoothSerial.instance.startDiscovery().listen((r) {
//           // setState(() {
//             final existingIndex = results.indexWhere(
//                     (element) => element.device.address == r.device.address);
//             if (existingIndex >= 0)
//               results[existingIndex] = r;
//              //entries[existingIndex] = r.device.name;
//             else
//               results.add(r);
//             entries.add(r.device.name.toString());
//             AdressEntries.add(r.device.address);
//           // });
//         });
//
//     _streamSubscription!.onDone(() {
//       // setState(() {
//         isDiscovering = false;
//         print(entries);
//         //entries.add()
//       // });
//     });
//   }
//
//
//
//
//   void search()
//   {
//     _startDiscovery();
//   }
//
//
//
// }
//

