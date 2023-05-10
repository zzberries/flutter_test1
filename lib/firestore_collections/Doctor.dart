import "package:cloud_firestore/cloud_firestore.dart";

class Doctor {
  final String building;
  final String department;
  final int doctorID;
  final String firstName;
  final String lastName;
  final String floorNumber;
  final String phoneNumber;

  Doctor({
    required this.building,
    required this.department,
    required this.doctorID,
    required this.firstName,
    required this.lastName,
    required this.floorNumber,
    required this.phoneNumber,
  });

  factory Doctor.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Doctor(
      building: data?['building'],
      department: data?['department'],
      doctorID: data?['doctor_id'],
      firstName: data?['first_name'],
      lastName: data?['last_name'],
      floorNumber: data?['floor'],
      phoneNumber: data?['phone_number'],
    ); //Doctor
  }

  Map<String, dynamic> toFirestore() {
    return {
      "building": building,
      "department": department,
      "doctor_id": doctorID,
      "first_name": firstName,
      "last_name": lastName,
      "floor": floorNumber,
      "phone_number": phoneNumber,
    };
  }
}
