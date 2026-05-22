abstract class UserRepo {

 // Future<String> login(String email, String password);
 // Future<String> register(String email, String password);
 // Future<void> logout();


  Future register();
  Future login();
  Future logout();
  Future forgetPassword();
  Future addUser();
  Future deleteUser();
  Future getAllUser();
  Future getUserByID();
}
