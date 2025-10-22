import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../data/database/database.dart';
import 'user_screen_state.dart';

class UserScreenCubit extends Cubit<UserScreenState> {
  UserScreenCubit() : super(const UserScreenState(username: '', email: ''));

  Future<void> getUser() async {
    await Database().getUser();
    emit(
        state.copyWith(username: Database().username, email: Database().email));
  }

  Future<void> logOut(BuildContext context) async {
    try {
      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear cached user data from Database
      Database().clearUserData();

      // Force a delay to ensure auth state is completely cleared
      await Future.delayed(const Duration(milliseconds: 200));

      if (context.mounted) {
        if (kDebugMode) {
          print('UserScreenCubit - User signed out, redirecting to /sign-in');
        }

        // Use pushReplacementNamed to ensure proper route handling
        Navigator.pushReplacementNamed(context, '/sign-in');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error signing out: $e'); // Lỗi khi đăng xuất
      }
    }
  }
}
