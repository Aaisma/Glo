import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nepali_utils/nepali_utils.dart';
import 'package:provider/provider.dart';
import '../viewmodel/user_view_model.dart';

// ─── palette ────────────────────────────────────────────────────────────────
const _bgColor     = Color(0xFFF8C8DC);
const _cardColor   = Colors.white;
const _accent      = Color(0xFFD4658A);
const _accentLight = Color(0xFFF0A0BC);
const _textDark    = Color(0xFF3D1A2E);
const _textMid     = Color(0xFF9A6070);

// ─── affirmations ────────────────────────────────────────────────────────────
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

// ─── event model ────────────────────────────────────────────────────────────
class _CalEvent {
  final String type, label, icon;
  final Color color;
  const _CalEvent({required this.type, required this.label, required this.icon, required this.color});
}

// ─── to-do item ─────────────────────────────────────────────────────────────
class _TodoItem {
  String text;
  bool done;
  _TodoItem(this.text, {this.done = false});
}

// ─── routine item ────────────────────────────────────────────────────────────
class _RoutineItem {
  String title, startTime, endTime, emoji;
  _RoutineItem(this.title, this.startTime, this.endTime, this.emoji);
}

// ═══════════════════════════════════════════════════════════════════════════
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  // view mode
  int _viewIndex = 0; // 0=Daily 1=Weekly 2=Monthly
  static const _viewLabels = ['Daily', 'Weekly', 'Monthly'];

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay  = DateTime.now();
  bool _showNepali = false;
  bool _isLoading  = true;
  bool _showTodos  = false;

  final TextEditingController _noteCtrl    = TextEditingController();
  final TextEditingController _todoAddCtrl = TextEditingController();
  final Map<String, String>         _savedNotes = {};
  final Map<String, List<_TodoItem>> _todos     = {};
  final List<_RoutineItem> _routine = [
    _RoutineItem('Yoga 🧘','7:00 AM','8:00 AM','🧘'),
    _RoutineItem('Morning skincare','8:00 AM','8:30 AM','✨'),
    _RoutineItem('Water intake check','9:00 AM','9:10 AM','💧'),
    _RoutineItem('Medication','9:30 AM','9:35 AM','💊'),
    _RoutineItem('Evening walk','6:00 PM','6:45 PM','🚶'),
    _RoutineItem('Night skincare','9:00 PM','9:20 PM','🌙'),
  ];

  final Map<String, List<_CalEvent>> _events = {};

  // event colours
  static const _cPeriod    = Color(0xFFE57373);
  static const _cOvulation = Color(0xFFFFB74D);
  static const _cDerma     = Color(0xFF64B5F6);
  static const _cMed       = Color(0xFF81C784);
  static const _cAcne      = Color(0xFFBA68C8);
  static const _cWater     = Color(0xFF4FC3F7);
  static const _cMeal      = Color(0xFFFFD54F);
  static const _cJournal   = Color(0xFFF06292);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn);
    _animCtrl.forward();

    Future.microtask(() {
      final userVM = context.read<UserViewModel>();
      if (userVM.userId != null) {
        _loadAll(userVM.userId!);
      } else {
        setState(() => _isLoading = false);
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

  // ── helpers ─────────────────────────────────────────────────────────────
  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  String _eMonth(int m) => const ['January','February','March','April','May','June','July','August','September','October','November','December'][m-1];
  String _npMonth(int m) => const ['बैशाख','जेठ','असार','श्रावण','भदौ','आश्विन','कार्तिक','मंसिर','पुष','माघ','फाल्गुन','चैत'][(m-1).clamp(0,11)];
  String _npNum(int n) { const d=['०','१','२','३','४','५','६','७','८','९']; return n.toString().split('').map((c)=>d[int.parse(c)]).join(); }
  NepaliDateTime _np(DateTime d) => NepaliDateTime.fromDateTime(d);

  void _addEv(String key, _CalEvent e) => _events.putIfAbsent(key,()=>[]).add(e);

  String? _extractDate(Map<String,dynamic> data) {
    for (final f in ['date','startDate','start_date','periodDate','ovulationDate','visitDate','appointmentDate','takenAt','createdAt']) {
      final v = data[f];
      if (v is String && v.length >= 10) return v.substring(0,10);
      if (v is Timestamp) return _key(v.toDate());
    }
    return null;
  }

  bool _isMyUser(Map<String,dynamic> data, String userId) {
    final uid = data['userId'] as String? ?? data['user_id'] as String? ?? '';
    return uid.isEmpty || uid == userId;
  }

  // ── Firestore ────────────────────────────────────────────────────────────
  Future<void> _loadAll(String userId) async {
    setState(() => _isLoading = true);
    final db = FirebaseFirestore.instance;

    Future<List<QueryDocumentSnapshot<Map<String,dynamic>>>> _root(String col) async {
      try { return (await db.collection(col).get()).docs; } catch(_) { return []; }
    }
    Future<List<QueryDocumentSnapshot<Map<String,dynamic>>>> _sub(String col) async {
      try { return (await db.collection('users').doc(userId).collection(col).get()).docs; } catch(_) { return []; }
    }

    _events.clear();

    // period
    for (final doc in await _root('period')) {
      final data = doc.data(); if (!_isMyUser(data, userId)) continue;
      final k = _extractDate(data); if (k==null) continue;
      _addEv(k, const _CalEvent(type:'period', label:'Period day 🩸', icon:'🩸', color:_cPeriod));
    }

    // ovulation
    for (final doc in await _root('ovulation')) {
      final data = doc.data(); if (!_isMyUser(data, userId)) continue;
      final k = _extractDate(data); if (k==null) continue;
      _addEv(k, const _CalEvent(type:'ovulation', label:'Ovulation day 🥚', icon:'🥚', color:_cOvulation));
    }

    // derma_visits
    for (final doc in await _root('derma_visits')) {
      final data = doc.data(); if (!_isMyUser(data, userId)) continue;
      final k = _extractDate(data); if (k==null) continue;
      final title = data['title'] as String? ?? data['visitTitle'] as String? ?? 'Derma visit';
      _addEv(k, _CalEvent(type:'derma', label:'$title 🏥', icon:'🏥', color:_cDerma));
    }

    // medications
    for (final doc in await _root('medications')) {
      final data = doc.data(); if (!_isMyUser(data, userId)) continue;
      final k = _extractDate(data); if (k==null) continue;
      final name = data['name'] as String? ?? data['medicationName'] as String? ?? 'Medication';
      _addEv(k, _CalEvent(type:'medication', label:'$name 💊', icon:'💊', color:_cMed));
    }

    // journals
    for (final doc in await _root('journals')) {
      final data = doc.data(); if (!_isMyUser(data, userId)) continue;
      final k = _extractDate(data); if (k==null) continue;
      _addEv(k, const _CalEvent(type:'journal', label:'Journal entry 📝', icon:'📝', color:_cJournal));
    }

    // my subcollections
    for (final doc in await _sub('acne_tracker')) {
      _addEv(doc.id, const _CalEvent(type:'acne', label:'Skin tracked ✨', icon:'✨', color:_cAcne));
    }
    for (final doc in await _sub('water_history')) {
      final data = doc.data() as Map<String,dynamic>;
      final l = (data['intake'] as num?)?.toDouble() ?? 0;
      _addEv(doc.id, _CalEvent(type:'water', label:'Water: ${l.toStringAsFixed(1)} L 💧', icon:'💧', color:_cWater));
    }
    for (final doc in await _sub('meal_tracker')) {
      final data = doc.data() as Map<String,dynamic>;
      final m = (data['meals'] as List?)?.length ?? 0;
      _addEv(doc.id, _CalEvent(type:'meal', label:'$m meals logged 🍽️', icon:'🍽️', color:_cMeal));
    }

    if (mounted) setState(() => _isLoading = false);
  }

  // ── calendar grid ────────────────────────────────────────────────────────
  List<DateTime?> _monthGrid() {
    final first = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final days  = DateTime(_focusedMonth.year, _focusedMonth.month+1, 0).day;
    final offset = first.weekday % 7;
    final grid = <DateTime?>[for(int i=0;i<offset;i++) null, for(int d=1;d<=days;d++) DateTime(_focusedMonth.year,_focusedMonth.month,d)];
    while(grid.length%7!=0) grid.add(null);
    return grid;
  }

  List<DateTime> _weekDays() {
    final start = _selectedDay.subtract(Duration(days: _selectedDay.weekday%7));
    return List.generate(7,(i)=>start.add(Duration(days:i)));
  }

  void _changePage(int delta) {
    _animCtrl.reverse().then((_){
      if(!mounted) return;
      setState(()=> _focusedMonth = DateTime(_focusedMonth.year,_focusedMonth.month+delta));
      _animCtrl.forward();
    });
  }

  void _selectDay(DateTime d) {
    setState((){
      _selectedDay = d;
      _noteCtrl.text = _savedNotes[_key(d)] ?? '';
      if (d.month != _focusedMonth.month || d.year != _focusedMonth.year) {
        _focusedMonth = DateTime(d.year, d.month);
      }
    });
  }

  // ── affirmation for today ────────────────────────────────────────────────
  String get _todayAffirmation {
    final idx = DateTime.now().day % _affirmations.length;
    return _affirmations[idx];
  }

  // ────────────────────────────────────────────────────────────────────────
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
    );
  }

  // ── header ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20,14,20,0),
      child: Row(
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('My Calendar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _textDark)),
            Text(_eMonth(_focusedMonth.month)+' ${_focusedMonth.year}',
                style: const TextStyle(fontSize: 13, color: _textMid)),
          ]),
          const Spacer(),
          // EN / NP toggle
          GestureDetector(
            onTap: ()=> setState(()=> _showNepali = !_showNepali),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: _showNepali ? _accent : _cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _accent.withOpacity(0.5)),
              ),
              child: Text(_showNepali ? 'NP ✓' : 'EN',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                      color: _showNepali ? Colors.white : _accent)),
            ),
          ),
        ],
      ),
    );
  }

  // ── view toggle ──────────────────────────────────────────────────────────
  Widget _buildViewToggle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20,12,20,0),
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: _cardColor.withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: List.generate(3,(i){
            final sel = _viewIndex == i;
            return Expanded(
              child: GestureDetector(
                onTap: ()=> setState(()=> _viewIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: sel ? _accent : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(_viewLabels[i],
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: sel ? Colors.white : _textMid)),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── body router ──────────────────────────────────────────────────────────
  Widget _buildBody() {
    switch(_viewIndex){
      case 0: return _buildDailyView();
      case 1: return _buildWeeklyView();
      case 2: return _buildMonthlyView();
      default: return _buildDailyView();
    }
  }

  // ════════════════════════════════════════════════════════════════════════
  // DAILY VIEW
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildDailyView() {
    final selKey = _key(_selectedDay);
    final events = _events[selKey] ?? [];
    final np = _np(_selectedDay);
    final todos = _todos.putIfAbsent(selKey, ()=>[]);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // horizontal week strip
        _buildWeekStrip(),
        const SizedBox(height: 16),

        // affirmation card
        _affirmationCard(),
        const SizedBox(height: 14),

        // date label
        Row(children:[
          Text('TODAY  ',style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textMid, letterSpacing: 1.5)),
          Text(
            _showNepali
                ? '${_selectedDay.day} ${_eMonth(_selectedDay.month)}  •  ${_npNum(np.day)} ${_npMonth(np.month)} ${_npNum(np.year)}'
                : '${_selectedDay.day} ${_eMonth(_selectedDay.month)} ${_selectedDay.year}',
            style: const TextStyle(fontSize: 13, color: _textDark, fontWeight: FontWeight.w500),
          ),
        ]),
        const SizedBox(height: 12),

        // events
        if (events.isEmpty) _emptyCard('Nothing logged on this day ✨')
        else ...events.map((e) => _eventTile(e)),

        const SizedBox(height: 16),

        // to-do list card
        _todoCard(selKey, todos),
        const SizedBox(height: 16),

        // notes card
        _notesCard(selKey),
        const SizedBox(height: 20),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // WEEKLY VIEW
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildWeeklyView() {
    final week = _weekDays();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildWeekStrip(),
        const SizedBox(height: 16),
        ...week.map((day){
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
              boxShadow: [BoxShadow(color: _accent.withOpacity(0.1), blurRadius: 6, offset: const Offset(0,2))],
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isToday ? _accent : _bgColor.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), topRight: Radius.circular(14)),
                ),
                child: Row(children: [
                  Text(['Sun','Mon','Tue','Wed','Thu','Fri','Sat'][day.weekday%7],
                      style: TextStyle(fontSize: 11, color: isToday ? Colors.white : _textMid, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  Text('${day.day}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isToday ? Colors.white : _textDark)),
                  if (_showNepali) Text('  ${_npNum(np.day)} ${_npMonth(np.month)}',
                      style: TextStyle(fontSize: 13, color: isToday ? Colors.white70 : _accent)),
                ]),
              ),
              if (evs.isEmpty)
                const Padding(padding: EdgeInsets.all(12),
                    child: Text('No events', style: TextStyle(color: _textMid, fontSize: 12)))
              else
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Wrap(spacing: 6, runSpacing: 6,
                        children: evs.map((e) => _eventChip(e)).toList())),
            ]),
          );
        }),
        const SizedBox(height: 20),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // MONTHLY VIEW
  // ════════════════════════════════════════════════════════════════════════
  Widget _buildMonthlyView() {
    final grid = _monthGrid();
    final selKey = _key(_selectedDay);
    final selEvents = _events[selKey] ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // month nav
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          IconButton(icon: const Icon(Icons.chevron_left, color: _textMid), onPressed: ()=> _changePage(-1)),
          Text(
            _showNepali
                ? '${_eMonth(_focusedMonth.month)} ${_focusedMonth.year}  /  ${_npMonth(_np(DateTime(_focusedMonth.year,_focusedMonth.month,1)).month)}'
                : '${_eMonth(_focusedMonth.month)} ${_focusedMonth.year}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark),
          ),
          IconButton(icon: const Icon(Icons.chevron_right, color: _textMid), onPressed: ()=> _changePage(1)),
        ]),

        // weekday headers
        Row(children: ['S','M','T','W','T','F','S'].map((d)=> Expanded(
          child: Center(child: Text(d, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _textMid))),
        )).toList()),
        const SizedBox(height: 4),

        // grid
        Container(
          decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: _accent.withOpacity(0.12), blurRadius: 8, offset: const Offset(0,3))]),
          padding: const EdgeInsets.all(6),
          child: Column(
            children: List.generate(grid.length~/7, (row){
              return Row(
                children: List.generate(7,(col){
                  final day = grid[row*7+col];
                  if(day==null) return const Expanded(child: SizedBox(height: 52));
                  final k = _key(day);
                  final isSel = k==selKey;
                  final isT   = k==_key(DateTime.now());
                  final evs   = _events[k] ?? [];
                  final nd    = _np(day);
                  return Expanded(
                    child: GestureDetector(
                      onTap: ()=> _selectDay(day),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        height: _showNepali ? 58 : 48,
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: isSel ? _accent : isT ? _accentLight.withOpacity(0.3) : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(alignment: Alignment.center, children: [
                          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text('${day.day}', style: TextStyle(
                              fontSize: 15, fontWeight: isSel||isT ? FontWeight.bold : FontWeight.normal,
                              color: isSel ? Colors.white : isT ? _accent : _textDark,
                            )),
                            if (_showNepali) Text(_npNum(nd.day), style: TextStyle(
                              fontSize: 11, color: isSel ? Colors.white70 : _accent,
                            )),
                          ]),
                          if (evs.isNotEmpty) Positioned(bottom: 3, child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: evs.take(3).map((e)=> Container(
                              width: 4, height: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(shape: BoxShape.circle,
                                  color: isSel ? Colors.white60 : e.color),
                            )).toList(),
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

        // selected day events
        if (selEvents.isNotEmpty) ...[
          Text('${_selectedDay.day} ${_eMonth(_selectedDay.month)}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _textDark)),
          const SizedBox(height: 8),
          ...selEvents.map((e)=> _eventTile(e)),
          const SizedBox(height: 14),
        ],

        // legend
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _ldot(_cPeriod,'🩸 Period'),
            _ldot(_cOvulation,'🥚 Ovulation'),
            _ldot(_cDerma,'🏥 Derma'),
            _ldot(_cMed,'💊 Meds'),
            _ldot(_cAcne,'✨ Skin'),
            _ldot(_cWater,'💧 Water'),
            _ldot(_cMeal,'🍽️ Meal'),
            _ldot(_cJournal,'📝 Journal'),
          ]),
        ),

        const SizedBox(height: 16),

        // daily routine card
        _routineCard(),
        const SizedBox(height: 20),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════════════
  // REUSABLE WIDGETS
  // ════════════════════════════════════════════════════════════════════════

  Widget _buildWeekStrip() {
    final week = _weekDays();
    final selKey  = _key(_selectedDay);
    final todayKey= _key(DateTime.now());
    return SizedBox(
      height: _showNepali ? 94 : 82,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, i){
          final day = week[i];
          final k = _key(day);
          final isSel = k==selKey;
          final isT   = k==todayKey;
          final nd = _np(day);
          return GestureDetector(
            onTap: ()=> _selectDay(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52, margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isSel ? _accent : _cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(
                  color: isSel ? _accent.withOpacity(0.45) : Colors.black.withOpacity(0.06),
                  blurRadius: isSel ? 10 : 4, offset: const Offset(0,3),
                )],
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(['Su','Mo','Tu','We','Th','Fr','Sa'][day.weekday%7],
                    style: TextStyle(fontSize: 11, color: isSel ? Colors.white70 : _textMid)),
                const SizedBox(height: 3),
                Text('${day.day}', style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold,
                  color: isSel ? Colors.white : isT ? _accent : _textDark,
                )),
                if (_showNepali) Text(_npNum(nd.day),
                    style: TextStyle(fontSize: 12, color: isSel ? Colors.white60 : _accent)),
                if (!_showNepali && _events.containsKey(k))
                  Container(width: 5, height: 5, margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          color: isSel ? Colors.white60 : _accent)),
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
        gradient: LinearGradient(colors: [_accentLight.withOpacity(0.5), _bgColor], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _accentLight),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("TODAY'S AFFIRMATIONS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _textMid, letterSpacing: 1.5)),
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
        boxShadow: [BoxShadow(color: e.color.withOpacity(0.18), blurRadius: 6, offset: const Offset(0,2))],
      ),
      child: Row(children: [
        Container(width: 5, height: 52,
            decoration: BoxDecoration(color: e.color,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)))),
        const SizedBox(width: 12),
        Text(e.icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Expanded(child: Padding(padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(e.label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _textDark)))),
        const SizedBox(width: 10),
      ]),
    );
  }

  Widget _eventChip(_CalEvent e) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: e.color.withOpacity(0.15), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: e.color.withOpacity(0.4))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(e.icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(e.label, style: TextStyle(fontSize: 11, color: e.color, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _todoCard(String key, List<_TodoItem> todos) {
    return Container(
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _accent.withOpacity(0.12), blurRadius: 8, offset: const Offset(0,3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // header
        GestureDetector(
          onTap: ()=> setState(()=> _showTodos = !_showTodos),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16,14,16,14),
            decoration: BoxDecoration(
              color: _bgColor.withOpacity(0.4),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16), topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(_showTodos ? 0 : 16),
                bottomRight: Radius.circular(_showTodos ? 0 : 16),
              ),
            ),
            child: Row(children: [
              const Text("📋 To Do's", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark)),
              const Spacer(),
              Icon(_showTodos ? Icons.expand_less : Icons.expand_more, color: _textMid),
            ]),
          ),
        ),
        if (_showTodos) Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // existing todos
            ...todos.asMap().entries.map((entry){
              final i = entry.key;
              final todo = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  GestureDetector(
                    onTap: ()=> setState(()=> todo.done = !todo.done),
                    child: Container(
                      width: 22, height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: todo.done ? _accent : Colors.transparent,
                        border: Border.all(color: todo.done ? _accent : _textMid.withOpacity(0.4), width: 1.5),
                      ),
                      child: todo.done ? const Icon(Icons.check, color: Colors.white, size: 13) : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(todo.text, style: TextStyle(
                    fontSize: 14, color: todo.done ? _textMid : _textDark,
                    decoration: todo.done ? TextDecoration.lineThrough : null,
                  ))),
                  GestureDetector(
                    onTap: ()=> setState(()=> todos.removeAt(i)),
                    child: const Icon(Icons.close, size: 16, color: _textMid),
                  ),
                ]),
              );
            }),
            const SizedBox(height: 8),
            // add new todo
            Row(children: [
              Expanded(child: TextField(
                controller: _todoAddCtrl,
                style: const TextStyle(fontSize: 13, color: _textDark),
                decoration: InputDecoration(
                  hintText: 'Add to-do...',
                  hintStyle: TextStyle(color: _textMid.withOpacity(0.6), fontSize: 13),
                  filled: true, fillColor: const Color(0xFFFFF0F5),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _accent.withOpacity(0.3))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: _accent.withOpacity(0.3))),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              )),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: (){
                  final t = _todoAddCtrl.text.trim();
                  if (t.isEmpty) return;
                  setState((){ todos.add(_TodoItem(t)); _todoAddCtrl.clear(); });
                },
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }

  Widget _notesCard(String key) {
    return Container(
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _accent.withOpacity(0.12), blurRadius: 8, offset: const Offset(0,3))]),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('📓 Notes', style: TextStyle(fontWeight: FontWeight.bold, color: _textDark, fontSize: 14)),
          const Spacer(),
          GestureDetector(
            onTap: (){
              setState(()=> _savedNotes[key] = _noteCtrl.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Note saved!'), backgroundColor: _accent, duration: Duration(seconds: 1)));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(12)),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        TextField(
          controller: _noteCtrl, maxLines: 3,
          style: const TextStyle(fontSize: 13, color: _textDark),
          decoration: InputDecoration(
            hintText: 'How are you feeling today?...',
            hintStyle: TextStyle(color: _textMid.withOpacity(0.6), fontSize: 13),
            filled: true, fillColor: const Color(0xFFFFF0F5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _accent.withOpacity(0.3))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: _accent.withOpacity(0.3))),
            contentPadding: const EdgeInsets.all(10),
          ),
        ),
      ]),
    );
  }

  Widget _routineCard() {
    return Container(
      decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: _accent.withOpacity(0.12), blurRadius: 8, offset: const Offset(0,3))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _bgColor.withOpacity(0.4),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Row(children: [
            const Text('🗓️ Daily Routine', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _textDark)),
            const Spacer(),
            GestureDetector(
              onTap: ()=> _showAddRoutineDialog(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(10)),
                child: const Text('+ Add', style: TextStyle(color: Colors.white, fontSize: 11)),
              ),
            ),
          ]),
        ),
        ..._routine.asMap().entries.map((entry){
          final r = entry.value;
          return Container(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
            decoration: BoxDecoration(
              color: _bgColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _accentLight.withOpacity(0.5)),
            ),
            child: Row(children: [
              Container(width: 4, height: 52,
                  decoration: BoxDecoration(color: _accent,
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)))),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${r.startTime}', style: const TextStyle(fontSize: 11, color: _textMid)),
              ]),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${r.emoji}  ${r.title}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: _textDark)),
                Text('${r.startTime} – ${r.endTime}', style: const TextStyle(fontSize: 11, color: _textMid)),
              ])),
              GestureDetector(
                onTap: ()=> setState(()=> _routine.removeAt(entry.key)),
                child: const Padding(padding: EdgeInsets.all(12),
                    child: Icon(Icons.close, size: 15, color: _textMid)),
              ),
            ]),
          );
        }),
        const SizedBox(height: 6),
      ]),
    );
  }

  void _showAddRoutineDialog() {
    final titleCtrl = TextEditingController();
    final startCtrl = TextEditingController(text: '8:00 AM');
    final endCtrl   = TextEditingController(text: '9:00 AM');
    final emojiCtrl = TextEditingController(text: '⭐');
    showDialog(context: context, builder: (_)=> AlertDialog(
      title: const Text('Add Routine Item', style: TextStyle(color: _textDark)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Morning run')),
        TextField(controller: emojiCtrl, decoration: const InputDecoration(labelText: 'Emoji')),
        TextField(controller: startCtrl, decoration: const InputDecoration(labelText: 'Start time')),
        TextField(controller: endCtrl,   decoration: const InputDecoration(labelText: 'End time')),
      ]),
      actions: [
        TextButton(onPressed: ()=> Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: _accent),
          onPressed: (){
            final t = titleCtrl.text.trim();
            if (t.isNotEmpty) {
              setState(()=> _routine.add(_RoutineItem(t, startCtrl.text.trim(), endCtrl.text.trim(), emojiCtrl.text.trim())));
            }
            Navigator.pop(context);
          },
          child: const Text('Add', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  Widget _emptyCard(String msg) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: _cardColor, borderRadius: BorderRadius.circular(14)),
    child: Center(child: Text(msg, style: const TextStyle(color: _textMid, fontSize: 13))),
  );

  Widget _ldot(Color c, String label) => Padding(
    padding: const EdgeInsets.only(right: 12),
    child: Row(children: [
      Container(width: 9, height: 9, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: _textMid)),
    ]),
  );
}