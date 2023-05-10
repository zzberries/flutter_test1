import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_workspace/rotate_map.dart';
import 'package:latlng/latlng.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:permission_handler/permission_handler.dart';

import 'main.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _hasPermissions = false;
  CompassEvent? _lastRead;
  DateTime? _lastReadAt;
  late final MapController _mapController;
  double _rotation = 0;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _fetchPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('Flutter Compass'),
        ),
        body: Builder(builder: (context) {
          if (_hasPermissions) {
            return Column(
              children: <Widget>[
                _buildManualReader(),
                Expanded(child: _buildCompass()),
              ],
            );
          } else {
            return _buildPermissionSheet();
          }
        }),
      ),
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
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        double? direction = snapshot.data!.heading;

        // if direction is null, then device does not support this sensor
        // show error message
        if (direction == null)
          return Center(
            child: Text("Device does not have sensors !"),
          );

        final coordinates = [LatLng(42.27748, -71.7642), LatLng(42.27656, -71.76399)];


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
            title: Text('You\'re at the First Road Parking Garage.\nHead to '),
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
          ),
          body: Container(
              width: double.maxFinite,
              height: double.maxFinite,
              color: Colors.black,
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                CurrentLocation(mapController: _mapController),
                if (true)
                  Container(
                    constraints: BoxConstraints(maxHeight: 400),
                    child:
                        Transform.rotate(
                    angle: (direction * (math.pi / 180) * -1),
                    child:   FlutterMap(
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
                            markers: coordinates.map((location) {
                              return Marker(
                                  point: latlong2.LatLng(
                                      location.latitude, location.longitude),
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
                    ),)
                  ),
                Container(
                  width: 50,
                ),
              ])),

        );
      },
    );
  }

  Widget _buildManualReader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          ElevatedButton(
            child: Text('Read Value'),
            onPressed: () async {
              final CompassEvent tmp = await FlutterCompass.events!.first;
              setState(() {
                _lastRead = tmp;
                _lastReadAt = DateTime.now();
              });
            },
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '$_lastRead',
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Text(
                    '$_lastReadAt',
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Location Permission Required'),
          ElevatedButton(
            child: Text('Request Permissions'),
            onPressed: () {
              Permission.locationWhenInUse.request().then((ignored) {
                _fetchPermissionStatus();
              });
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: Text('Open App Settings'),
            onPressed: () {
              openAppSettings().then((opened) {
                //
              });
            },
          )
        ],
      ),
    );
  }



  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
}
