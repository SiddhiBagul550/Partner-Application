import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/vendor_model.dart';

class VendorService {
  static final VendorService _instance = VendorService._internal();
  factory VendorService() => _instance;
  VendorService._internal();

  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  Stream<VendorModel?> currentVendorStream() {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      return Stream.value(null);
    }
    
    return _db
        .collection('vendorApplications')
        .where('email', isEqualTo: user.email)
        .snapshots()
        .map((snap) {
          if (snap.docs.isEmpty) return null;
          return VendorModel.fromFirestore(snap.docs.first);
        });
  }

  Future<VendorModel?> getVendorByEmail(String email) async {
    final snap = await _db
        .collection('vendorApplications')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    
    if (snap.docs.isEmpty) return null;
    return VendorModel.fromFirestore(snap.docs.first);
  }
}
