import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';
import 'package:latlong2/latlong.dart' as latlong2;

import 'search_page.dart';

/// This class models the map page where users can view where they are and where their destination is.
class FavoriteMapPage extends StatefulWidget {
  final double lat;
  final double long;
  final int buildingId;
  final int departmentId;
  final int doctorId;

  const FavoriteMapPage(
      {super.key,
      required this.lat,
      required this.long,
      required this.buildingId,
      required this.departmentId,
      required this.doctorId});

  @override
  State<FavoriteMapPage> createState() => _FavoriteMapPageState();
}

class _FavoriteMapPageState extends State<FavoriteMapPage> {
  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  bool positionStreamStarted = false;
  bool _isImageVisible = false;
  late double currentLat = 0;
  late double currentLong = 0;
  late final MapController _mapController;
  double targetLat = 42.2775;
  double targetLong = -71.7617;
  String buildingName = "N/A";
  String doctorName = "N/A";
  String floorName = "N/A";
  bool showMarker = false;
  String img = "";

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchData();
  }

  /// Toggles between displaying the image of the building and the map
  void _toggleImageVisibility() {
    setState(() {
      _isImageVisible = !_isImageVisible;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  Future<void> _fetchData() async {
    await _getDoctorName(widget.doctorId);
    await _getFloorName(widget.doctorId);
    await _getBuildingName(widget.buildingId);
    await _getImage(widget.buildingId);
  }

  /// Builds the map
  Widget _buildMap(BuildContext context) {

    _getCurrentPosition();
    double? lat =
        42.27507; // south road parking garage is the default target location
    double? lng = -71.76205;

    /// Checks if current location was updated and if so, updates lat and long accordingly
    if (currentLat != 0) {
      lat = currentLat;
      lng = currentLong;
    }

    final coordinates = [LatLng(lat, lng)];

    /// Calculates the bounds for the default orientation/location of the map
    final bounds = LatLngBounds.fromPoints(coordinates
        .map((location) =>
            latlong2.LatLng(location.latitude, location.longitude))
        .toList());

    const padding = 13.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Expanded(
          child: Text(
              ('Building: $buildingName , Doctor: $doctorName, Floor: $floorName'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10)),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(children: <Widget>[
        Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Colors.black,
          child: Material(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //CurrentLocation(mapController: _mapController),
                if (_isImageVisible)
                  Container(
                      width: 600,
                      height: 600,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: NetworkImage(img),
                          ))),
                if (!_isImageVisible)
                  Expanded(
                    child: Container(
                      constraints: const BoxConstraints(maxHeight: 600),
                      child: FlutterMap(
                        mapController: _mapController,
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
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: latlong2.LatLng(widget.lat, widget.long),
                                width: 100,
                                height: 100,
                                builder: (context) => const Icon(
                                  Icons.star,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          CurrentLocationLayer()
                        ],
                      ),
                    ),
                    //Expanded(child: _buildCompass()),
                  ),
              ],
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(
      height: 10,
    );

    IconData icon = Icons.photo;
    if (_isImageVisible) {
      icon = Icons.map;
    }
    /// Buttons to recenter the map and go back to the previous page
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _buildMap(context),
      floatingActionButton: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _recenterMap,
            child: const Icon(Icons.my_location),
          ),
          sizedBox,
          FloatingActionButton(
            onPressed: _recenterMapTarget,
            child: const Icon(Icons.star),
          ),
          sizedBox,
          FloatingActionButton(
            onPressed: _toggleImageVisibility,
            child: Icon(icon),
          ),
          sizedBox,
          FloatingActionButton(
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
        ],
      ),
    );
  }

  /// Updates current latitude and longitude
  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      showMarker = false;
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();

    currentLat = position.latitude;
    currentLong = position.longitude;
    showMarker = true;
  }

  /// Re-centers the map around the current location
  _recenterMap() async {
    if (await _handlePermission()) {
      showMarker = true;
      _mapController.move(latlong2.LatLng(currentLat, currentLong), 17);
    }
  }

  /// Re-centers the map around the target location
  _recenterMapTarget() async {
    if (await _handlePermission()) {
      showMarker = true;
      _mapController.move(latlong2.LatLng(widget.lat, widget.long), 17);
    }
  }

  /// Returns whether or not permissions are enabled to access current location
  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {

      return false;
    }

    return true;
  }


  /// Updates the doctor name variable given the doctor's [doctorId].
  Future<void> _getDoctorName(int doctorId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .where('doctor_id', isEqualTo: doctorId)
        .get();
    if (snapshot.size > 0) {
      final data = snapshot.docs[0].data();
      final firstName = data['first_name'].toString();
      final lastName = data['last_name'].toString();
      setState(() {
        doctorName = '$firstName $lastName';
      });
    }
  }

  /// Updates the building name variable given the buildings [buildingId].
  Future<void> _getBuildingName(int buildingId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('buildings')
        .where('building_id', isEqualTo: buildingId)
        .get();
    if (snapshot.size > 0) {
      final data = snapshot.docs[0].data();
      final building = data['building_name'].toString();
      setState(() {
        buildingName = building;
      });
    }
  }

  /// Updates the floor name variable to the name of the floor the specified doctor works on
  /// given the doctor's [doctorId].
  Future<void> _getFloorName(int doctorId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .where('doctor_id', isEqualTo: doctorId)
        .get();
    if (snapshot.size > 0) {
      final data = snapshot.docs[0].data();
      final floor = data['floor'].toString();
      setState(() {
        floorName = floor;
      });
    }
  }

  /// Updates the image variable to the image of the building that the specified doctor works in
  /// given the doctor's [doctorId].
  Future<void> _getImage(int doctorId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('buildings')
        .where('building_id', isEqualTo: doctorId)
        .get();
    if (snapshot.size > 0) {
      final data = snapshot.docs[0].data();
      final imgUrl = await FirebaseStorage.instance
          .ref('${data['campus']}_${data['building_id']}.jpg')
          .getDownloadURL();
      setState(() {
        img = imgUrl;
      });
    }
  }
}
