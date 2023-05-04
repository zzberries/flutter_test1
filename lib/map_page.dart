<<<<<<< Updated upstream
=======
import 'package:floating_overlay/floating_overlay.dart';
import 'package:flutter/cupertino.dart';
>>>>>>> Stashed changes
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlng/latlng.dart';
import 'package:latlong2/latlong.dart' as latlong2;

import 'main.dart';
import 'home_page.dart';
import 'dart:math' as math;

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  bool _isImageVisible = false;
  bool _hasPermissions = true;
  CompassEvent? _lastRead;
  DateTime? _lastReadAt;


  void _toggleImageVisibility() {
    setState(() {
      _isImageVisible = !_isImageVisible;
    }
    );
  }

  @override
  void initState() {
    super.initState();


  }


  @override
  Widget build(BuildContext context) {
    //Future<Position> futurePose = getLatLng();
    // Position pos = await futurePose ;
    // String buildingName = building;
    double lat = 42.27507; // south road parking garage
    double lng = -71.76205;
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

    final controller = FloatingOverlayController.absoluteSize(
      maxSize: const Size(200, 200),
      minSize: const Size(100, 100),
      start: Offset.zero,
      padding: const EdgeInsets.all(20.0),
      constrained: true,
    );
    controller.show();



    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('You are here right now!'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Container(
          width: double.maxFinite,
          height: double.maxFinite,
          color: Colors.black,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              //onPressed: () => _toggleImageVisibility(),
              onPressed: (){
                _isImageVisible = !_isImageVisible;
                //controller.show();
              },
              child: Text('Toggle Image'),
            ),
            Expanded(child: _buildCompass()),
            if (_isImageVisible)
              GestureDetector(
                onTap: () => _toggleImageVisibility(),
                child: Container(
                  width: 600,
                  height: 800,
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
                constraints: BoxConstraints(maxHeight: 600),
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
        label: Text('Back'),
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

        return Material(
          shape: CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 4.0,
          child: Container(
            padding: EdgeInsets.all(16.0),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: Transform.rotate(
              angle: (direction * (math.pi / 180) * -1),
              child: Image.asset('assets/compass.jpg'),
            ),
          ),
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
}
