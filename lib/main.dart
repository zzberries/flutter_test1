import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';

import 'dart:async';

import 'package:latlong2/latlong.dart';
import "package:http/http.dart" as http;
import "dart:convert" as convert;

import 'package:latlong2/latlong.dart' as latlong2;
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MyApp());
}

String building = "";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'UMass Hospital Navigation'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String _str = "";

  // Initial Selected Value
  String dropdownvalue = 'N/A';

  // List of items in our dropdown menu
  var items = [
    'N/A',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  void _changeStr(String text) {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _str = text;
    });
  }

  /* List<DropdownMenuItem<String>> get dropdownItems {
    List<DropdownMenuItem<String>> menuItems = [
      DropdownMenuItem(child: Text("USA"), value: "USA"),
      DropdownMenuItem(child: Text("Canada"), value: "Canada"),
      DropdownMenuItem(child: Text("Brazil"), value: "Brazil"),
      DropdownMenuItem(child: Text("England"), value: "England"),
    ];
    return menuItems;
  }

  */
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const GeneratorPage();
        break;
      case 1:
        page = OpeningPage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.announcement),
                    label: Text('Announcements'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }

// This trailing comma makes auto-formatting nicer for build methods.
}



class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    //Future<Position> futurePose = getLatLng();
    // Position pos = await futurePose ;
    String buildingName = building;
    double lat = 42.27507; // south road parking garage
    double lng = -71.76205;
    if (building == "ACC") {
      lat = 42.27514;
      lng = -71.76259;
    } else if (building == "Aaron Lazare") {
      lat = 42.27656;
      lng = -71.76399;
    } else if (building == "Medical School") {
      lat = 42.27756;
      lng = -71.7617;
    }
    //lat = pos?.latitude;
    // double? lng  = pos?.latitude;
    //print(lat.toString()+", "+lng.toString());
    final coordinates = [LatLng(42.27748, -71.7642), LatLng(lat, lng)];
    final coordinatesTarget = [LatLng(42.27748, -71.7642), LatLng(lat, lng)];

    final bounds = LatLngBounds.fromPoints(coordinates
        .map((location) =>
            latlong2.LatLng(location.latitude, location.longitude))
        .toList());
    const padding = 50.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title:  Text('You\'re at the First Road Parking Garage.\nHead to '+buildingName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FlutterMap(
        options: MapOptions(
          bounds: bounds,
          boundsOptions: FitBoundsOptions(
            padding: EdgeInsets.only(
              left: padding,
              top: padding + MediaQuery.of(context).padding.top,
              right: padding,
              bottom: padding,
            ),
          ),
        ),
        nonRotatedChildren: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
          MarkerLayer(
              markers: coordinates.map((location) {
            return Marker(
                point: latlong2.LatLng(location.latitude, location.longitude),
                width: 35,
                height: 35,

                builder: (context) => const Icon(
                      Icons.location_pin,
                    ),
                anchorPos: AnchorPos.align(AnchorAlign.top));
          }).toList()),
          // DirectionsLayer(
          //      coordinates: coordinates,
          //      color: Colors.blue,
          //    ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        hoverColor: Colors.purple,
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pop(
            context,
            MaterialPageRoute(builder: (context) => const GeneratorPage()),
          );
        },
        label: Text('Back'),
      ),

    );
  }
}

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  State<GeneratorPage> createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  int _counter = 0;
  TextEditingController _textFieldController = TextEditingController();
  bool _isTextFieldFilled = false;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    IconData icon;
    icon = Icons.arrow_drop_down;

    return Material(
      child: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.

        child: Expanded(
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Enter any information you know about your appointment',
              ),
              Container(
                margin: EdgeInsets.all(24),
                padding: EdgeInsets.all(12),
                child: TextField(
                  controller: _textFieldController,
                  onChanged: (text) {
                    setState(() {
                      _isTextFieldFilled = text.isNotEmpty;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter some text',
                  ),
                ),
                decoration: BoxDecoration(color: Colors.white),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  //Icon(Icons.star, color: Colors.green[500]),
                  //Icon(Icons.star, color: Colors.green[500]),
                  // Icon(Icons.star, color: Colors.green[500]),
                  //const Icon(Icons.star, color: Colors.black),
                  // const Icon(Icons.star, color: Colors.black),

                  Container(
                    margin: EdgeInsets.all(24),
                    padding: EdgeInsets.all(5),
                    width: 200,
                    child: Column(
                      children: [
                        Text('What is your doctors first name?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16, // set the font size to 16
                            )),
                        CustomDropdownButton(
                          items: ['N/A', 'Item 2', 'Item 3'],
                          selectedItem: 'N/A',
                          onChanged: (String newValue) {
                            if (newValue != 'N/A') {
                              setState(() {
                                _isTextFieldFilled = true;
                              });
                            }
                            if (newValue == 'N/A') {
                              setState(() {
                                _isTextFieldFilled = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(24),
                    padding: EdgeInsets.all(5),
                    width: 200,
                    child: Column(
                      children: [
                        Text('What department are you going to?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16, // set the font size to 16
                            )),
                        CustomDropdownButton(
                          items: ['N/A', 'Item 2', 'Item 3'],
                          selectedItem: 'N/A',
                          onChanged: (String newValue) {
                            if (newValue != 'N/A') {
                              setState(() {
                                _isTextFieldFilled = true;
                              });
                            }
                            if (newValue == 'N/A') {
                              setState(() {
                                _isTextFieldFilled = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.all(24),
                    padding: EdgeInsets.all(5),

                    width: 200,
                    child: Column(
                      children: [
                        Text('What building are you going to?',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16, // set the font size to 16
                            )),
                        CustomDropdownButton(
                          items: [
                            'N/A',
                            'ACC',
                            'Aaron Lazare',
                            'Medical School'
                          ],
                          selectedItem: 'N/A',
                          onChanged: (String newValue) {
                            building = newValue;
                            if (newValue != 'N/A') {
                              setState(() {
                                _isTextFieldFilled = true;
                              });
                            }
                            if (newValue == 'N/A') {
                              setState(() {
                                _isTextFieldFilled = false;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    //decoration: BoxDecoration(color: Colors.white),
                  ),

                  Container(
                    margin: EdgeInsets.all(24),
                    child: ElevatedButton(
                      child: const Text('Next'),
                      onPressed: _isTextFieldFilled
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const FavoritesPage()),
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OpeningPage extends StatefulWidget {
  const OpeningPage({super.key});

  @override
  _OpeningPageState createState() => _OpeningPageState();
}

class _OpeningPageState extends State<OpeningPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('You have no annoucements!'),
      ),
    );
  }
}

class CustomDropdownButton extends StatefulWidget {
  final List<String> items;
  final String selectedItem;
  final Function(String) onChanged;

  CustomDropdownButton({
    required this.items,
    required this.selectedItem,
    required this.onChanged,
  });

  @override
  _CustomDropdownButtonState createState() => _CustomDropdownButtonState();
}

class _CustomDropdownButtonState extends State<CustomDropdownButton> {
  String? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DropdownButton<String>(
        value: _selectedItem,
        onChanged: (String? newValue) {
          setState(() {
            _selectedItem = newValue;
            widget.onChanged(newValue!);
          });
        },
        items: widget.items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
      ),
    );
  }
}
