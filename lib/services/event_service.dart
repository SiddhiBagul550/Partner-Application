import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final _db = FirebaseFirestore.instance;

  /// Real-time stream of all events, ordered by creation date descending.
  Stream<List<EventModel>> eventsStream() {
    return _db
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  /// Real-time stream of active vendor's committed events securely pulled from Firestore
  Stream<List<EventModel>> vendorEventsStream(String vendorEmail) {
    if (vendorEmail.isEmpty) return Stream.value([]);
    return _db
        .collection('events')
        .where('committedVendors', arrayContains: vendorEmail)
        .snapshots()
        .map((snap) =>
            snap.docs.map((doc) => EventModel.fromFirestore(doc)).toList());
  }

  /// Accept an event securely matching vendor via Firestore transaction.
  Future<void> acceptEvent(String eventId, String vendorEmail, String categoryRole) async {
    final eventRef = _db.collection('events').doc(eventId);

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(eventRef);
      if (!doc.exists) throw Exception('Event does not exist!');

      final data = doc.data()!;
      final committed = List<String>.from(data['committedVendors'] ?? []);
      
      if (committed.contains(vendorEmail)) {
        throw Exception('Already applied');
      }

      final rolesRaw = data['roles'] as List<dynamic>? ?? [];
      final roles = rolesRaw.map((r) => Map<String, dynamic>.from(r)).toList();

      final roleIndex = roles.indexWhere((r) => r['category'] == categoryRole);
      if (roleIndex == -1) throw Exception('Role not found in this event.');

      final targetRole = roles[roleIndex];
      final roleCommitted = List<String>.from(targetRole['committedVendors'] ?? []);
      final roleVacancies = targetRole['vacancies'] as int? ?? 1;

      if (roleCommitted.length >= roleVacancies) {
        throw Exception('This specific role is fully booked');
      }

      // Add vendor to role
      roleCommitted.add(vendorEmail);
      roles[roleIndex]['committedVendors'] = roleCommitted;

      final updates = <String, dynamic>{
        'roles': roles,
        'committedVendors': FieldValue.arrayUnion([vendorEmail]),
      };

      // Check if ALL roles are now full
      bool allFull = true;
      for (var r in roles) {
        final rCommitted = List<String>.from(r['committedVendors'] ?? []);
        final rVac = r['vacancies'] as int? ?? 1;
        if (rCommitted.length < rVac) {
          allFull = false;
          break;
        }
      }

      if (allFull) {
        updates['fullAt'] = FieldValue.serverTimestamp();
      }

      transaction.update(eventRef, updates);
    });
  }

  /// Withdraw from an event safely, restoring vacancies via transaction.
  Future<void> withdrawEvent(String eventId, String vendorEmail) async {
    final eventRef = _db.collection('events').doc(eventId);

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(eventRef);
      if (!doc.exists) throw Exception('Event does not exist!');

      final data = doc.data()!;
      final committed = List<String>.from(data['committedVendors'] ?? []);

      if (!committed.contains(vendorEmail)) {
        throw Exception('You are not committed to this event');
      }

      final rolesRaw = data['roles'] as List<dynamic>? ?? [];
      final roles = rolesRaw.map((r) => Map<String, dynamic>.from(r)).toList();

      for (var i = 0; i < roles.length; i++) {
        final roleCommitted = List<String>.from(roles[i]['committedVendors'] ?? []);
        if (roleCommitted.contains(vendorEmail)) {
          roleCommitted.remove(vendorEmail);
          roles[i]['committedVendors'] = roleCommitted;
        }
      }

      final updates = <String, dynamic>{
        'roles': roles,
        'committedVendors': FieldValue.arrayRemove([vendorEmail]),
      };

      // Since we withdrew, the event cannot be full anymore. Remove fullAt.
      final wasFull = data.containsKey('fullAt');
      if (wasFull) {
        updates['fullAt'] = FieldValue.delete();
      }

      transaction.update(eventRef, updates);
    });
  }
}
