import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_workspace/firestore_collections/Doctor.dart';
import 'package:flutter_workspace/map_page_live.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'choice_page.dart';
import 'firestore_collections/Building.dart';
import 'firestore_collections/Department.dart';

/// This class models the Search page.
class SearchPage extends StatefulWidget {
  // Callback function

  const SearchPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  @override
  void initState() {
    super.initState();
    // Add a delay before showing the terms dialog button
    /// A pop-up that appears when the app is first opened. Shared preferences is used to ensure the pop-up does not re-appear between screens
    SharedPreferences.getInstance().then((prefs) {
      final int dialogOpen = prefs.getInt('dialog_open') ?? 0;
      if (dialogOpen == 0) {
        Future.delayed(const Duration(seconds: 2), () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Navigation search'),
                content: const Text(
                    'While only one field is required, please provide as much information as possible to help us navigate you.'),
                actions: [
                  TextButton(
                    child: const Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
                ],
              );
            },
          );
        });
      }
    });
  }

  final CollectionReference doctorsRef =
      FirebaseFirestore.instance.collection('departments');
  List<String> _suggestions = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isTextFieldFilled = false;

  final String _departmentName = 'N/A';

  ///variables representing the ID for each of the dropdown menus
  int _doctorID = -1;
  int _buildingID = -1;
  int _departmentID = -1;

  double _lat = 0.0;
  double _long = 0.0;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Text(
            'What is the reason of appointment?',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              textStyle: const TextStyle(fontSize: 16),
            ),
          ),
        ),
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
                  hintText: 'Search keywords',
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
                    margin: const EdgeInsets.only(top: 60),
                    height: 200,
                    child: ListView.builder(
                      itemCount: _suggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_suggestions[index]),
                          onTap: () async {
                            setState(() {
                              _searchController.text = _suggestions[index];
                              _isTextFieldFilled = false;
                            });
                            ///the global variable _departmentID is set, also changing the department dropdown state
                            await _getDepartmentFromKeyword(
                                _suggestions[index]);
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
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(5),
                  width: 400,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          'What building are you going to?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
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
                          var buildings =
                              snapshot.data!.docs.map((e) => e.data()).toList();

                          ///If the user selects a department, filter the building list by buildings with the specified department
                          if (_departmentID != -1) {
                            buildings = buildings
                                .where((building) => building.departmentList
                                    .contains(_departmentID))
                                .toList();
                          }

                          ///If the user selects a doctor, filter the building list by buildings with the specified doctor
                          if (_doctorID != -1) {
                            buildings = buildings
                                .where((building) =>
                                    building.doctorList.contains(_doctorID))
                                .toList();
                          }

                          return DropdownButton(
                            items: [
                              const DropdownMenuItem(
                                  value: -1, child: Text('N/A')),
                              ...buildings.map((d) {
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
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          'What is the name of the doctor?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
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
                          var doctors =
                          snapshot.data!.docs.map((e) => e.data()).toList();

                          ///If the user selects a department, filter the doctor list by doctors within the specified department
                          if (_departmentID != -1) {
                            doctors = doctors
                                .where((doctor) => doctor.departmentID == _departmentID)
                                .toList();
                          }

                          ///If the user selects a building, filter the doctor list by doctors with the specified building
                          if (_buildingID != -1) {
                            doctors = doctors
                                .where((doctor) => doctor.buildingID == _buildingID)
                                .toList();
                          }
                          return DropdownButton(
                            items: [
                              const DropdownMenuItem(
                                  value: -1, child: Text('N/A')),
                              ...doctors.map((d) {
                                return DropdownMenuItem(
                                  value: d.doctorID,
                                  child: Text('${d.lastName}, ${d.firstName}'),
                                );
                              }).toList(),
                            ],
                            value: _doctorID,
                            onChanged: (int? newValue) async {
                              setState(() {
                                _doctorID = newValue!;
                              });
                              await _getBuildingName(_doctorID);
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
                      Padding(
                        padding: const EdgeInsets.only(top: 15),
                        child: Text(
                          'What department are you going to?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            textStyle: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('departments')
                            .withConverter(
                                fromFirestore: Department.fromFirestore,
                                toFirestore: (Department d, _) =>
                                    d.toFirestore())
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const CircularProgressIndicator();
                          }
                          var departments =
                              snapshot.data!.docs.map((e) => e.data()).toList();

                          ///If the user selects a building, filter the building list by departments with the specified building
                          if (_buildingID != -1) {
                            departments = departments
                                .where((department) => department.buildingList
                                    .contains(_buildingID))
                                .toList();
                          }
                          ///If the user selects a doctor, filter the department list by departments with the specified doctor
                          if (_doctorID != -1) {
                            departments = departments
                                .where((department) =>
                                    department.doctorList.contains(_doctorID))
                                .toList();
                          }

                          return DropdownButton(
                            items: [
                              const DropdownMenuItem(
                                  value: -1, child: Text('N/A')),
                              ...departments.map((d) {
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
                                  builder: (context) => FavoriteMapPage(
                                      lat: _lat,
                                      long: _long,
                                      buildingId: _buildingID,
                                      departmentId: _departmentID,
                                      doctorId: _doctorID),
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
        ),
      ],
    ));
  }

  /// Displays a list of keywords for the dynamic search bar from Firestore given the search [query].
  void _getSuggestions(String query) async {
    List<String> suggestions = [];
    QuerySnapshot querySnapshot = await doctorsRef.get();

    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      List<dynamic> keywords =
          data['keyword_list']; // Assuming 'building_name' is an array field


      for (var name in keywords) {
        String keyword = name.toString();
        if (keyword.toLowerCase().contains(query.toLowerCase())) {
          suggestions.add(keyword);
        }
      }
    }

    setState(() {
      _suggestions = suggestions;
    });
  }

  /// Updates the longitude and latitude variables to specific building's coordinates given its [buildingid].
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
    }
  }

  /// Updates the department id variable to a specific department's id given the [departmentName].
  Future<void> _getDepartmentId(String departmentName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('departments')
        .where('department_name', isEqualTo: departmentName)
        .get();
    if (snapshot.size > 0) {
      final data = snapshot.docs[0].data();
      final id = data['department_id'].toInt();
      setState(() {
        _departmentID = id;
      });
    }
  }

  /// Updates the building name variable to the name of the that a specified building that a specific doctor works in given their [doctorId].
  Future<void> _getBuildingName(int doctorId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .where('doctor_id', isEqualTo: doctorId)
        .get();
    if (snapshot.size > 0) {
      final data = snapshot.docs[0].data();
      final buildingName = data['building'].toString();

      await _getBuildingID(buildingName); // Pass buildingName as the parameter
    }
  }

  /// Updates the building id variable to the id of a specified building given the its [buildingName].
  Future<void> _getBuildingID(String buildingName) async {
    // Change the parameter name
    final snapshot = await FirebaseFirestore.instance
        .collection('buildings')
        .where('building_name', isEqualTo: buildingName) // Use the parameter
        .get();
    if (snapshot.size > 0) {
      final data = snapshot.docs[0].data();
      final id = data['building_id'].toInt();
      setState(() {
        _buildingID = id;
      });
    }
    await _getLatLong(_buildingID);
  }

  /// Updates the department id variable to a specific department's id given the [keyword] the user inputted into
  /// the search bar related to the specific department.
  Future<void> _getDepartmentFromKeyword(String keyword) async {
    // Change the parameter name
    final snapshot = await FirebaseFirestore.instance
        .collection('departments')
        .where('keyword_list', arrayContains: keyword) // Use the parameter
        .get();
    if (snapshot.size > 0) {
      final data = snapshot.docs[0].data();
      final id = data['department_id'].toInt();
      setState(() {
        _departmentID = id;
      });
    }
  }
}
