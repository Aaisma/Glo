import 'package:firebase_auth/firebase_auth.dart';
import '../model/user_model.dart';

abstract class UserRepo {
  Future<UserModel?> getUserByID(String id);
  Future<void> addUser(UserModel userModel);
  Future<void> editProfile(UserModel userModel);
  Future<void> deleteUser(String id);
  Future<List<UserModel>> getAllUser();
  Future<void> createDefaultProfile(User user);
  
  Future<void> updateSurvey({
    required String userId,
    required String email,
    String? name,
    required String ageGroup,
    required String skinType,
    required List<String> goals,
    int? actualAge,
    double? bmi,
    double? waterGoal,
    DateTime? lastCycleDate,
    List<String>? acneTypes,
    bool? usesMedication,
    String? medicationType,
    String? medicationTime,
    bool? visitsDerma,
    DateTime? lastDermaVisit,
  });
}
