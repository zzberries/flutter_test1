import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'dart:async';

import 'package:latlong2/latlong.dart';
import "package:http/http.dart" as http;
import "dart:convert" as convert;

import 'package:latlong2/latlong.dart' as latlong2;
import 'package:flutter/widgets.dart';

import 'map-page.dart';


void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        page = SearchPage();
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
                color: Theme
                    .of(context)
                    .colorScheme
                    .primaryContainer,
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
//creates a list from firebase document
  class FirebaseListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  return Scaffold(
  appBar: AppBar(
  title: Text('Firebase List'),
  ),
  body: StreamBuilder<DocumentSnapshot>(
  stream: FirebaseFirestore.instance
      .collection('buildings')
      .doc('11')
      .collection('my_collection')
      .doc('my_document')
      .snapshots(),
  builder: (context, snapshot) {
  if (!snapshot.hasData) {
  return Center(
  child: CircularProgressIndicator(),
  );
  }

  final data = snapshot.data!.data() as Map<String, dynamic>;
  final myList = data['my_list'] as List<dynamic>;

  return ListView.builder(
  itemCount: myList.length,
  itemBuilder: (context, index) {
  final item = myList[index];
  return ListTile(
  title: Text(item),
  );
  },
  );
  },
  ),
  );
  }
  }

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final CollectionReference doctorsRef =
  FirebaseFirestore.instance.collection('buildings');
  List<String> _suggestions = [];
  TextEditingController _searchController = TextEditingController();
  bool _isTextFieldFilled = false;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              onChanged: (value) {
                _getSuggestions(value);
              },
              decoration: InputDecoration(
                hintText: 'Search buildings',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 100,
              child: ListView.builder(
                itemCount: _suggestions.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_suggestions[index]),
                    onTap: () {
                      setState(() {
                        _searchController.text = _suggestions[index];
                        _isTextFieldFilled = true;
                      });
                    },
                  );
                },
              ),
            ),

            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
        )
    );
  }

  void _getSuggestions(String query) async {
    List<String> suggestions = [];
    QuerySnapshot querySnapshot = await doctorsRef
        .where('building_name', isGreaterThanOrEqualTo: query)
        .get();
    querySnapshot.docs.forEach((doc) {
      final data = doc.data() as Map<String, dynamic>;
      String buildingName = data['building_name'];
      if (buildingName.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(buildingName);
      }
    });

    setState(() {
      _suggestions = suggestions;
    });
  }
}