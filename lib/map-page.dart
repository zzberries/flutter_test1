import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlng/latlng.dart';
import 'package:latlong2/latlong.dart' as latlong2;

import 'main.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isImageVisible = false;

  void _toggleImageVisibility() {
    setState(() {
      _isImageVisible = !_isImageVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Future<Position> futurePose = getLatLng();
    // Position pos = await futurePose ;
    String buildingName = building;
    double lat = 42.27507; // south road parking garage
    double lng = -71.76205;
    if (building == "ACC") {
      lat = 42.27514;
      lng = -71.76259;
    } else if (building == "Aaron Lazare") {
      lat = 42.27656;
      lng = -71.76399;
    } else if (building == "Medical School") {
      lat = 42.27756;
      lng = -71.7617;
    }
    //lat = pos?.latitude;
    // double? lng  = pos?.latitude;
    //print(lat.toString()+", "+lng.toString());
    final coordinates = [LatLng(42.27748, -71.7642), LatLng(lat, lng)];
    final coordinatesTarget = [LatLng(42.27748, -71.7642), LatLng(lat, lng)];

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
        title: Text('You\'re at the First Road Parking Garage.\nHead to ' +
            buildingName),
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
              child: Text('Toggle Image'),
            ),
            if (_isImageVisible)
              GestureDetector(
                onTap: () => _toggleImageVisibility(),
                child: Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
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
                constraints: BoxConstraints(maxHeight: 400),
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
            MaterialPageRoute(builder: (context) => const GeneratorPage()),
          );
        },
        label: Text('Back'),
      ),
    );
  }
}

