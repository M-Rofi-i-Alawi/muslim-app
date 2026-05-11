import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/tr_service.dart';
import 'package:google_fonts/google_fonts.dart';
import '../viewmodel/kalender_viewmodel.dart';
import '../model/kalender_model.dart';
import '../utils/theme_helper.dart';

const _kTeal = Color(0xFF00A086);
const _kTealDark = Color(0xFF007A68);
const _kTealLight = Color(0xFF00C4A7);
const _kGold = Color(0xFFE8A020);

class HijriCalendarPage extends StatelessWidget {
  const HijriCalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 24 + bottomPadding),
                child: Column(
                  children: [
                    _buildTodayCard(context),
                    const SizedBox(height: 14),
                    _buildMonthSelector(context),
                    const SizedBox(height: 14),
                    _buildCalendarGrid(context),
                    const SizedBox(height: 14),
                    _buildEventsSection(context),
                    const SizedBox(height: 14),
                    _buildDateConverter(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── APP BAR ──────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 8, 16, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_kTealDark, _kTeal, _kTealLight],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrText(
                  'Kalender Hijriah',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                TrText(
                  'Kalender Islam & Konversi Tanggal',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          Text(
            'التقويم',
            style: TextStyle(
              color: Colors.white.withOpacity(0.2),
              fontSize: 22,
              fontFamily: 'serif',
            ),
          ),
        ],
      ),
    );
  }

  // ─── TODAY CARD ───────────────────────────────────────────────────────────
  Widget _buildTodayCard(BuildContext context) {
    return Consumer<HijriCalendarViewModel>(
      builder: (_, vm, __) => Container(
        margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_kTealDark, _kTeal, _kTealLight],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: _kTeal.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TrText(
                'HARI INI',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              vm.currentHijriDate.monthName,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${vm.currentHijriDate.day}',
                  style: GoogleFonts.poppins(
                    fontSize: 70,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    '${vm.currentHijriDate.year} H',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
            Text(
              vm.currentHijriDate.dayName,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 14),
            Container(height: 1, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_rounded,
                    color: Colors.white70, size: 14),
                const SizedBox(width: 6),
                Text(
                  vm.formatGregorianDate(vm.selectedGregorianDate),
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ─── MONTH SELECTOR ───────────────────────────────────────────────────────
  Widget _buildMonthSelector(BuildContext context) {
    return Consumer<HijriCalendarViewModel>(
      builder: (_, vm, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left_rounded),
              onPressed: vm.previousMonth,
              color: _kTeal,
            ),
            Column(
              children: [
                Text(
                  vm.currentMonthName,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: _kTeal,
                  ),
                ),
                Text(
                  '${vm.selectedYear} H',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right_rounded),
              onPressed: vm.nextMonth,
              color: _kTeal,
            ),
          ],
        ),
      ),
    );
  }

  // ─── CALENDAR GRID (FIXED!) ───────────────────────────────────────────────
  Widget _buildCalendarGrid(BuildContext context) {
    return Consumer<HijriCalendarViewModel>(
      builder: (_, vm, __) {
        final daysInMonth = vm.daysInCurrentMonth;
        final firstDayOffset = vm.getFirstDayOffset();
        final totalCells = firstDayOffset + daysInMonth;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [context.tr('Ahd'), context.tr('Sen'), context.tr('Sel'), context.tr('Rab'), context.tr('Kam'), context.tr('Jum'), context.tr('Sab')]
                    .map((d) => Expanded(
                          child: Center(
                            child: Text(
                              d,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: d == context.tr('Jum')
                                    ? _kTeal
                                    : context.colors.textHint,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: totalCells,
                itemBuilder: (_, index) {
                  if (index < firstDayOffset) {
                    return Container();
                  }
                  final day = index - firstDayOffset + 1;
                  final event = vm.getEventForDate(day, vm.selectedMonth);
                  final isToday = day == vm.currentHijriDate.day &&
                      vm.selectedMonth == vm.currentHijriDate.month &&
                      vm.selectedYear == vm.currentHijriDate.year;

                  return Container(
                    decoration: BoxDecoration(
                      color: isToday
                          ? _kTeal
                          : event != null
                              ? _kGold.withOpacity(0.12)
                              : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: event != null && !isToday
                          ? Border.all(color: _kGold.withOpacity(0.4), width: 1)
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        '$day',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight:
                              isToday ? FontWeight.bold : FontWeight.normal,
                          color: isToday
                              ? Colors.white
                              : event != null
                                  ? _kGold
                                  : context.colors.onSurface,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── EVENTS SECTION ───────────────────────────────────────────────────────
  Widget _buildEventsSection(BuildContext context) {
    return Consumer<HijriCalendarViewModel>(
      builder: (_, vm, __) {
        final events = vm.currentMonthEvents;
        if (events.isEmpty) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _kGold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.event_rounded,
                          color: _kGold, size: 18),
                    ),
                    const SizedBox(width: 10),
                    TrText(
                      'Hari Penting Bulan Ini',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: context.colors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: context.colors.divider),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(14),
                itemCount: events.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _buildEventCard(context, events[i]),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEventCard(BuildContext context, IslamicEvent event) {
    final Color color;
    final IconData icon;

    switch (event.category) {
      case 'eid':
        color = const Color(0xFF388E3C);
        icon = Icons.celebration_rounded;
        break;
      case 'ramadan':
        color = const Color(0xFF7B1FA2);
        icon = Icons.nightlight_round;
        break;
      case 'important':
        color = _kGold;
        icon = Icons.star_rounded;
        break;
      default:
        color = _kTeal;
        icon = Icons.event_note_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${event.day}',
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.name,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.description,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: color, size: 18),
        ],
      ),
    );
  }

  // ─── DATE CONVERTER ───────────────────────────────────────────────────────
  Widget _buildDateConverter(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TrText(
            'Konversi Tanggal',
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: context.colors.onSurface),
          ),
          const SizedBox(height: 14),
          Consumer<HijriCalendarViewModel>(
            builder: (_, vm, __) => Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _kTeal.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _kTeal.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TrText(
                              'Masehi',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: context.colors.textSecondary,
                              ),
                            ),
                            Text(
                              vm.formatGregorianDate(vm.selectedGregorianDate),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded,
                          color: _kTeal, size: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TrText(
                              'Hijriah',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: context.colors.textSecondary,
                              ),
                            ),
                            Text(
                              vm.currentHijriDate.fullDate,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _kTeal,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: vm.selectedGregorianDate,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        builder: (ctx, child) => Theme(
                          data: ThemeData.light().copyWith(
                            colorScheme:
                                const ColorScheme.light(primary: _kTeal),
                          ),
                          child: child!,
                        ),
                      );
                      if (date != null) vm.selectDate(date);
                    },
                    icon: const Icon(Icons.calendar_month_rounded,
                        color: Colors.white, size: 18),
                    label: TrText(
                      'Pilih Tanggal Masehi',
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kTeal,
                      padding: const EdgeInsets.all(14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}