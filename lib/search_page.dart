import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_workspace/firestore_collections/Doctor.dart';
import 'package:flutter_workspace/geolocator-test.dart';

import 'choice_page.dart';
import 'firestore_collections/Building.dart';
import 'firestore_collections/Department.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
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
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(5),
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
                  padding: const EdgeInsets.all(5),
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
                            builder: (context) => GeolocatorWidget(),
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
          ],
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