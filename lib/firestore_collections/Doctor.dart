import "package:cloud_firestore/cloud_firestore.dart";

/// This class models a doctor with an id, name, and phone number, as well as the building, department, and floor number the
/// doctor works on.
class Doctor {
  // final String building;
  // final String department;
  final int buildingID;
  final int departmentID;
  final int doctorID;
  final String firstName;
  final String lastName;
  final String floorNumber;
  final String phoneNumber;

  /// Creates a doctor with a give [building], [department], [doctorID], [firstName], [lastName],
  /// [floorNumber], and [phoneNumber].
  Doctor({
    // required this.building,
    // required this.department,
    required this.buildingID,
    required this.departmentID,
    required this.doctorID,
    required this.firstName,
    required this.lastName,
    required this.floorNumber,
    required this.phoneNumber,
  });

  /// Converts a [DocumentSnapshot] from Firestore into a [Doctor] object.
  factory Doctor.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Doctor(
      // building: data?['building'],
      // department: data?['department'],
      buildingID: data?['building_id'],
      departmentID: data?['department_id'],
      doctorID: data?['doctor_id'],
      firstName: data?['first_name'],
      lastName: data?['last_name'],
      floorNumber: data?['floor'],
      phoneNumber: data?['phone_number'],
    ); //Doctor
  }

  /// Converts a [Doctor] object into a map that can be stored in Firestore.
  Map<String, dynamic> toFirestore() {
    return {
      // "building": building,
      // "department": department,
      "building_id": buildingID,
      "department_id": departmentID,
      "doctor_id": doctorID,
      "first_name": firstName,
      "last_name": lastName,
      "floor": floorNumber,
      "phone_number": phoneNumber,
    };
  }
}
