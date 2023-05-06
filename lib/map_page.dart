import 'package:floating_overlay/floating_overlay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlng/latlng.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:flutter_compass/flutter_compass.dart';

import 'globals.dart';
import 'home_page.dart';
import 'main.dart';

class FavoritesPage extends StatefulWidget {
  final double lat;
  final double long;

  FavoritesPage({required this.lat, required this.long});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  double _lat = 0.0;
  double _long = 0.0;
  bool _isImageVisible = false;
  bool _hasPermissions = true;

  CompassEvent? _lastRead;
  DateTime? _lastReadAt;

  void _toggleImageVisibility() {
    setState(() {
      _isImageVisible = !_isImageVisible;
    });
  }

  @override
  void initState() {
    super.initState();
    _lat = widget.lat;
    _long = widget.long;
  }

  @override
  Widget build(BuildContext context) {
    //Future<Position> futurePose = getLatLng();
    // Position pos = await futurePose ;
    // String buildingName = building;
    double lat = _lat; // south road parking garage
    double lng = _long;
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
    final coordinates = [const LatLng(42.27748, -71.7642), LatLng(lat, lng)];
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
      body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Colors.black,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: () => _toggleImageVisibility(),
              child: const Text('Toggle Image'),
            ),
            if (_isImageVisible)
              GestureDetector(
                onTap: () => _toggleImageVisibility(),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'assets/UMass_Img.webp',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            if (!_isImageVisible)
              Container(
                constraints: const BoxConstraints(maxHeight: 400),
                child: FlutterMap(
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
                ),
              ),
            Container(
              width: 50,
            ),
          ])),
      floatingActionButton: FloatingActionButton.extended(
        hoverColor: Colors.purple,
        backgroundColor: Colors.blue,
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
}
