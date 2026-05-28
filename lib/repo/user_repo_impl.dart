import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:glo/model/user_model.dart';

import 'user_repo.dart';

class UserRepoImpl implements UserRepo{

  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  @override
  Future<void> addUser(UserModel userModel) {
    return firestore
        .collection("users")
        .doc(userModel.id)
        .set (userModel.toMap());
  }

  @override
  Future<void> deleteUser(String id) {
    return firestore.collection("users").doc(id).delete();
  }

  @override
  Future<void> editProfile(UserModel userModel) {
    return firestore
        .collection("users")
        .doc(userModel.id)
        .update(userModel.toMap());
  }

  @override
  Future<void> forgetPassword(String email) {
    return auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<List<UserModel>> getAllUser() async{
    final users = await firestore
        .collection("users")
        .get();

    List<UserModel> data = [];
    for(int i=0; i<users.docs.length; i++){
      data.add(UserModel.fromMap(users.docs[i].data()));
    }
    return data;
  }

  @override
  Future<UserModel> getUserByID(String id) async{
    final users = await firestore
        .collection("users")
        .doc(id)
        .get();
    final data = users.data();

    if(data == null){
      throw Exception("Unable to fetch data.");
    }
    return UserModel.fromMap(data);
  }

  @override
  Future<String> login(String email, String password) async{
    final user = await auth.signInWithEmailAndPassword(email: email, password: password);
    final userId = user.user?.uid;

    if(userId==null){
      throw  Exception("login failed");
    }
    return userId;
  }

  @override
  Future<void> logout() {
    return auth.signOut();
  }

  @override
  Future<String> register(String email, String password) async{
    final user = await auth.signInWithEmailAndPassword(email: email, password: password);
    final userId = user.user?.uid;

    if(userId==null){
      throw  Exception("Registration failed");
    }
    return userId;

  }
}