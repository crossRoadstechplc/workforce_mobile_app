import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme_extension.dart';
import '../history_date_utils.dart';

class DayStripPicker extends StatefulWidget {
  const DayStripPicker({
    super.key,
    required this.monthKeys,
    required this.selected,
    required this.onSelected,
    required this.visibleMonth,
    required this.onVisibleMonthChanged,
    this.onPrefetchEarlier,
    this.hasData,
  });

  final List<String> monthKeys;
  final DateTime selected;
  final DateTime visibleMonth;
  final ValueChanged<DateTime> onSelected;
  final ValueChanged<DateTime> onVisibleMonthChanged;
  final ValueChanged<DateTime>? onPrefetchEarlier;
  final bool Function(DateTime day)? hasData;

  @override
  State<DayStripPicker> createState() => _DayStripPickerState();
}

class _DayStripPickerState extends State<DayStripPicker> {
  static const _itemWidth = 50.0;
  static const _itemHeight = 62.0;
  static const _stride = 56.0;

  final _controller = ScrollController();
  bool _scrolledToInitial = false;
  int _lastDayCount = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleScroll);
  }

  @override
  void didUpdateWidget(covariant DayStripPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final days = _days;
    if (days.length > _lastDayCount && _lastDayCount > 0 && _controller.hasClients) {
      final added = days.length - _lastDayCount;
      _controller.jumpTo(_controller.offset + added * _stride);
    }
    _lastDayCount = days.length;

    if (!_scrolledToInitial && days.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected(animate: false));
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleScroll);
    _controller.dispose();
    super.dispose();
  }

  List<DateTime> get _days => buildDayRange(widget.monthKeys, DateTime.now());

  void _handleScroll() {
    if (!_controller.hasClients || _days.isEmpty) return;

    final centerOffset = _controller.offset + _controller.position.viewportDimension / 2;
    final index = (centerOffset / _stride).floor().clamp(0, _days.length - 1);
    final day = _days[index];
    final month = monthStart(day);

    if (!isSameCalendarMonth(month, widget.visibleMonth)) {
      widget.onVisibleMonthChanged(month);
    }

    if (_controller.offset <= 12 && widget.onPrefetchEarlier != null) {
      widget.onPrefetchEarlier!(monthStart(_days.first));
    }
  }

  void _scrollToSelected({bool animate = true}) {
    if (!_controller.hasClients || _days.isEmpty) return;

    final index = _days.indexWhere((d) => isSameCalendarDay(d, widget.selected));
    if (index < 0) return;

    final viewport = _controller.position.viewportDimension;
    final target = index * _stride - (viewport / 2 - _itemWidth / 2);
    final offset = target.clamp(0.0, _controller.position.maxScrollExtent);

    if (animate) {
      _controller.animateTo(offset, duration: const Duration(milliseconds: 280), curve: Curves.easeOut);
    } else {
      _controller.jumpTo(offset);
    }
    _scrolledToInitial = true;
    _lastDayCount = _days.length;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();
    final today = normalizeDate(DateTime.now());
    final days = _days;

    if (days.isEmpty) {
      return const SizedBox(height: 88);
    }

    if (!_scrolledToInitial) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSelected(animate: false));
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(bottom: BorderSide(color: colors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              DateFormat('MMMM yyyy', locale).format(widget.visibleMonth),
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: colors.textPrimary),
            ),
          ),
          SizedBox(
            height: _itemHeight + 12,
            child: ListView.builder(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              itemExtent: _stride,
              itemCount: days.length,
              itemBuilder: (context, index) {
                final day = days[index];
                final isSelected = isSameCalendarDay(day, widget.selected);
                final isToday = isSameCalendarDay(day, today);
                final marked = widget.hasData?.call(day) ?? false;

                return SizedBox(
                  width: _itemWidth,
                  height: _itemHeight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Material(
                      color: isSelected
                          ? colors.primary
                          : colors.muted.withValues(alpha: isToday ? 0.75 : 0.45),
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () => widget.onSelected(day),
                        borderRadius: BorderRadius.circular(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              DateFormat('EEE', locale).format(day),
                              style: TextStyle(
                                fontSize: 10,
                                height: 1.1,
                                fontWeight: FontWeight.w600,
                                color: isSelected ? Colors.white : colors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              DateFormat('d', locale).format(day),
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.1,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : colors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: marked ? (isSelected ? Colors.white : colors.primary) : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
