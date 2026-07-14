import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../viewmodel/admin_monthly_tracking_viewmodel.dart';
import 'package:intl/intl.dart';

class AdminCalendarViewScreen extends StatefulWidget {
  const AdminCalendarViewScreen({super.key});

  @override
  State<AdminCalendarViewScreen> createState() => _AdminCalendarViewScreenState();
}

class _AdminCalendarViewScreenState extends State<AdminCalendarViewScreen> {
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Kick off the real month-range fetch as soon as this screen opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminMonthlyTrackingViewModel>().setFocusedMonth(_focusedDay);
    });
  }

  String _dayKey(DateTime d) =>
      "${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AdminMonthlyTrackingViewModel>();
    final summary = vm.calendarSummary;

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Calendar View (Admin)",
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.calendar_month, color: Colors.black),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.chevron_left, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, _focusedDay.day);
                              });
                              vm.setFocusedMonth(_focusedDay);
                            },
                          ),
                          Text(
                            DateFormat.yMMMM().format(_focusedDay),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.chevron_right, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, _focusedDay.day);
                              });
                              vm.setFocusedMonth(_focusedDay);
                            },
                          ),
                        ],
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime.now();
                          });
                          vm.setCalendarDate(_focusedDay);
                          vm.setFocusedMonth(_focusedDay);
                        },
                        child: const Text("Today", style: TextStyle(color: Colors.black87)),
                      )
                    ],
                  ),
                  const SizedBox(height: 16),
                  TableCalendar(
                    firstDay: DateTime.utc(2020, 10, 16),
                    lastDay: DateTime.utc(2030, 3, 14),
                    focusedDay: _focusedDay,
                    currentDay: vm.selectedCalendarDate,
                    headerVisible: false,
                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekdayStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                      weekendStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF66BB6A), width: 2),
                        shape: BoxShape.circle,
                      ),
                      todayTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      defaultTextStyle: const TextStyle(color: Colors.black87),
                      weekendTextStyle: const TextStyle(color: Colors.black87),
                      outsideDaysVisible: false,
                    ),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                      vm.setCalendarDate(selectedDay);
                    },
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, date, focusedDay) {
                        final dayData = vm.calendarMonthSummary[_dayKey(date)];
                        final bool hasOvulation = dayData?["hasOvulation"] == true;
                        if (!hasOvulation) return null; // fall through to default rendering
                        return Center(
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xFF66BB6A), width: 2),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "${date.day}",
                              style: const TextStyle(color: Colors.black87),
                            ),
                          ),
                        );
                      },
                      markerBuilder: (context, date, events) {
                        // Real data only: a day with no entry in calendarMonthSummary
                        // has no logs at all, so it gets no markers - never a default/fake one.
                        final dayData = vm.calendarMonthSummary[_dayKey(date)];
                        final bool hasPeriod = dayData?["hasPeriod"] == true;
                        final bool hasSymptoms = dayData?["hasSymptoms"] == true;
                        // NOTE: Ovulation Day is rendered via defaultBuilder above (border
                        // circle around the day number), matching the legend's visual style.
                        // NOTE: Fertile Window is not yet backed by real per-day data - the
                        // repo has no fertile-window calculation at the calendar-day level
                        // (it requires running CycleAnalyticsEngine per user per day, the way
                        // getOvulationAnalytics does for its aggregate stats). Left off rather
                        // than faked; wire this up once that's available for daily granularity.

                        if (dayData == null) return const SizedBox();

                        return Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (hasPeriod)
                                Container(
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFCDD2),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              if (hasSymptoms)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(width: 4, height: 4, margin: const EdgeInsets.all(1), decoration: const BoxDecoration(color: Color(0xFF9C27B0), shape: BoxShape.circle)),
                                    Container(width: 4, height: 4, margin: const EdgeInsets.all(1), decoration: const BoxDecoration(color: Color(0xFF9C27B0), shape: BoxShape.circle)),
                                  ],
                                ),
                              const SizedBox(height: 4),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem(const Color(0xFFFFCDD2), "Period Days", isCircle: true),
                      _buildLegendItem(const Color(0xFFC8E6C9), "Fertile Window", isCircle: true),
                      _buildLegendItem(const Color(0xFF66BB6A), "Ovulation Day", isCircle: false, isBorderOnly: true),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(const Color(0xFF9C27B0), "Logged Symptoms", isCircle: true, size: 6),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Day Summary (${DateFormat.yMMMd().format(vm.selectedCalendarDate)})",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (summary['hasOvulation'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F8E9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.eco, color: Color(0xFF66BB6A), size: 16),
                                SizedBox(width: 6),
                                Text("Ovulation Day", style: TextStyle(color: Color(0xFF4CAF50), fontSize: 12, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        const Text("Symptoms Logged", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (summary['topSymptoms'] != null)
                          ...(summary['topSymptoms'] as List).map((symptom) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(symptom['name'], style: const TextStyle(color: Colors.black87)),
                                  Text(symptom['intensity'], style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            );
                          }),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Total Logs", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text("${summary['totalLogsUsers'] ?? 0} Users", style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isCircle = false, bool isBorderOnly = false, double size = 12}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isBorderOnly ? Colors.transparent : color,
            shape: BoxShape.circle,
            border: isBorderOnly ? Border.all(color: color, width: 2) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }
}