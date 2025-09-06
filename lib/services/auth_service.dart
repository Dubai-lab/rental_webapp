import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔑 Sign up new user
  Future<UserModel> signUp({
    required String name,
    required String email,
    required String phone,
    required String password,
    String role = "user", // default role
  }) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = cred.user!.uid;

      UserModel user = UserModel(
        id: uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        createdAt: DateTime.now(),
      );

      await _firestore.collection("users").doc(uid).set({
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'role': user.role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception("SignUp Error: ${e.message}");
    } catch (e) {
      throw Exception("SignUp Error: ${e.toString()}");
    }
  }

  /// 🔑 Login
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot doc =
          await _firestore.collection("users").doc(cred.user!.uid).get();

      if (!doc.exists) throw Exception("User data not found in Firestore.");

      return UserModel.fromDoc(doc);
    } on FirebaseAuthException catch (e) {
      throw Exception("Login Error: ${e.message}");
    } catch (e) {
      throw Exception("Login Error: ${e.toString()}");
    }
  }

  /// 🚪 Logout
  Future<void> logout() async {
    await _auth.signOut();
  }

  /// 👤 Get current logged-in user
  Future<UserModel?> getCurrentUser() async {
    User? user = _auth.currentUser;
    if (user == null) return null;

    DocumentSnapshot doc =
        await _firestore.collection("users").doc(user.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromDoc(doc);
  }

  /// 🔎 Fetch user by UID
  Future<UserModel?> getUserById(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection("users").doc(uid).get();
      if (!doc.exists) return null;
      return UserModel.fromDoc(doc);
    } catch (e) {
      return null;
    }
  }

  /// Update user profile
  Future<void> updateProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw Exception("Failed to update profile: ${e.toString()}");
    }
  }
}

/// ✅ Riverpod provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
