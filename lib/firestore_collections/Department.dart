import "package:cloud_firestore/cloud_firestore.dart";

/// This class models a department with an id, name, the list of buildings that contain the department,
/// and a list of keywords related to the department.
class Department {
  final int departmentID;
  final String departmentName;
  final List departmentKeywords;
  final List buildingList;
  final List doctorList;

  /// Creates a department with a given [departmentID], [departmentName], [buildingList], and a list of [departmentKeywords].
  Department({
    required this.departmentID,
    required this.departmentName,
    required this.departmentKeywords,
    required this.buildingList,
    required this.doctorList,
  });

  /// Converts a [DocumentSnapshot] from Firestore into a [Department] object.
  factory Department.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Department(
      departmentID: data?['department_id'],
      departmentName: data?['department_name'],
      departmentKeywords: data?['keyword_list'],
      buildingList: data?['building_list'],
      doctorList: data?['doctor_list'],
    ); //Department
  }

  /// Converts a [Building} object into a map that can be stored in Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      "department_id": departmentID,
      "departmentName": departmentName,
      "keyword_list": departmentKeywords,
      "building_list": buildingList,
      "doctor_list": doctorList,
    };
  }
}
