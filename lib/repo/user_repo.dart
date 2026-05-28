import '../model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract class UserRepo {

  Future<String> login(String email,String password);
  Future<String> register(String email, String password);
  Future<void> logout();
  Future<void> forgetPassword(String email);
  Future<void> addUser(UserModel userModel);
  Future<void> deleteUser(String id);
  Future<List<UserModel>> getAllUser();
  Future<UserModel> getUserByID(String id);
  Future<void> editProfile(UserModel userModel);
}