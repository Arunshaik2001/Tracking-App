

import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationService{
  final FirebaseAuth _firebaseAuth;
  AuthenticationService(this._firebaseAuth);

  Stream<User> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<bool> signIn({String email,String password}) async{
    try{
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on FirebaseAuthException catch(e){
      print(e.toString());
      return false;
    }

  }

  Future<String> signUp({String email,String password}) async{
    try{
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      return "Logged In";
    } on FirebaseAuthException catch(e){

      return "11${e.toString()}";
    }

  }
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}