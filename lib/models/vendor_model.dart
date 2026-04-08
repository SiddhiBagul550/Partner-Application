import 'package:cloud_firestore/cloud_firestore.dart';

class VendorModel {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String city;
  final List<String> services;
  final String status;
  final String tier;
  final double rating;
  final double wallet;
  final int projectsCompleted;

  VendorModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
    required this.services,
    required this.status,
    required this.tier,
    required this.rating,
    required this.wallet,
    required this.projectsCompleted,
  });

  factory VendorModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return VendorModel(
      id: doc.id,
      fullName: data['fullName'] ?? 'Vendor User',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      city: data['city'] ?? '',
      services: List<String>.from(data['services'] ?? []),
      status: data['status'] ?? 'pending',
      tier: data['tier'] ?? 'Silver',
      rating: (data['rating'] ?? 0.0).toDouble(),
      wallet: (data['wallet'] ?? 0.0).toDouble(),
      projectsCompleted: data['projectsCompleted'] ?? 0,
    );
  }
}
