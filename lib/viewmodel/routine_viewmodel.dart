import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../model/calendar_models.dart';
import '../repo/routine_repo.dart';

class RoutineViewModel extends ChangeNotifier {
  final RoutineRepo _routineRepo;

  RoutineViewModel({required RoutineRepo routineRepo}) : _routineRepo = routineRepo;

  List<CalendarNoteModel> _notes = [];
  List<CalendarTodoModel> _todos = [];
  List<RoutineModel> _routines = [];

  List<CalendarNoteModel> get notes => _notes;
  List<CalendarTodoModel> get todos => _todos;
  List<RoutineModel> get routines => _routines;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void listenToData(String userId) {
    _routineRepo.getNotes(userId).listen((notesData) {
      _notes = notesData;
      notifyListeners();
    });

    _routineRepo.getTodos(userId).listen((todosData) {
      _todos = todosData;
      notifyListeners();
    });

    _routineRepo.getRoutines(userId).listen((routinesData) {
      _routines = routinesData;
      notifyListeners();
    });
  }

  // --- Notes ---
  CalendarNoteModel? getNoteForDate(String date) {
    try {
      return _notes.firstWhere((note) => note.date == date);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNote(String userId, String date, String noteText) async {
    final existing = getNoteForDate(date);
    final note = CalendarNoteModel(
      id: existing?.id ?? Uuid().v4(),
      userId: userId,
      date: date,
      note: noteText,
      createdAt: existing?.createdAt ?? DateTime.now(),
    );
    await _routineRepo.saveNote(note);
  }

  Future<void> deleteNote(String noteId, String userId) async {
    await _routineRepo.deleteNote(noteId, userId);
  }

  // --- Todos ---
  List<CalendarTodoModel> getTodosForDate(String date) {
    return _todos.where((todo) => todo.date == date).toList();
  }

  Future<void> saveTodo(String userId, String date, String text) async {
    final todo = CalendarTodoModel(
      id: Uuid().v4(),
      userId: userId,
      date: date,
      text: text,
      isDone: false,
      createdAt: DateTime.now(),
    );
    await _routineRepo.saveTodo(todo);
  }

  Future<void> toggleTodo(CalendarTodoModel todo) async {
    final updated = todo.copyWith(isDone: !todo.isDone);
    await _routineRepo.saveTodo(updated);
  }

  Future<void> deleteTodo(String todoId, String userId) async {
    await _routineRepo.deleteTodo(todoId, userId);
  }

  // --- Routines ---
  Future<void> saveRoutine(String userId, String title, DateTime startTime, DateTime endTime, String emoji, {String? existingId, DateTime? existingCreatedAt}) async {
    final routine = RoutineModel(
      id: existingId ?? Uuid().v4(),
      userId: userId,
      title: title,
      startTime: startTime,
      endTime: endTime,
      emoji: emoji,
      createdAt: existingCreatedAt ?? DateTime.now(),
    );
    await _routineRepo.saveRoutine(routine);
  }

  Future<void> deleteRoutine(String routineId, String userId) async {
    await _routineRepo.deleteRoutine(routineId, userId);
  }
}
