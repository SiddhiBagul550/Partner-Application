import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';

// Dummy vendor ID for prototype since real auth is not yet implemented
const String currentVendorId = 'dummy_vendor_123';

class EventCard extends StatelessWidget {
  final EventModel event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(event.status);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.black4,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.6)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Gold left accent bar
            Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: AppColors.darkGoldGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + status & vacancies row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _StatusBadge(status: event.status, colors: colors),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.black4,
                                border: Border.all(
                                    color: AppColors.goldBorder.withOpacity(0.4)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${event.filledCount} / ${event.vacancies} Filled',
                                style: GoogleFonts.dmSans(
                                  fontSize: 9,
                                  color: AppColors.whiteDim,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // City + category
                    Row(
                      children: [
                        _MetaChip('📍 ${event.city}'),
                        const SizedBox(width: 8),
                        _MetaChip(event.category),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Date
                    Text(
                      event.formattedDate,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.whiteDim,
                      ),
                    ),
                    if (event.description != null &&
                        event.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        event.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.whiteDim.withOpacity(0.7),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    // Budget + apply row
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) =>
                              AppColors.goldGradient.createShader(b),
                          child: Text(
                            event.formattedBudget,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Budget',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: AppColors.whiteDim,
                          ),
                        ),
                        const Spacer(),
                        if (event.status == EventStatus.upcoming)
                          _ApplyButton(event: event),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Color> _statusColors(EventStatus s) {
    switch (s) {
      case EventStatus.ongoing:
        return {'bg': const Color(0x1F4ADE80), 'text': const Color(0xFF4ADE80)};
      case EventStatus.completed:
        return {'bg': const Color(0x1F93C5FD), 'text': const Color(0xFF93C5FD)};
      default:
        return {'bg': AppColors.goldGlow, 'text': AppColors.gold};
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final EventStatus status;
  final Map<String, Color> colors;
  const _StatusBadge({required this.status, required this.colors});

  @override
  Widget build(BuildContext context) {
    final label = status == EventStatus.upcoming
        ? 'Upcoming'
        : status == EventStatus.ongoing
            ? 'Ongoing'
            : 'Completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors['text']!.withOpacity(0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: colors['text'],
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  const _MetaChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.black5,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          color: AppColors.whiteDim,
        ),
      ),
    );
  }
}

class _ApplyButton extends StatefulWidget {
  final EventModel event;
  const _ApplyButton({required this.event});

  @override
  State<_ApplyButton> createState() => _ApplyButtonState();
}

class _ApplyButtonState extends State<_ApplyButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final hasApplied = widget.event.committedVendors.contains(currentVendorId);
    final isFull = widget.event.isFull;
    final isDisabled = hasApplied || isFull || _isLoading;

    final String buttonText;
    if (hasApplied) {
      buttonText = 'Applied';
    } else if (isFull) {
      buttonText = 'Filled';
    } else if (_isLoading) {
      buttonText = '...';
    } else {
      buttonText = 'Apply';
    }

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () async {
              setState(() => _isLoading = true);
              try {
                await EventService().acceptEvent(widget.event.id, currentVendorId);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Applied for "${widget.event.name}"',
                          style: GoogleFonts.dmSans(color: AppColors.black)),
                      backgroundColor: AppColors.gold,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to apply. Try again.',
                          style: GoogleFonts.dmSans(color: Colors.white)),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
              color: isDisabled
                  ? AppColors.whiteDim.withOpacity(0.3)
                  : AppColors.gold),
          borderRadius: BorderRadius.circular(10),
          color: isDisabled ? AppColors.whiteDim.withOpacity(0.1) : null,
        ),
        child: Text(
          buttonText,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDisabled
                ? AppColors.whiteDim.withOpacity(0.6)
                : AppColors.gold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
