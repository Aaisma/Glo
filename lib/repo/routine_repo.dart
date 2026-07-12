import '../model/calendar_models.dart';

abstract class RoutineRepo {
  // Notes
  Stream<List<CalendarNoteModel>> getNotes(String userId);
  Future<void> saveNote(CalendarNoteModel note);
  Future<void> deleteNote(String noteId, String userId);

  // Todos
  Stream<List<CalendarTodoModel>> getTodos(String userId);
  Future<void> saveTodo(CalendarTodoModel todo);
  Future<void> deleteTodo(String todoId, String userId);

  // Routines
  Stream<List<RoutineModel>> getRoutines(String userId);
  Future<void> saveRoutine(RoutineModel routine);
  Future<void> deleteRoutine(String routineId, String userId);
}
