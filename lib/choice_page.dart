import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_workspace/search_page.dart';
import 'firestore_collections/Building.dart';
import 'map_page_live.dart';

class ChoicePage extends StatefulWidget {
  final int buildingID;
  final int doctorID;
  final int departmentID;

  const ChoicePage(
      {super.key,
      required this.buildingID,
      required this.doctorID,
      required this.departmentID});

  @override
  State<ChoicePage> createState() => _ChoicePageState();
}

class _ChoicePageState extends State<ChoicePage> {
  List<Destination> _destinations = [];
  double _lat = 0.0;
  double _long = 0.0;

  @override
  void initState() {
    super.initState();
    loadDestinations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Expanded(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: ListView.builder(
              itemCount: _destinations.length,
              itemBuilder: (BuildContext context, int index) {
                final item = _destinations[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8.0),
                  decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE0E0E0)),
                      borderRadius: BorderRadius.circular(8.0)),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                              child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.buildingName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Text("${item.campusName} · ${item.departments}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                  )),
                              //Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 8),
                            ],
                          )),
                          Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(8.0),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(item.imageUrl),
                                  ))),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: ElevatedButton(
                          onPressed: () async {
                            print(item.buildingName);
                            print(_lat);
                            await _getLatLong(item.buildingName);
                            print(_lat);
                            if (true) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => FavoriteMapPage(
                                        lat: _lat, long: _long)),
                              );
                            }
                          },
                          child: const Text('Navigate'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        hoverColor: Colors.purple,
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pop(
            context,
            MaterialPageRoute(builder: (context) => const SearchPage()),
          );
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }

  Future<void> loadDestinations() async {
    _destinations = [];
    final destinationList = <Destination>[];

    Query<Building> querySnapshot = FirebaseFirestore.instance
        .collection('buildings')
        .withConverter<Building>(
          fromFirestore: (snapshot, _) => Building.fromFirestore(snapshot, _),
          toFirestore: (building, _) => building.toFirestore(),
        );

    if (widget.buildingID != -1) {
      querySnapshot =
          querySnapshot.where('building_id', isEqualTo: widget.buildingID);
    }

    if (widget.departmentID != -1) {
      querySnapshot = querySnapshot.where('department_list',
          arrayContains: widget.departmentID);
    }

    final snapshot = await querySnapshot.get();
    final buildings = snapshot.docs.map((doc) => doc.data()).toList();

    for (Building b in buildings) {
      final article = Destination(
        buildingName: b.buildingName,
        campusName: b.campus,
        imageUrl: await FirebaseStorage.instance
            .ref('${b.campus}_${b.buildingID}.jpg')
            .getDownloadURL(),
        //imageUrl: 'https://www.bing.com/search?pglt=161&q=gs%3A%2F%2Fapps-for-good---umass-nav.appspot.com%2FInstitute_0.jpg&cvid=724e3f587bc64498b74a62d80fbb43e8&aqs=edge..69i57j69i58.241j0j1&FORM=ANNTA1&PC=U531', // Use download URL as the image URL
        departments: await Future.wait(b.departmentList.map((id) async {
          final departmentDoc = await FirebaseFirestore.instance
              .collection('departments')
              .doc(id.toString())
              .get();
          final departmentData = departmentDoc.data() as Map<String, dynamic>;
          return departmentData['department_name'] as String;
        })).then((names) => names.join(', ')),
      );
      destinationList.add(article);
    }

    setState(() {
      _destinations = destinationList;
    });
  }

  Future<void> _getLatLong(String _buildingName) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('buildings')
        .where('building_name', isEqualTo: _buildingName)
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
      print('No data found for building name: $_buildingName');
    }
  }
}

class Destination {
  String buildingName;
  String campusName;
  String imageUrl;
  String departments;

  Destination({
    required this.buildingName,
    required this.campusName,
    required this.imageUrl,
    required this.departments,
  });
}
