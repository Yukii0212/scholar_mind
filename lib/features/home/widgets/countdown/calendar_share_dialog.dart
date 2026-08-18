import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart' hide ShareResult;

import '../../../../core/theme/app_design.dart';
import '../../../countdown/domain/countdown_item.dart';
import 'dashboard_calendar_grid.dart';

/// A shareable snapshot of one month of the countdown calendar, captured as
/// an image. Unlike the in-app calendar (dots only -- you have to tap a date
/// to see what's due), this bakes a legend of every countdown in the month
/// directly into the image, so it's actually useful to someone who doesn't
/// have ScholarMind installed.
class CalendarShareDialog extends StatefulWidget {
  const CalendarShareDialog({
    super.key,
    required this.displayedMonth,
    required this.days,
    required this.countdowns,
  });

  final DateTime displayedMonth;
  final List<DateTime?> days;

  /// Already scoped to non-completed countdowns due within [displayedMonth]
  /// -- see [DashboardCalendarPage]'s call site.
  final List<CountdownItem> countdowns;

  @override
  State<CalendarShareDialog> createState() => _CalendarShareDialogState();
}

class _CalendarShareDialogState extends State<CalendarShareDialog> {
  final _boundaryKey = GlobalKey();

  bool _busy = false;

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<MapEntry<DateTime, List<CountdownItem>>> get _groupedByDate {
    final byDate = <DateTime, List<CountdownItem>>{};

    for (final item in widget.countdowns) {
      final key = DateTime(
        item.dueDate.year,
        item.dueDate.month,
        item.dueDate.day,
      );

      byDate.putIfAbsent(key, () => []).add(item);
    }

    final entries = byDate.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (final entry in entries) {
      entry.value.sort((a, b) {
        final priority = b.priority.compareTo(a.priority);
        if (priority != 0) return priority;
        return a.title.compareTo(b.title);
      });
    }

    return entries;
  }

  Future<Uint8List?> _captureImage() async {
    final boundary =
        _boundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return byteData?.buffer.asUint8List();
  }

  Future<void> _saveToGallery() async {
    setState(() => _busy = true);

    try {
      final bytes = await _captureImage();

      if (bytes == null) {
        throw Exception('Could not render the calendar.');
      }

      await Gal.putImageBytes(
        bytes,
        name:
            'scholarmind_calendar_${DateFormat('yyyy_MM').format(widget.displayedMonth)}',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved to gallery')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save calendar: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _shareImage() async {
    setState(() => _busy = true);

    try {
      final bytes = await _captureImage();

      if (bytes == null) {
        throw Exception('Could not render the calendar.');
      }

      final directory = await getTemporaryDirectory();

      final file = File(
        '${directory.path}/scholarmind_calendar_${DateFormat('yyyy_MM').format(widget.displayedMonth)}.png',
      );

      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              "My ${DateFormat('MMMM yyyy').format(widget.displayedMonth)} deadlines, from ScholarMind.",
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not share calendar: $e')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.scholarPalette;
    final grouped = _groupedByDate;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Share this month',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                Text(
                  'Renders an image of this month with a legend of every '
                  'deadline, so people without ScholarMind can read it too.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textMuted,
                      ),
                ),
                const Gap(16),
                RepaintBoundary(
                  key: _boundaryKey,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: palette.stroke),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const ScholarIconBadge(
                              icon: Icons.calendar_month_rounded,
                              size: 34,
                            ),
                            const Gap(10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    DateFormat('MMMM yyyy')
                                        .format(widget.displayedMonth),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                  Text(
                                    'ScholarMind Countdown',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelSmall
                                        ?.copyWith(color: palette.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Gap(14),
                        Row(
                          children: const [
                            'Mon',
                            'Tue',
                            'Wed',
                            'Thu',
                            'Fri',
                            'Sat',
                            'Sun',
                          ].map((weekday) {
                            return Expanded(
                              child: Center(
                                child: Text(
                                  weekday,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: palette.textMuted,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const Gap(8),
                        DashboardCalendarGrid(
                          days: widget.days,
                          selectedDate: DateTime(0),
                          eventCountBuilder: (date) {
                            final count = widget.countdowns
                                .where((item) => _isSameDate(item.dueDate, date))
                                .length;

                            if (count == 0) return 0;
                            if (count == 1) return 1;
                            return 2;
                          },
                          onDateSelected: (_) {},
                        ),
                        const Gap(16),
                        Divider(color: palette.stroke),
                        const Gap(10),
                        Text(
                          'What\'s due',
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const Gap(8),
                        if (grouped.isEmpty)
                          Text(
                            'No deadlines this month.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: palette.textMuted,
                                ),
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final entry in grouped) ...[
                                Text(
                                  DateFormat('EEE, d MMM').format(entry.key),
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(fontWeight: FontWeight.w800),
                                ),
                                const Gap(2),
                                for (final item in entry.value)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8,
                                      bottom: 4,
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '•  ',
                                          style: TextStyle(color: palette.textMuted),
                                        ),
                                        Expanded(
                                          child: Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: item.title,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                ),
                                                TextSpan(
                                                  text: '  (${item.type.label})',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        color: palette.textMuted,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const Gap(6),
                              ],
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const Gap(18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _saveToGallery,
                      icon: const Icon(Icons.download_rounded),
                      label: const Text('Save'),
                    ),
                    const Gap(12),
                    OutlinedButton.icon(
                      onPressed: _busy ? null : _shareImage,
                      icon: const Icon(Icons.ios_share_rounded),
                      label: const Text('Share'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
