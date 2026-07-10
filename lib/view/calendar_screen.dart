import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_view_model.dart';

/// Color palette
const _bgColor = Color(0xFFF8C8DC);
const _cardColor = Colors.white;
const _accent = Color(0xFFD4658A);
const _accentLight = Color(0xFFF0A0BC);
const _textDark = Color(0xFF3D1A2E);
const _textMid = Color(0xFF9A6070);

/// Nepali date font size (user requested larger Nepali date)
const double _npFontSize = 24.0;

const _affirmations = [
  "You are the main character of your life. Start romanticizing every moment — this is the life you are creating. ✨",
  "You are worthy of everything good coming your way. Keep going, love. 💕",
  "Your body is doing incredible things every day. Be gentle with yourself. 🌸",
  "Healing isn't linear, and that's okay. You are growing even on the hard days. 🌷",
  "You deserve rest just as much as you deserve success. 💗",
  "Every day is a fresh start. Today holds something beautiful for you. 🌺",
  "You are stronger than you think. Trust the process. ✨",
  "Your feelings are valid. Your dreams are valid. You are valid. 💖",
  "Choose yourself today — and every day after. 🎀",
  "Small steps still count. You are making progress. 🌸",
];

class _CalEvent {
  final String type;
  final String label;
  final String icon;
  final Color color;
  const _CalEvent({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _TodoItem {
  String text;
  bool done;
  _TodoItem(this.text, [this.done = false]);
}

class _RoutineItem {
  String title, startTime, endTime, emoji;
  _RoutineItem(this.title, this.startTime, this.endTime, this.emoji);
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  int _viewIndex = 0; // 0=Daily 1=Weekly 2=Monthly
  static const _viewLabels = ['Daily', 'Weekly', 'Monthly'];

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime.now();
  bool _showNepali = false;
  bool _isLoading = true;
  bool _showTodos = false;

  final TextEditingController _noteCtrl = TextEditingController();
  final TextEditingController _todoAddCtrl = TextEditingController();
  final Map<String, String> _savedNotes = {};
  final Map<String, List<_TodoItem>> _todos = {};

  // Routine is now dynamic: user can add/edit/delete items
  final List<_RoutineItem> _routine = [
    _RoutineItem('Yoga 🧘', '7:00 AM', '8:00 AM', '🧘'),
    _RoutineItem('Morning skincare', '8:00 AM', '8:30 AM', '✨'),
    _RoutineItem('Water intake check', '9:00 AM', '9:10 AM', '💧'),
    _RoutineItem('Medication', '9:30 AM', '9:35 AM', '💊'),
    _RoutineItem('Evening walk', '6:00 PM', '6:45 PM', '🚶'),
    _RoutineItem('Night skincare', '9:00 PM', '9:20 PM', '🌙'),
  ];

  final Map<String, List<_CalEvent>> _events = {};

  // event colours
  static const _cPeriod = Color(0xFFE57373);
  static const _cOvulation = Color(0xFFFFB74D);
  static const _cDerma = Color(0xFF64B5F6);
  static const _cMed = Color(0xFF81C784);
  static const _cAcne = Color(0xFFBA68C8);
  static const _cWater = Color(0xFF4FC3F7);
  static const _cMeal = Color(0xFFFFD54F);
  static const _cJournal = Color(0xFFF06292);

  @override
  void initState() {
    super.initState();
    _animCtrl =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();

    // Safe provider read: if provider missing, show UI without Firestore load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final userVM = context.read<UserViewModel>();
        if (userVM.userId != null) {
          _loadAll(userVM.userId!);
        } else {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        debugPrint('Calendar: UserViewModel provider not found, skipping Firestore load -> $e');
        if (mounted) setState(() => _isLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _noteCtrl.dispose();
    _todoAddCtrl.dispose();
    super.dispose();
  }

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _eMonth(int m) =>
      const ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'][m - 1];

  String _npMonth(int m) =>
      const ['बैशाख', 'जेठ', 'असार', 'श्रावण', 'भदौ', 'आश्विन', 'कार्तिक', 'मंसिर', 'पुष', 'माघ', 'फाल्गुन', 'चैत'][(m - 1).clamp(0, 11)];

  String _npNum(int n) {
    const d = ['०', '१', '२', '३', '४', '५', '६', '७', '८', '९'];
    return n.toString().split('').map((c) => d[int.parse(c)]).join();
  }

  NepaliDateTime _np(DateTime d) => d.toNepaliDateTime();

  void _addEv(String key, _CalEvent e) => _events.putIfAbsent(key, () => []).add(e);

  String? _extractDate(Map<String, dynamic> data) {
    for (final f in [
      'date',
      'startDate',
      'start_date',
      'periodDate',
      'ovulationDate',
      'visitDate',
      'appointmentDate',
      'takenAt',
      'createdAt'
    ]) {
      final v = data[f];
      if (v is String && v.length >= 10) return v.substring(0, 10);
      if (v is Timestamp) return _key(v.toDate());
    }
    return null;
  }

  bool _isMyUser(Map<String, dynamic> data, String userId) {
    final uid = (data['userId'] as String?) ?? (data['user_id'] as String?) ?? '';
    return uid.isEmpty || uid == userId;
  }

  // Non-blocking Firestore loader: parallel queries, timeouts, logs
  Future<void> _loadAll(String userId) async {
    setState(() => _isLoading = true);
    final db = FirebaseFirestore.instance;

    Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> safeRoot(String col, {int limit = 200}) async {
      try {
        debugPrint('Calendar: fetching $col ...');
        final snap = await db.collection(col).limit(limit).get().timeout(const Duration(seconds: 8));
        debugPrint('Calendar: fetched ${snap.docs.length} from $col');
        return snap.docs;
      } catch (e) {
        debugPrint('Calendar: failed $col -> $e');
        return [];
      }
    }

    Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>> safeSub(String col, {int limit = 200}) async {
      try {
        debugPrint('Calendar: fetching users/$userId/$col ...');
        final snap = await db.collection('users').doc(userId).collection(col).limit(limit).get().timeout(const Duration(seconds: 8));
        debugPrint('Calendar: fetched ${snap.docs.length} from users/$userId/$col');
        return snap.docs;
      } catch (e) {
        debugPrint('Calendar: failed users/$userId/$col -> $e');
        return [];
      }
    }

    _events.clear();

    final rootFutures = <Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>>[
      safeRoot('period'),
      safeRoot('ovulation'),
      safeRoot('derma_visits'),
      safeRoot('medications'),
      safeRoot('journals'),
    ];

    final rootResults = await Future.wait(rootFutures);

    // process root results
    for (final doc in rootResults[0]) {
      final data = doc.data();
      if (!_isMyUser(data, userId)) continue;
      final k = _extractDate(data);
      if (k == null) continue;
      _addEv(k, const _CalEvent(type: 'period', label: 'Period day 🩸', icon: '🩸', color: _cPeriod));
    }
    for (final doc in rootResults[1]) {
      final data = doc.data();
      if (!_isMyUser(data, userId)) continue;
      final k = _extractDate(data);
      if (k == null) continue;
      _addEv(k, const _CalEvent(type: 'ovulation', label: 'Ovulation day 🥚', icon: '🥚', color: _cOvulation));
    }
    for (final doc in rootResults[2]) {
      final data = doc.data();
      if (!_isMyUser(data, userId)) continue;
      final k = _extractDate(data);
      if (k == null) continue;
      final title = (data['title'] as String?) ?? (data['visitTitle'] as String?) ?? 'Derma Visit';
      _addEv(k, _CalEvent(type: 'derma', label: '$title 🏥', icon: '🏥', color: _cDerma));
    }
    for (final doc in rootResults[3]) {
      final data = doc.data();
      if (!_isMyUser(data, userId)) continue;
      final k = _extractDate(data);
      if (k == null) continue;
      final name = (data['name'] as String?) ?? (data['medicationName'] as String?) ?? 'Medication';
      _addEv(k, _CalEvent(type: 'medication', label: '$name 💊', icon: '💊', color: _cMed));
    }
    for (final doc in rootResults[4]) {
      final data = doc.data();
      if (!_isMyUser(data, userId)) continue;
      final k = _extractDate(data);
      if (k == null) continue;
      _addEv(k, const _CalEvent(type: 'journal', label: 'Journal entry 📝', icon: '📝', color: _cJournal));
    }

    final subFutures = <Future<List<QueryDocumentSnapshot<Map<String, dynamic>>>>>[
      safeSub('acne_tracker'),
      safeSub('water_history'),
      safeSub('meal_tracker'),
    ];

    final subResults = await Future.wait(subFutures);

    for (final doc in subResults[0]) {
      _addEv(doc.id, const _CalEvent(type: 'acne', label: 'Skin tracked ✨', icon: '✨', color: _cAcne));
    }

    for (final doc in subResults[1]) {
      final data = doc.data();
      final l = (data['intake'] as num?)?.toDouble() ?? 0;
      _addEv(doc.id, _CalEvent(type: 'water', label: 'Water: ${l.toStringAsFixed(1)} L 💧', icon: '💧', color: _cWater));
    }

    for (final doc in subResults[2]) {
      final data = doc.data();
      final m = (data['meals'] as List?)?.length ?? 0;
      _addEv(doc.id, _CalEvent(type: 'meal', label: '$m meals logged 🍽️', icon: '🍽️', color: _cMeal));
    }

    if (mounted) setState(() => _isLoading = false);
  }

  List<DateTime?> _monthGrid() {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final days = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final offset = first.weekday % 7;
    final grid = <DateTime?>[
      for (int i = 0; i < offset; i++) null,
      for (int d = 1; d <= days; d++) DateTime(_focusedMonth.year, _focusedMonth.month, d)
    ];
    while (grid.length % 7 != 0) grid.add(null);
    return grid;
  }

  List<DateTime> _weekDays() {
    final start = _selectedDay.subtract(Duration(days: _selectedDay.weekday % 7));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  void _changePage(int delta) {
    _animCtrl.reverse().then((_) {
      if (!mounted) return;
      setState(() => _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta));
      _animCtrl.forward();
    });
  }

  void _selectDay(DateTime d) {
    setState(() {
      _selectedDay = d;
      _noteCtrl.text = _savedNotes[_key(d)] ?? '';
      if (d.month != _focusedMonth.month || d.year != _focusedMonth.year) {
        _focusedMonth = DateTime(d.year, d.month);
      }
    });
  }

  String get _todayAffirmation {
    final idx = DateTime.now().day % _affirmations.length;
    return _affirmations[idx];
  }

  // -------------------------
  // Routine editing helpers
  // -------------------------
  Future<void> _showEditRoutineDialog({int? index}) async {
    final isNew = index == null;
    final titleCtrl = TextEditingController(text: isNew ? '' : _routine[index!].title);
    final startCtrl = TextEditingController(text: isNew ? '' : _routine[index!].startTime);
    final endCtrl = TextEditingController(text: isNew ? '' : _routine[index!].endTime);
    final emojiCtrl = TextEditingController(text: isNew ? '' : _routine[index!].emoji);

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isNew ? 'Add Routine' : 'Edit Routine'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Start Time')),
              TextField(controller: endCtrl, decoration: const InputDecoration(labelText: 'End Time')),
              TextField(controller: emojiCtrl, decoration: const InputDecoration(labelText: 'Emoji')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final t = titleCtrl.text.trim();
              if (t.isEmpty) return;
              if (isNew) {
                setState(() {
                  _routine.add(_RoutineItem(t, startCtrl.text.trim(), endCtrl.text.trim(), emojiCtrl.text.trim()));
                });
              } else {
                setState(() {
                  _routine[index!] = _RoutineItem(t, startCtrl.text.trim(), endCtrl.text.trim(), emojiCtrl.text.trim());
                });
              }
              Navigator.pop(ctx, true);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true) {
      // optionally persist to Firestore or local storage here
    }
  }

  Future<void> _confirmDeleteRoutine(int index) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Routine'),
        content: Text('Delete "${_routine[index].title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      setState(() => _routine.removeAt(index));
      // optionally remove from Firestore/local storage here
    }
  }

  // -------------------------
  // Build UI
  // -------------------------
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: _bgColor,
        body: Center(child: CircularProgressIndicator(color: _accent)),
      );
    }

    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            children: [
              _buildHeader(),
              _buildViewToggle(),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _accent,
        child: const Icon(Icons.add),
        onPressed: () => _showEditRoutineDialog(), // quick add routine
        tooltip: 'Add routine',
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('My Calendar',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textDark)),
            Text('${_eMonth(_focusedMonth.month)} ${_focusedMonth.year}',
                style: const TextStyle(fontSize: 13, color: _textMid)),
          ]),
          const Spacer(),
          GestureDetector(
            onTap: () => setState(() => _showNepali = !_showNepali),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _showNepali ? _accent : _cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accent.withAlpha(128)),
              ),
              child: Text(_showNepali ? 'NP ✓' : 'EN',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _showNepali ? Colors.white : _accent)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: _cardColor.withAlpha(230),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: List.generate(3, (i) {
            final sel = _viewIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _viewIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: sel ? _accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(_viewLabels[i],
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : _textMid)),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (_viewIndex) {
      case 0:
        return _buildDailyView();
      case 1:
        return _buildWeeklyView();
      case 2:
        return _buildMonthlyView();
      default:
        return _buildDailyView();
    }
  }

  Widget _buildDailyView() {
    final selKey = _key(_selectedDay);
    final events = _events[selKey] ?? [];
    final np = _np(_selectedDay);
    final todos = _todos.putIfAbsent(selKey, () => []);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildWeekStrip(),
        const SizedBox(height: 16),
        _affirmationCard(),
        const SizedBox(height: 14),
        Row(children: [
          const Text('TODAY  ',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w700, color: _textMid, letterSpacing: 1.5)),
          // Show English and Nepali with larger Nepali font
          Expanded(
            child: _showNepali
                ? RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${_selectedDay.day} ${_eMonth(_selectedDay.month)}  •  ',
                    style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w500),
                  ),
                  TextSpan(
                    text: '${_npNum(np.day)} ${_npMonth(np.month)} ${_npNum(np.year)}',
                    style: TextStyle(fontSize: _npFontSize, color: _accent, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            )
                : Text('${_selectedDay.day} ${_eMonth(_selectedDay.month)} ${_selectedDay.year}',
                style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w500)),
          ),
        ]),
        const SizedBox(height: 12),
        if (events.isEmpty)
          _emptyCard('Nothing logged on this day ✨')
        else
          ...events.map((e) => _eventTile(e)),
        const SizedBox(height: 16),
        _todoCard(selKey, todos),
        const SizedBox(height: 16),
        _notesCard(selKey),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWeeklyView() {
    final week = _weekDays();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildWeekStrip(),
        const SizedBox(height: 16),
        ...week.map((day) {
          final k = _key(day);
          final evs = _events[k] ?? [];
          final np = _np(day);
          final isToday = k == _key(DateTime.now());
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(14),
              border: isToday ? Border.all(color: _accent, width: 2) : null,
              boxShadow: [BoxShadow(color: _accent.withAlpha(25), blurRadius: 6, offset: const Offset(0, 2))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isToday ? _accent : _bgColor.withAlpha(30),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                ),
                child: Row(children: [
                  Text(['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][day.weekday % 7],
                      style: TextStyle(fontSize: 11, color: isToday ? Colors.white : _textMid, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text('${day.day}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isToday ? Colors.white : _textDark)),
                  if (_showNepali)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text('${_npNum(np.day)} ${_npMonth(np.month)}',
                          style: TextStyle(fontSize: _npFontSize, color: isToday ? Colors.white70 : _accent)),
                    ),
                ]),
              ),
              if (evs.isEmpty)
                const Padding(padding: EdgeInsets.all(12), child: Text('No events', style: TextStyle(color: _textMid, fontSize: 12)))
              else
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Wrap(spacing: 6, runSpacing: 6, children: evs.map((e) => _eventChip(e)).toList())),
            ]),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMonthlyView() {
    final grid = _monthGrid();
    final selKey = _key(_selectedDay);
    final selEvents = _events[selKey] ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: const Icon(Icons.chevron_left, color: _textMid), onPressed: () => _changePage(-1)),
          Text(
            _showNepali
                ? '${_eMonth(_focusedMonth.month)} ${_focusedMonth.year}  /  ${_npMonth(_np(DateTime(_focusedMonth.year, _focusedMonth.month, 1)).month)}'
                : '${_eMonth(_focusedMonth.month)} ${_focusedMonth.year}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark),
          ),
          IconButton(icon: const Icon(Icons.chevron_right, color: _textMid), onPressed: () => _changePage(1)),
        ]),
        Row(
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textMid)))))
                .toList()),
        const SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
              color: _cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: _accent.withAlpha(30), blurRadius: 8, offset: const Offset(0, 3))]),
          padding: const EdgeInsets.all(6),
          child: Column(
            children: List.generate(grid.length ~/ 7, (row) {
              return Row(
                children: List.generate(7, (col) {
                  final day = grid[row * 7 + col];
                  if (day == null) return const Expanded(child: SizedBox(height: 52));
                  final k = _key(day);
                  final isSel = k == selKey;
                  final isT = k == _key(DateTime.now());
                  final evs = _events[k] ?? [];
                  final nd = _np(day);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDay(day),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: _showNepali ? 58 : 48,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSel ? _accent : isT ? _accentLight.withAlpha(30) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(alignment: Alignment.center, children: [
                          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('${day.day}',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSel || isT ? FontWeight.bold : FontWeight.normal,
                                  color: isSel ? Colors.white : isT ? _accent : _textDark,
                                )),
                            if (_showNepali)
                              Text(_npNum(nd.day),
                                  style: TextStyle(fontSize: _npFontSize, color: isSel ? Colors.white70 : _accent)),
                          ]),
                          if (evs.isNotEmpty)
                            Positioned(
                                bottom: 3,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: evs.take(3).map((e) {
                                    return Container(
                                      width: 4,
                                      height: 4,
                                      margin: const EdgeInsets.symmetric(horizontal: 1),
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: isSel ? Colors.white60 : e.color),
                                    );
                                  }).toList(),
                                )),
                        ]),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ),
        const SizedBox(height: 14),
        if (selEvents.isNotEmpty) ...[
          Text('${_selectedDay.day} ${_eMonth(_selectedDay.month)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textDark)),
          const SizedBox(height: 8),
          ...selEvents.map((e) => _eventTile(e)),
          const SizedBox(height: 14),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _legendDot(_cPeriod, '🩸 Period'),
            _legendDot(_cOvulation, '🥚 Ovulation'),
            _legendDot(_cDerma, '🏥 Derma'),
            _legendDot(_cMed, '💊 Meds'),
            _legendDot(_cAcne, '✨ Skin'),
            _legendDot(_cWater, '💧 Water'),
            _legendDot(_cMeal, '🍽️ Meal'),
            _legendDot(_cJournal, '📝 Journal'),
          ]),
        ),
        const SizedBox(height: 16),
        _routineCard(),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildWeekStrip() {
    final week = _weekDays();
    final selKey = _key(_selectedDay);
    final todayKey = _key(DateTime.now());
    return SizedBox(
      height: _showNepali ? 94 : 82,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, i) {
          final day = week[i];
          final k = _key(day);
          final isSel = k == selKey;
          final isT = k == todayKey;
          final nd = _np(day);
          return GestureDetector(
            onTap: () => _selectDay(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isSel ? _accent : _cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isSel ? _accent.withAlpha(70) : Colors.black.withAlpha(15),
                    blurRadius: isSel ? 10 : 4,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'][day.weekday % 7],
                    style: TextStyle(fontSize: 11, color: isSel ? Colors.white70 : _textMid)),
                const SizedBox(height: 3),
                Text('${day.day}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isSel ? Colors.white : isT ? _accent : _textDark,
                    )),
                if (_showNepali)
                  Text(_npNum(nd.day), style: TextStyle(fontSize: _npFontSize, color: isSel ? Colors.white60 : _accent)),
                if (!_showNepali && _events.containsKey(k))
                  Container(
                      width: 5,
                      height: 5,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(shape: BoxShape.circle, color: isSel ? Colors.white60 : _accent)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _affirmationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [_accentLight.withAlpha(120), _bgColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("TODAY'S AFFIRMATIONS",
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textMid, letterSpacing: 1.5)),
        const SizedBox(height: 8),
        Text(_todayAffirmation, style: const TextStyle(fontSize: 14, color: _textDark, height: 1.5)),
      ]),
    );
  }

  Widget _eventTile(_CalEvent e) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: _accent.withAlpha(20), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: e.color, child: Text(e.icon, style: const TextStyle(fontSize: 14))),
        title: Text(e.label, style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _eventChip(_CalEvent e) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: e.color.withAlpha(30), borderRadius: BorderRadius.circular(12)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(e.icon),
        const SizedBox(width: 6),
        Text(e.label, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }

  Widget _emptyCard(String text) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: _textMid)),
    );
  }

  Widget _todoCard(String selKey, List<_TodoItem> todos) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('To‑dos', style: TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
              onPressed: () => setState(() => _showTodos = !_showTodos),
              icon: Icon(_showTodos ? Icons.expand_less : Icons.expand_more))
        ]),
        if (_showTodos) ...[
          for (int i = 0; i < todos.length; i++)
            CheckboxListTile(
              value: todos[i].done,
              onChanged: (v) => setState(() => todos[i].done = v ?? false),
              title: Text(todos[i].text),
            ),
          Row(children: [
            Expanded(
              child: TextField(
                controller: _todoAddCtrl,
                decoration: const InputDecoration(hintText: 'Add todo', isDense: true),
              ),
            ),
            IconButton(
                onPressed: () {
                  final t = _todoAddCtrl.text.trim();
                  if (t.isEmpty) return;
                  setState(() {
                    todos.add(_TodoItem(t));
                    _todoAddCtrl.clear();
                  });
                },
                icon: const Icon(Icons.add))
          ])
        ] else
          Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text('${todos.length} tasks')),
      ]),
    );
  }

  Widget _notesCard(String selKey) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Today's Notes", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: _noteCtrl,
          maxLines: 3,
          decoration: const InputDecoration(border: InputBorder.none, hintText: 'Write your notes here...'),
          onChanged: (v) => _savedNotes[selKey] = v,
        ),
      ]),
    );
  }

  Widget _routineCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(12)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Daily Routine', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(children: [
            IconButton(
              tooltip: 'Add routine',
              onPressed: () => _showEditRoutineDialog(),
              icon: const Icon(Icons.add, color: _accent),
            ),
          ]),
        ]),
        const SizedBox(height: 8),
        if (_routine.isEmpty)
          const Text('No routines yet', style: TextStyle(color: _textMid))
        else
          Column(
            children: List.generate(_routine.length, (i) {
              final r = _routine[i];
              return ListTile(
                dense: true,
                leading: Text(r.emoji),
                title: Text(r.title),
                subtitle: Text('${r.startTime} - ${r.endTime}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.black54),
                    onPressed: () => _showEditRoutineDialog(index: i),
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => _confirmDeleteRoutine(i),
                    tooltip: 'Delete',
                  ),
                ]),
              );
            }),
          ),
      ]),
    );
  }

  Widget _legendDot(Color c, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ]),
    );
  }
}
