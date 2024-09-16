import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthServiec {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?>sginupWithEmailAndPAssword(String email , String password)async{
    try{
      UserCredential credential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }
    catch(e){
      print("object");
    }
    return null;
  }
  Future<User?>sginINWithEmailAndPAssword(String email , String password)async{
    try{
      UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return credential.user;
    }
    catch(e){
      print("object");
    }
    return null;
  }
}
