import "package:cloud_firestore/cloud_firestore.dart";

/// This class models a building with an Id, name, coordinates, the campus it is located on, and the departments
/// located in that building.
class Building {
  final int buildingID;
  final String buildingName;
  final String campus;
  final double lat;
  final double long;
  final List departmentList;

  /// Creates a building with a given [buildingID], [buildingName], [campus], coordinates of [lat] and [long], and [departmentList].
  Building({
    required this.buildingID,
    required this.buildingName,
    required this.campus,
    required this.lat,
    required this.long,
    required this.departmentList,
  });

  /// Converts a [DocumentSnapshot] from Firestore into a [Building] object.
  factory Building.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options,
      ) {
    final data = snapshot.data();
    return Building(
      buildingID: data?['building_id'],
      buildingName: data?['building_name'],
      campus: data?['campus'],
      lat: data?['lat'],
      long: data?['long'],
      departmentList: data?['department_list'],
    ); //Building
  }

  /// Converts a [Building} object into a map that can be stored in Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      "building_id": buildingID,
      "building_name": buildingName,
      "campus": campus,
      "lat": lat,
      "long": long,
      "department_list": departmentList,
    };
  }
}