import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gizmoglobe_client/data/database/database.dart';

part 'main_screen_state.dart';

class MainScreenCubit extends Cubit<MainScreenState> {
  MainScreenCubit() : super(const MainScreenState());

  Future<void> getUserName() async {
    // CRITICAL SECURITY: Check authentication before running any logic
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = user != null;

    // ABSOLUTE WEB SECURITY: Block cubit logic if not authenticated
    if (kIsWeb && !isAuthenticated) {
      return;
    }

    // Additional security: Block if user is null or has no UID
    if (user == null || user.uid.isEmpty) {
      return;
    }

    try {
      await Database().getUsername();
      emit(state.copyWith(username: Database().username));
    } catch (e) {
      // Error fetching username - gracefully handle without rethrowing
    }
  }
}
