import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_workspace/firestore_collections/Doctor.dart';
import 'package:flutter_workspace/geolocator-test.dart';

import 'choice_page.dart';
import 'firestore_collections/Building.dart';
import 'firestore_collections/Department.dart';
import 'map_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = SearchPage();
        break;
      case 1:
        page = const OpeningPage();
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
                destinations: const [
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

class OpeningPage extends StatefulWidget {
  const OpeningPage({super.key});

  @override
  OpeningPageState createState() => OpeningPageState();
}

class OpeningPageState extends State<OpeningPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('You have no announcements!'),
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
        title: const Text('Firebase List'),
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
            return const Center(
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
  String _doctorName = 'N/A';
  String _buildingName = 'N/A';
  String _departmentName = 'N/A';

  int _doctorID = -1;
  int _buildingID = -1;
  int _departmentID = -1;

  double _lat = 0.0;
  int _id = 0;

  double _long = 0.0;

  @override
  Widget build(BuildContext context) {
    return Material(

        child: Container(
          child: Column(
            children: [
              const Text('What is the reason of appointment?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16, // set the font size to 16
                  )),
              Container(
                margin: const EdgeInsets.all(24),
                padding: const EdgeInsets.all(5),
                child: Stack(
                  children: [
                    TextField(
                      controller: _searchController,
                      onTap: () {
                        setState(() {
                          _isTextFieldFilled = true;
                        });
                      },
                      onChanged: (value) {
                        _getSuggestions(value);
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search buildings',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.search),
                      ),
                    ),
                    Visibility(
                      visible: _isTextFieldFilled,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isTextFieldFilled = false;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 60),
                          height: 100,
                          child: ListView.builder(
                            itemCount: _suggestions.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(_suggestions[index]),
                                onTap: () {
                                  setState(() {
                                    _searchController.text = _suggestions[index];
                                    _isTextFieldFilled = false;
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.only(top: 5),
                      margin: const EdgeInsets.all(24),
                      width: 400,
                      child: Column(
                        children: [
                          const Text('What building are you going to?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16, // set the font size to 16
                              )),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('buildings')
                                .withConverter(
                                fromFirestore: Building.fromFirestore,
                                toFirestore: (Building d, _) => d.toFirestore())
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              return DropdownButton(
                                items: [
                                  const DropdownMenuItem(value: -1, child: Text('N/A')),
                                  ...snapshot.data!.docs.map((e) {
                                    var d = e.data();
                                    return DropdownMenuItem(
                                      value: d.buildingID,
                                      child: Text(d.buildingName),
                                    );
                                  }).toList(),
                                ],
                                value: _buildingID,
                                onChanged: (int? newValue) async {
                                  setState(() {
                                    _buildingID = newValue!;
                                  });
                                  await _getLatLong(_buildingID);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(24),
                      padding: EdgeInsets.only(top: 5),
                      width: 400,
                      child: Column(
                        children: [
                          const Text('What is the name of your doctor?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16, // set the font size to 16
                              )),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('doctors')
                                .withConverter(
                                fromFirestore: Doctor.fromFirestore,
                                toFirestore: (Doctor d, _) => d.toFirestore())
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              return DropdownButton(
                                items: [
                                  const DropdownMenuItem(value: -1, child: Text('N/A')),
                                  ...snapshot.data!.docs.map((e) {
                                    var d = e.data();
                                    return DropdownMenuItem(
                                      value: d.doctorID,
                                      child: Text('${d.lastName}, ${d.firstName}'),
                                    );
                                  }).toList(),
                                ],
                                value: _doctorID,
                                onChanged: (int? newValue) {
                                  setState(() {
                                    _doctorID = newValue!;
                                  });
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(24),
                      padding: const EdgeInsets.all(5),
                      width: 400,
                      child: Column(
                        children: [
                          const Text('What department are you going to?',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16, // set the font size to 16
                              )),
                          StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('departments')
                                .withConverter(
                                fromFirestore: Department.fromFirestore,
                                toFirestore: (Department d, _) => d.toFirestore())
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const CircularProgressIndicator();
                              }
                              return DropdownButton(
                                items: [
                                  const DropdownMenuItem(value: -1, child: Text('N/A')),
                                  ...snapshot.data!.docs.map((e) {
                                    var d = e.data();
                                    return DropdownMenuItem(
                                      value: d.departmentID,
                                      child: Text(d.departmentName),
                                    );
                                  }).toList(),
                                ],
                                value: _departmentID,
                                onChanged: (int? newValue) async {
                                  setState(() {
                                    _departmentID = newValue!;
                                  });
                                  await _getDepartmentId(_departmentName);
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(24),
                      child: ElevatedButton(
                        onPressed: !(_doctorID == -1 &&
                            _departmentID == -1 &&
                            _buildingID == -1)
                            ? () {
                          if (_departmentID != -1 && _buildingID == -1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChoicePage(
                                  buildingID: _buildingID,
                                  departmentID: _departmentID,
                                  doctorID: _doctorID,
                                ),
                              ),
                            );
                          } else if (_buildingID != -1) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FavoritesPage(
                                  lat: _lat,
                                  long: _long,
                                ),
                              ),
                            );
                          }
                        }
                            : null,
                        child: const Text('Next'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));

  }

  void _getSuggestions(String query) async {
    List<String> suggestions = [];
    QuerySnapshot querySnapshot = await doctorsRef
        .where('building_name', isGreaterThanOrEqualTo: query)
        .get();
    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      String buildingName = data['building_name'];
      if (buildingName.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(buildingName);
      }
    }

    setState(() {
      _suggestions = suggestions;
    });
  }

  Future<void> _getLatLong(int buildingid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('buildings')
        .where('building_id', isEqualTo: buildingid)
        .get();
    if (snapshot.size > 0) {
      final data = snapshot.docs[0].data();
      final lat = data['lat'].toDouble();
      final long = data['long'].toDouble();
      setState(() {
        _lat = lat;
        _long = long;
      });
      print('Latitude: $_lat');
      print('Longitude: $_long');
    } else {
      print('No data found for building name: $buildingid');
    }
  }

  Future<void> _getDepartmentId(String _departmentName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('departments')
        .where('department_name', isEqualTo: _departmentName)
        .get();
    if (snapshot.size > 0) {
      final data = snapshot.docs[0].data();
      final id = data['department_id'].toInt();
      setState(() {
        _id = id;
      });
      print('Department Id: $_id');
    } else {
      print('No data found for department name: $_departmentName');
    }
  }
}