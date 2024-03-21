// ignore_for_file: use_build_context_synchronously

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AuthService {
  final firebaseAuth = FirebaseAuth.instance;

  get user => firebaseAuth.currentUser;

  void showSnackbarMessage(
    BuildContext context,
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 100, right: 20, left: 20),
      ),
    );
  }

  //SIGN UP METHOD
  Future signUp(BuildContext context,
      {required String email, required String password}) async {
    BotToast.showLoading();
    try {
      return await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      showSnackbarMessage(context, e.message!, isError: true);
      return e.message;
    }
  }

  //SIGN IN METHOD
  Future signIn(BuildContext context,
      {required String email, required String password}) async {
    BotToast.showLoading();
    try {
      return await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      showSnackbarMessage(context, e.message!, isError: true);
      return e.message;
    }
  }

  void onError(FirebaseAuthException e, BuildContext context) {
    if (e.code == 'invalid-email') {
      showSnackbarMessage(context, 'Invalid Email');
      if (kDebugMode) {
        print('Firebase Authentication Exception: ${e.code}/////////////');
      }
    } else if (e.code == 'user-not-found') {
      showSnackbarMessage(context, 'User not found for this Email');
      if (kDebugMode) {
        print('Firebase Authentication Exception: ${e.code}/////////////');
      }
    } else if (e.code == 'wrong-password') {
      showSnackbarMessage(context, 'Wrong Password');
      if (kDebugMode) {
        print('Firebase Authentication Exception: ${e.code}/////////////');
      }
    }
  }

  //SIGN OUT METHOD
  Future signOut() async {
    await firebaseAuth.signOut();
    if (kDebugMode) {
      print('signout');
    }
  }
}
