import 'dart:async';
import 'dart:io' show Platform;

import 'package:baseflow_plugin_template/baseflow_plugin_template.dart';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_workspace/rotate_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlng/latlng.dart';
import 'package:latlong2/latlong.dart' as latlong2;

import 'dart:math' as math;

import 'search_page.dart';

/// Defines the main theme color.
final MaterialColor themeMaterialColor =
    BaseflowPluginExample.createMaterialColor(
        const Color.fromRGBO(48, 49, 60, 1));

void main() {
  runApp(const GeolocatorWidget());
}

/// Example [Widget] showing the functionalities of the geolocator plugin
class GeolocatorWidget extends StatefulWidget {
  /// Creates a new GeolocatorWidget.
  const GeolocatorWidget({Key? key}) : super(key: key);

  /// Utility method to create a page with the Baseflow templating.
  static ExamplePage createPage() {
    return ExamplePage(
        Icons.location_on, (context) => const GeolocatorWidget());
  }

  @override
  State<GeolocatorWidget> createState() => _GeolocatorWidgetState();
}

class _GeolocatorWidgetState extends State<GeolocatorWidget> {
  static const String _kLocationServicesDisabledMessage =
      'Location services are disabled.';
  static const String _kPermissionDeniedMessage = 'Permission denied.';
  static const String _kPermissionDeniedForeverMessage =
      'Permission denied forever.';
  static const String _kPermissionGrantedMessage = 'Permission granted.';

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;
  final List<_PositionItem> _positionItems = <_PositionItem>[];
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

  PopupMenuButton _createActions() {
    return PopupMenuButton(
      elevation: 40,
      onSelected: (value) async {
        switch (value) {
          case 1:
            _getLocationAccuracy();
            break;
          case 2:
            _requestTemporaryFullAccuracy();
            break;
          case 3:
            _openAppSettings();
            break;
          case 4:
            _openLocationSettings();
            break;
          case 5:
            setState(_positionItems.clear);
            break;
          default:
            break;
        }
      },
      itemBuilder: (context) => [
        if (Platform.isIOS)
          const PopupMenuItem(
            value: 1,
            child: Text("Get Location Accuracy"),
          ),
        if (Platform.isIOS)
          const PopupMenuItem(
            value: 2,
            child: Text("Request Temporary Full Accuracy"),
          ),
        const PopupMenuItem(
          value: 3,
          child: Text("Open App Settings"),
        ),
        if (Platform.isAndroid || Platform.isWindows)
          const PopupMenuItem(
            value: 4,
            child: Text("Open Location Settings"),
          ),
        const PopupMenuItem(
          value: 5,
          child: Text("Clear"),
        ),
      ],
    );
  }

  Widget _buildCompass() {
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

  Widget _buildMap(BuildContext context) {
    //Future<Position> futurePose = getLatLng();
    // Position pos = await futurePose ;
    // String buildingName = building;
    _getCurrentPosition();
    double? lat = 42.27507; // south road parking garage
    double? lng = -71.76205;

    if (currentLat != 0) {
      lat = currentLat;
      lng = currentLong;
    }
    // if (building == "ACC") {
    //   lat = 42.27514;
    //   lng = -71.76259;
    // } else if (building == "Aaron Lazare") {
    //   lat = 42.27656;
    //   lng = -71.76399;
    // } else if (building == "Medical School") {
    //   lat = 42.27756;
    //   lng = -71.7617;
    // }

    //lat = pos?.latitude;
    // double? lng  = pos?.latitude;
    //print(lat.toString()+", "+lng.toString());
    final coordinates = [LatLng(lat, lng)];
    final coordinatesTarget = [
      const LatLng(42.27748, -71.7642),
      LatLng(lat, lng)
    ];

    final bounds = LatLngBounds.fromPoints(coordinates
        .map((location) =>
            latlong2.LatLng(location.latitude, location.longitude))
        .toList());

    var latLngCoordinates = coordinates
        .map<LatLng>(
            (location) => LatLng(location.latitude, location.longitude))
        .toList();
    // final bounds = coordinates.map<LatLng>((coordinates.))
    const padding = 50.0;

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
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                CurrentLocation(mapController: _mapController),
                ElevatedButton(
                  //onPressed: () => _toggleImageVisibility(),
                  onPressed: () {
                    _isImageVisible = !_isImageVisible;
                  },
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
                                  point: latlong2.LatLng(currentLat, currentLong),
                                  width: 100,
                                  height: 100,
                                  builder: (context) => const Icon(
                                    Icons.location_pin,
                                    color: Colors.purple,
                                  ),
                                ),
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
                          ],
                        ),
                      ),
                      Expanded(child: _buildCompass()),
                    ],
                  )
              ])),

        ]
      ),


      floatingActionButton: FloatingActionButton.extended(
        hoverColor: Colors.purple,
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.pop(
            context,
            MaterialPageRoute(builder: (context) => SearchPage()),
          );
        },
        label: const Text('Back'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const sizedBox = SizedBox(
      height: 10,
    );

    return BaseflowPluginExample(
        pluginName: 'Geolocator',
        githubURL: 'https://github.com/Baseflow/flutter-geolocator',
        pubDevURL: 'https://pub.dev/packages/geolocator',
        appBarActions: [
          _createActions()
        ],
        pages: [
          ExamplePage(
            Icons.location_on,
            (context) => Scaffold(
              backgroundColor: Theme.of(context).backgroundColor,
              body: _buildMap(context),
              floatingActionButton: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    onPressed: () {
                      positionStreamStarted = !positionStreamStarted;
                      _toggleListening();
                    },
                    tooltip: (_positionStreamSubscription == null)
                        ? 'Start position updates'
                        : _positionStreamSubscription!.isPaused
                            ? 'Resume'
                            : 'Pause',
                    backgroundColor: _determineButtonColor(),
                    child: (_positionStreamSubscription == null ||
                            _positionStreamSubscription!.isPaused)
                        ? const Icon(Icons.play_arrow)
                        : const Icon(Icons.pause),
                  ),
                  sizedBox,
                  FloatingActionButton(
                    onPressed: _recenterMap, //_getCurrentPosition,
                    child: const Icon(Icons.my_location),
                  ),
                  sizedBox,
                ],
              ),
            ),
          )
        ]);
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handlePermission();

    if (!hasPermission) {
      return;
    }

    final position = await _geolocatorPlatform.getCurrentPosition();
    _updatePositionList(
      _PositionItemType.position,
      position.toString(),
    );
    currentLat = position.latitude;
    currentLong = position.longitude;
  }

  _recenterMap() {
    _mapController.move(latlong2.LatLng(currentLat, currentLong), 17);
  }

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      _updatePositionList(
        _PositionItemType.log,
        _kLocationServicesDisabledMessage,
      );

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
        _updatePositionList(
          _PositionItemType.log,
          _kPermissionDeniedMessage,
        );

        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      _updatePositionList(
        _PositionItemType.log,
        _kPermissionDeniedForeverMessage,
      );

      return false;
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    _updatePositionList(
      _PositionItemType.log,
      _kPermissionGrantedMessage,
    );
    return true;
  }

  void _updatePositionList(_PositionItemType type, String displayValue) {
    _positionItems.add(_PositionItem(type, displayValue));
    setState(() {});
  }

  bool _isListening() => !(_positionStreamSubscription == null ||
      _positionStreamSubscription!.isPaused);

  Color _determineButtonColor() {
    return _isListening() ? Colors.green : Colors.red;
  }

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
              _updatePositionList(
                  _PositionItemType.log, 'Position Stream has been canceled');
            });
          }
          serviceStatusValue = 'disabled';
        }
        _updatePositionList(
          _PositionItemType.log,
          'Location service has been $serviceStatusValue',
        );
      });
    }
  }

  void _toggleListening() {
    if (_positionStreamSubscription == null) {
      final positionStream = _geolocatorPlatform.getPositionStream();
      _positionStreamSubscription = positionStream.handleError((error) {
        _positionStreamSubscription?.cancel();
        _positionStreamSubscription = null;
      }).listen((position) => _updatePositionList(
            _PositionItemType.position,
            position.toString(),
          ));
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

      _updatePositionList(
        _PositionItemType.log,
        'Listening for position updates $statusDisplayValue',
      );
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
      _updatePositionList(
        _PositionItemType.position,
        position.toString(),
      );
      currentLat = position.latitude;
      currentLong = position.longitude;
    } else {
      _updatePositionList(
        _PositionItemType.log,
        'No last known position available',
      );
    }
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
    _updatePositionList(
      _PositionItemType.log,
      '$locationAccuracyStatusValue location accuracy granted.',
    );
  }

  void _openAppSettings() async {
    final opened = await _geolocatorPlatform.openAppSettings();
    String displayValue;

    if (opened) {
      displayValue = 'Opened Application Settings.';
    } else {
      displayValue = 'Error opening Application Settings.';
    }

    _updatePositionList(
      _PositionItemType.log,
      displayValue,
    );
  }

  void _openLocationSettings() async {
    final opened = await _geolocatorPlatform.openLocationSettings();
    String displayValue;

    if (opened) {
      displayValue = 'Opened Location Settings';
    } else {
      displayValue = 'Error opening Location Settings';
    }

    _updatePositionList(
      _PositionItemType.log,
      displayValue,
    );
  }
}

enum _PositionItemType {
  log,
  position,
}

class _PositionItem {
  _PositionItem(this.type, this.displayValue);

  final _PositionItemType type;
  final String displayValue;
}