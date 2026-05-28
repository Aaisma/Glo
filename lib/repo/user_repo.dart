import '../model/user_model.dart';

abstract class UserRepo {
  Future<String> login(String email, String password);
  Future<String> register(String email, String password);
  Future<String> signInWithGoogle();
  Future<String> signInWithFacebook();
  Future<void> logout();
  Future<void> forgetPassword(String email);
  Future<void> addUser(UserModel userModel);
  Future<void> deleteUser(String id);
  Future<List<UserModel>> getAllUser();
  Future<UserModel> getUserByID(String id);
  Future<void> editProfile(UserModel userModel);
  Future<void> updateSurvey({
    required String userId,
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
