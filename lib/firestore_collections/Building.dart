import "package:cloud_firestore/cloud_firestore.dart";

class Building {
  final int buildingID;
  final String buildingName;
  final String campus;
  final double lat;
  final double long;
  final List departmentList;
  final List doctorList;

  Building({
    required this.buildingID,
    required this.buildingName,
    required this.campus,
    required this.lat,
    required this.long,
    required this.departmentList,
    required this.doctorList,
  });

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
      doctorList: data?['doctor_list'],
    ); //Building
  }

  Map<String, dynamic> toFirestore() {
    return {
      "building_id": buildingID,
      "building_name": buildingName,
      "campus": campus,
      "lat": lat,
      "long": long,
      "department_list": departmentList,
      "doctor_list": doctorList,
    };
  }
}