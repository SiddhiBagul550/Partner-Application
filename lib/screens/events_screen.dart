import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/event_service.dart';
import '../models/event_model.dart';
import '../widgets/event_card.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  EventStatus? _filter; // null = all

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AVAILABLE EVENTS',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: AppColors.gold,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Live from Admin',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  color: AppColors.whiteDim,
                ),
              ),
              const SizedBox(height: 14),
              // Filter pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterPill(
                      label: 'All',
                      active: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    const SizedBox(width: 8),
                    _FilterPill(
                      label: 'Upcoming',
                      active: _filter == EventStatus.upcoming,
                      onTap: () =>
                          setState(() => _filter = EventStatus.upcoming),
                    ),
                    const SizedBox(width: 8),
                    _FilterPill(
                      label: 'Ongoing',
                      active: _filter == EventStatus.ongoing,
                      onTap: () =>
                          setState(() => _filter = EventStatus.ongoing),
                    ),
                    const SizedBox(width: 8),
                    _FilterPill(
                      label: 'Completed',
                      active: _filter == EventStatus.completed,
                      onTap: () =>
                          setState(() => _filter = EventStatus.completed),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Divider(color: AppColors.goldBorder.withOpacity(0.4), height: 1),
            ],
          ),
        ),
        // Events list
        Expanded(
          child: StreamBuilder<List<EventModel>>(
            stream: EventService().eventsStream(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                );
              }
              if (snap.hasError) {
                return Center(
                  child: Text(
                    'Error loading events.\n${snap.error}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(color: AppColors.whiteDim),
                  ),
                );
              }
              final events = snap.data ?? [];
              final vendorEmail = FirebaseAuth.instance.currentUser?.email ?? '';

              final filtered = events.where((e) {
                // Rule 1: Vanish after 24 hrs of full
                if (e.isVanishable) return false;

                // Rule 2: Completed only visible if the vendor was part of it
                if (e.status == EventStatus.completed) {
                  if (!e.committedVendors.contains(vendorEmail)) return false;
                }

                // Rule 3: Apply standard pills filter
                if (_filter != null && e.status != _filter) return false;

                return true;
              }).toList();

              if (filtered.isEmpty) {
                return _EmptyState(hasFilter: _filter != null);
              }

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                itemCount: filtered.length,
                itemBuilder: (_, i) => EventCard(event: filtered[i]),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterPill(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.goldGlow : AppColors.black4,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.gold : AppColors.goldBorder.withOpacity(0.5),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: active ? AppColors.gold : AppColors.whiteDim,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasFilter;
  const _EmptyState({required this.hasFilter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📅', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 14),
          Text(
            hasFilter ? 'No events found for this filter.' : 'No events yet.',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.whiteDim,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Events added by admin will appear here.',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.whiteDim.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
