import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AuthService{
  final FirebaseAuth _auth=FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  //Insqcription avec email et mot de passe
  Future<void> signUpWithEmailPass(String email, String password) async {
    try {
      // Vérifier si l'utilisateur existe déjà (par exemple, avec Firebase Auth)
      var user = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (user.isNotEmpty) {
        throw Exception('User already exists');
      }

      // Créer un nouvel utilisateur s'il n'existe pas déjà
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }


  //Connection avec email et mot de passe

  Future<UserCredential> signInWithEmailPassword(String email , String password) async {
    try{
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    }catch(e){
      throw Exception(e.toString());
    }
  }


  //Decoonection

  Future<void> signOut() async{
    await _auth.signOut();
  }
}


