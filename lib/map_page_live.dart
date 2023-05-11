import 'dart:async';

import 'package:baseflow_plugin_template/baseflow_plugin_template.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_workspace/rotate_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

import 'dart:io' show Platform;

import 'geolocator_test.dart';
import 'search_page.dart';
import 'main.dart';



import 'dart:math' as math;

void main() {
  runApp(const FavoriteMapPage(lat: 42.32754, long: -71.679158));
}

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
  bool _hasPermissions = false;

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
  double targetLat = 42.32754;
  double targetLong = -71.679158;

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
  CompassEvent? _lastRead;
  DateTime? _lastReadAt;
  late double currentLat = 0;
  late double currentLong = 0;
  late final MapController _mapController;
  double targetLat = 42.32754;
  double targetLong = -71.679158;

  @override
  void initState() {
    super.initState();
    _toggleServiceStatusStream();
    _mapController = MapController();
  }

  void _toggleImageVisibility() {
    setState(() {
      _isImageVisible = !_isImageVisible;
    });
  }

  Widget _buildCompass() { // builds compass
    return StreamBuilder<CompassEvent>(
      stream: FlutterCompass.events,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error reading heading: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null) {
          return const Center(
            child: Text("Device does not have sensors !"),
          );
        }

        return SizedBox(
          width: 150,
          height: 150,
          child: Material(
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            elevation: 4.0,
            child: Container(
              padding: const EdgeInsets.all(5.0),
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: (direction * (math.pi / 180) * -1),
                child: Image.asset(
                  'assets/compass.png',
                  height: 150,
                  width: 150,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMap(BuildContext context) { // builds the map

    _getCurrentPosition();
    double? lat = 42.27507; // south road parking garage
    double? lng = -71.76205;

    if (currentLat != 0) {
      lat = currentLat;
      lng = currentLong;
    }

    final coordinates = [LatLng(lat, lng)];
    final coordinatesTarget = [
      const LatLng(42.27748, -71.7642),
      LatLng(lat, lng)
    ];

    final bounds = LatLngBounds.fromPoints(coordinates
        .map((location) =>
            latlong2.LatLng(location.latitude, location.longitude))
        .toList());

    const padding = 10.0;

    return Scaffold(

      appBar: AppBar(
        centerTitle: true,
        title: const Text('You are here right now!'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack (
          children: <Widget>[
            Container(
                width: double.maxFinite,
                height: double.maxFinite,
                color: Colors.black,
                child: Material (child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  //CurrentLocation(mapController: _mapController),
                  const Text("Inputted: <building name>, <doctor name>\nHead to floor <Floor #>",
                  textAlign: TextAlign.center),
                  const SizedBox(height:10),
                  ElevatedButton(
                    onPressed: () => _toggleImageVisibility(),
                    //onPressed: () {
                   //   _isImageVisible = !_isImageVisible;

                    child: const Text('Toggle Image'),
                  ),
                  if (_isImageVisible)
                    SizedBox(
                      width: 600,
                      height: 600,
                      child: Image.asset('assets/UMass_Img.jpg'),
                    ),
                  if (!_isImageVisible)
                    Stack (
                      children: <Widget>[
                        Container(
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
                                    point: latlong2.LatLng(targetLat, targetLong),
                                    width: 100,
                                    height: 100,
                                    builder: (context) => const Icon(
                                      Icons.star,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                              CurrentLocationLayer(),
                            ],
                          ),
                        ),
                        //Expanded(child: _buildCompass()),
                      ],
                    )
                ]))),

          ]
      ),


    );
  }
  
  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(
      height: 10,
    );

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: _buildMap(context),
        floatingActionButton: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: _recenterMap, //_getCurrentPosition,
              child: const Icon(Icons.my_location),
            ),
            sizedBox,
            FloatingActionButton(
              hoverColor: Colors.purple,
              backgroundColor: Colors.blue,
              onPressed: () {
                Navigator.pop(
                  context,
                  MaterialPageRoute(builder: (context) => SearchPage()),
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
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();

    currentLat = position.latitude;
    currentLong = position.longitude;
  }

  // recenters the map around the current location
  _recenterMap() {
    _mapController.move(latlong2.LatLng(currentLat, currentLong), 17);
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

  // toggles whether or not the app is actively determining current location
  void _toggleServiceStatusStream() {
    if (_serviceStatusStreamSubscription == null) {
      final serviceStatusStream = _geolocatorPlatform.getServiceStatusStream();
      _serviceStatusStreamSubscription =
          serviceStatusStream.handleError((error) {
        _serviceStatusStreamSubscription?.cancel();
        _serviceStatusStreamSubscription = null;
      }).listen((serviceStatus) {
        String serviceStatusValue;
        if (serviceStatus == ServiceStatus.enabled) {
          if (positionStreamStarted) {
            _toggleListening();
          }
          serviceStatusValue = 'enabled';
        } else {
          if (_positionStreamSubscription != null) {
            setState(() {
              _positionStreamSubscription?.cancel();
              _positionStreamSubscription = null;
            });
          }
          serviceStatusValue = 'disabled';
        }
      });
    }
  }

  void _doNothing() {}

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream = _geolocatorPlatform.getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }).listen((position) => _doNothing());
      _positionStreamSubscription?.pause();
    }

    setState(() {
      if (_positionStreamSubscription == null) {
        return;
      }

      String statusDisplayValue;
      if (_positionStreamSubscription!.isPaused) {
        _positionStreamSubscription!.resume();
        statusDisplayValue = 'resumed';
      } else {
        _positionStreamSubscription!.pause();
        statusDisplayValue = 'paused';
      }
    });
  }

  @override
  void dispose() {
    if (_positionStreamSubscription != null) {
      _positionStreamSubscription!.cancel();
      _positionStreamSubscription = null;
    }

    super.dispose();
  }

  void _getLastKnownPosition() async {
    final position = await _geolocatorPlatform.getLastKnownPosition();
    if (position != null) {
      currentLat = position.latitude;
      currentLong = position.longitude;
    } else {}
  }

  void _getLocationAccuracy() async {
    final status = await _geolocatorPlatform.getLocationAccuracy();
    _handleLocationAccuracyStatus(status);
  }

  void _requestTemporaryFullAccuracy() async {
    final status = await _geolocatorPlatform.requestTemporaryFullAccuracy(
      purposeKey: "TemporaryPreciseAccuracy",
    );
    _handleLocationAccuracyStatus(status);
  }

  void _handleLocationAccuracyStatus(LocationAccuracyStatus status) {
    String locationAccuracyStatusValue;
    if (status == LocationAccuracyStatus.precise) {
      locationAccuracyStatusValue = 'Precise';
    } else if (status == LocationAccuracyStatus.reduced) {
      locationAccuracyStatusValue = 'Reduced';
    } else {
      locationAccuracyStatusValue = 'Unknown';
    }
  }

  void _openAppSettings() async {
    final opened = await _geolocatorPlatform.openAppSettings();
    String displayValue;

    if (opened) {
      displayValue = 'Opened Application Settings.';
    } else {
      displayValue = 'Error opening Application Settings.';
    }
  }

  void _openLocationSettings() async {
    final opened = await _geolocatorPlatform.openLocationSettings();
    String displayValue;

    if (opened) {
      displayValue = 'Opened Location Settings';
    } else {
      displayValue = 'Error opening Location Settings';
    }
  }
}
