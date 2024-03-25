import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';



class CustomDrawer extends StatelessWidget {
  final List<String> items;
  final List<String> items_description;
  // final BluetoothDevice m_dev;
  final Function(List<String>,List<String>) setItems;
  final Function selectedSetter;
  final Function rfrsh;

  CustomDrawer({required this.items, required this.items_description,required this.selectedSetter, required this.rfrsh, required this.setItems});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black,
        child: Column(
          children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () {
                        rfrsh();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Select Device',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [

                      ListTile(
                        title: Text(
                          "${items[index]}\n${items_description[index]}",
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onTap: () {
                          print('Selected item: ${items[index]}');
                          selectedSetter(items[index],items_description[index]);

                          Navigator.pop(context);
                        },
                      ),

                       // Container(
                       //   margin: EdgeInsets.only(left: 20),
                       //   child:Text(
                       //     'Test',
                       //     style: TextStyle(
                       //       fontSize: 12.0,
                       //       color: Colors.grey,
                       //     ),
                       //   ),
                       // )

                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
//
// class CustomDrawer extends StatelessWidget {
//   final List<String> items;
//   final Function(List<String>) setItems;
//   final Function selectedSetter;
//
//   CustomDrawer({required this.items,required this.selectedSetter, required this.setItems});
//
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//       child: Column(
//         children: [
//           const SizedBox(height: 40),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               'Select Device',
//               style: TextStyle(
//                 fontSize: 20.0,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Expanded(
//             child: ListView.builder(
//               itemCount: items.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return ListTile(
//                   title: Text(items[index]),
//                   onTap: () {
//                     // Handle the item selection here
//                     // You can perform any action or navigation based on the selected item
//                     print('Selected item: ${items[index]}');
//                     selectedSetter(items[index]);
//                     Navigator.pop(context);
//                   },
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
