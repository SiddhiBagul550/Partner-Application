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

  /// Accept an event by adding vendorId to committedVendors
  Future<void> acceptEvent(String eventId, String vendorId) async {
    await _db.collection('events').doc(eventId).update({
      'committedVendors': FieldValue.arrayUnion([vendorId])
    });
  }
}
