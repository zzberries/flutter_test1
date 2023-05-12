import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'search_page.dart';

class FavoriteMapPage extends StatefulWidget {
  final double lat;
  final double long;

  const FavoriteMapPage({super.key, required this.lat, required this.long});

  @override
  State<FavoriteMapPage> createState() => _FavoriteMapPageState();
}

class _FavoritesPageState extends State<FavoriteMapPage> {
  double _lat = 0.0;
  double _long = 0.0;
  bool _isImageVisible = false;

  CompassEvent? _lastRead;
  DateTime? _lastReadAt;

  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  bool positionStreamStarted = false;
  late double currentLat = 0;
  late double currentLong = 0;
  late final MapController _mapController;
  double targetLat = 42.2775;
  double targetLong = -71.7617;

  // toggles whether the image of the target building or the map/compass is displayed
  void _toggleImageVisibility() {
    setState(() {
      _isImageVisible = !_isImageVisible;
    });
  }

  // sets target location to inputted coordinates
  @override
  void initState() {
    super.initState();
    targetLat = _lat = widget.lat;
    targetLong = _long = widget.long;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class _FavoriteMapPageState extends State<FavoriteMapPage> {
  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  StreamSubscription<Position>? _positionStreamSubscription;
  StreamSubscription<ServiceStatus>? _serviceStatusStreamSubscription;
  bool positionStreamStarted = false;
  bool _isImageVisible = false;
  DateTime? _lastReadAt;
  late double currentLat = 0;
  late double currentLong = 0;
  late final MapController _mapController;
  double targetLat = 42.2775;
  double targetLong = -71.7617;
  bool showMarker = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  void _toggleImageVisibility() {
    setState(() {
      _isImageVisible = !_isImageVisible;
    });
  }

  // builds the map
  Widget _buildMap(BuildContext context) {
    // builds the map

    _getCurrentPosition();
    double? lat = 42.27507; // south road parking garage
    double? lng = -71.76205;

    // checks if current location was updated and if so, updates lat and lng accordingly
    if (currentLat != 0) {
      lat = currentLat;
      lng = currentLong;
    }

    final coordinates = [LatLng(lat, lng)];

    // calculates the bounds for the default orientation/location of the map
    final bounds = LatLngBounds.fromPoints(coordinates
        .map((location) =>
            latlong2.LatLng(location.latitude, location.longitude))
        .toList());

    const padding = 10.0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
            "Inputted: <building name>, <doctor name>\nHead to floor <Floor #>",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18)),
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
                    SizedBox(
                      width: 600,
                      height: 600,
                      child: Image.asset('assets/UMass_Img.jpg'),
                    ),
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
                                top: padding +
                                    MediaQuery.of(context).padding.top,
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
                    )
                ]))),
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
    // buttons to recenter the map and go back to the previous page
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
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

  // updates currentLat and currentLong
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

  // recenters the map around the current location
  _recenterMap() async {
    if (await _handlePermission()) {
      showMarker = true;
      _mapController.move(latlong2.LatLng(currentLat, currentLong), 17);
    }
  }

  // recenters the map around the target location
  _recenterMapTarget() async {
    if (await _handlePermission()) {
      showMarker = true;
      _mapController.move(latlong2.LatLng(widget.lat, widget.long), 17);
    }
  }

  // returns whether or not permissions are enabled to access current location
  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.

      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await _geolocatorPlatform.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return true;
  }

  bool _isListening() => !(_positionStreamSubscription == null ||
      _positionStreamSubscription!.isPaused);

  Color _determineButtonColor() {
    return _isListening() ? Colors.green : Colors.red;
  }
}
