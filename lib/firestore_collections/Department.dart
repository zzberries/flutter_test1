import "package:cloud_firestore/cloud_firestore.dart";

class Department {
  final int departmentID;
  final String departmentName;
  final List departmentKeywords;
  final List buildingList;

  Department({
    required this.departmentID,
    required this.departmentName,
    required this.departmentKeywords,
    required this.buildingList,
  });

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
    ); //Department
  }

  Map<String, dynamic> toFirestore() {
    return {
      "department_id": departmentID,
      "departmentName": departmentName,
      "keyword_list": departmentKeywords,
      "building_list": buildingList,
    };
  }
}
