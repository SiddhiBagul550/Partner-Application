import 'package:cloud_firestore/cloud_firestore.dart';

enum DurationType { halfDay, fullDay, multiDay }

enum EventStatus { upcoming, ongoing, completed }

class EventRole {
  final String category;
  final int vacancies;
  final List<String> committedVendors;

  EventRole({required this.category, required this.vacancies, required this.committedVendors});

  factory EventRole.fromMap(Map<String, dynamic> data) {
    return EventRole(
      category: data['category'] ?? '',
      vacancies: data['vacancies'] ?? 1,
      committedVendors: List<String>.from(data['committedVendors'] ?? []),
    );
  }

  bool get isFull => committedVendors.length >= vacancies;
}

class EventModel {
  final String id;
  final String name;
  final String city;
  final String date;
  final String? dateEnd;
  final DurationType durationType;
  final String? timeSlot; // 'morning' | 'evening'
  final double budget;
  final List<EventRole> roles;
  final String? description;
  final EventStatus _dbStatus;
  final List<String> committedVendors;
  final Timestamp? createdAt;
  final Timestamp? fullAt;

  int get vacancies => roles.fold(0, (sum, role) => sum + role.vacancies);
  bool get isFull => roles.every((role) => role.isFull);
  int get filledCount => committedVendors.length;

  EventStatus get status {
    if (_dbStatus == EventStatus.completed) return EventStatus.completed;
    if (date.isEmpty) return _dbStatus;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    DateTime? startDate;
    DateTime? endDate;
    
    try {
      startDate = DateTime.parse(date);
      startDate = DateTime(startDate.year, startDate.month, startDate.day);
      
      if (dateEnd != null && dateEnd!.isNotEmpty) {
        endDate = DateTime.parse(dateEnd!);
        endDate = DateTime(endDate.year, endDate.month, endDate.day);
      } else {
        endDate = startDate;
      }
    } catch (_) {
      return _dbStatus;
    }

    if (today.isBefore(startDate)) {
      return EventStatus.upcoming;
    } else if (today.isAfter(endDate)) {
      return EventStatus.completed;
    } else {
      return EventStatus.ongoing;
    }
  }
  
  bool get isVanishable {
    if (!isFull || fullAt == null) return false;
    final diff = DateTime.now().difference(fullAt!.toDate());
    return diff.inHours >= 24;
  }

  EventModel({
    required this.id,
    required this.name,
    required this.city,
    required this.date,
    this.dateEnd,
    required this.durationType,
    this.timeSlot,
    required this.budget,
    required this.roles,
    this.description,
    required EventStatus status,
    this.committedVendors = const [],
    this.createdAt,
    this.fullAt,
  }) : _dbStatus = status;

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      name: d['name'] ?? '',
      city: d['city'] ?? '',
      date: d['date'] ?? '',
      dateEnd: d['dateEnd'],
      durationType: _parseDuration(d['durationType']),
      timeSlot: d['timeSlot'],
      budget: (d['budget'] ?? 0).toDouble(),
      roles: (d['roles'] as List<dynamic>?)?.map((r) => EventRole.fromMap(r)).toList() ?? [],
      description: d['description'],
      status: _parseStatus(d['status']),
      committedVendors: List<String>.from(d['committedVendors'] ?? []),
      createdAt: d['createdAt'],
      fullAt: d['fullAt'],
    );
  }

  static DurationType _parseDuration(String? val) {
    switch (val) {
      case 'half_day':
        return DurationType.halfDay;
      case 'multi_day':
        return DurationType.multiDay;
      default:
        return DurationType.fullDay;
    }
  }

  static EventStatus _parseStatus(String? val) {
    switch (val) {
      case 'ongoing':
        return EventStatus.ongoing;
      case 'completed':
        return EventStatus.completed;
      default:
        return EventStatus.upcoming;
    }
  }

  String get formattedBudget {
    if (budget >= 100000) return '₹${(budget / 100000).toStringAsFixed(1)}L';
    if (budget >= 1000) return '₹${(budget / 1000).toStringAsFixed(0)}K';
    return '₹${budget.toStringAsFixed(0)}';
  }

  String get formattedDate {
    if (date.isEmpty) return '—';
    try {
      final dt = DateTime.parse(date);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final base = '${dt.day.toString().padLeft(2, '0')} ${months[dt.month - 1]} ${dt.year}';

      if (durationType == DurationType.halfDay) {
        final slot = timeSlot == 'morning' ? '🌅 Morning' : '🌆 Evening';
        return '📅 $base · $slot';
      }
      if (durationType == DurationType.multiDay && dateEnd != null) {
        final dtEnd = DateTime.parse(dateEnd!);
        final endBase = '${dtEnd.day.toString().padLeft(2, '0')} ${months[dtEnd.month - 1]} ${dtEnd.year}';
        return '📅 $base → $endBase';
      }
      return '📅 $base';
    } catch (_) {
      return '📅 $date';
    }
  }

  String get statusLabel {
    switch (status) {
      case EventStatus.upcoming:
        return 'Upcoming';
      case EventStatus.ongoing:
        return 'Ongoing';
      case EventStatus.completed:
        return 'Completed';
    }
  }
}
