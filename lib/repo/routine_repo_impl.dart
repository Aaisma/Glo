import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/calendar_models.dart';
import 'routine_repo.dart';

class RoutineRepoImpl implements RoutineRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  Stream<List<CalendarNoteModel>> getNotes(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('calendar_notes')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CalendarNoteModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  @override
  Future<void> saveNote(CalendarNoteModel note) async {
    await _db
        .collection('users')
        .doc(note.userId)
        .collection('calendar_notes')
        .doc(note.id)
        .set(note.toMap());
  }

  @override
  Future<void> deleteNote(String noteId, String userId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('calendar_notes')
        .doc(noteId)
        .delete();
  }

  @override
  Stream<List<CalendarTodoModel>> getTodos(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('calendar_todos')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => CalendarTodoModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  @override
  Future<void> saveTodo(CalendarTodoModel todo) async {
    await _db
        .collection('users')
        .doc(todo.userId)
        .collection('calendar_todos')
        .doc(todo.id)
        .set(todo.toMap());
  }

  @override
  Future<void> deleteTodo(String todoId, String userId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('calendar_todos')
        .doc(todoId)
        .delete();
  }

  @override
  Stream<List<RoutineModel>> getRoutines(String userId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('calendar_routines')
        .orderBy('startTime')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RoutineModel.fromMap(doc.data(), doc.id))
        .toList());
  }

  @override
  Future<void> saveRoutine(RoutineModel routine) async {
    await _db
        .collection('users')
        .doc(routine.userId)
        .collection('calendar_routines')
        .doc(routine.id)
        .set(routine.toMap());
  }

  @override
  Future<void> deleteRoutine(String routineId, String userId) async {
    await _db
        .collection('users')
        .doc(userId)
        .collection('calendar_routines')
        .doc(routineId)
        .delete();
  }
}