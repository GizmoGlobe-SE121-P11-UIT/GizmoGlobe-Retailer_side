import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../data/database/database.dart';
import 'drawer_state.dart';

class DrawerCubit extends Cubit<DrawerState> {
  DrawerCubit() : super(DrawerState());

  void toggleDrawer() => emit(state.copyWith(isOpen: !state.isOpen));
  void openDrawer() => emit(state.copyWith(isOpen: true));
  void closeDrawer() => emit(state.copyWith(isOpen: false));

  Future<void> logOut(BuildContext context) async {
    try {
      closeDrawer();

      // Sign out from Firebase
      await FirebaseAuth.instance.signOut();

      // Clear cached user data from Database
      Database().clearUserData();

      // Force a delay to ensure auth state is completely cleared
      await Future.delayed(const Duration(milliseconds: 200));

      if (context.mounted) {
        // Use pushReplacementNamed to ensure proper route handling
        Navigator.pushReplacementNamed(context, '/sign-in');
      }
    } catch (e) {
      // Error signing out
    }
  }
}
