import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import 'sign_in_state.dart';
import '../../../enums/processing/notify_message_enum.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../data/firebase/firebase.dart';

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

class SignInCubit extends Cubit<SignInState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firebase _firebase = Firebase();

  SignInCubit() : super(const SignInState());

  void emailChanged(String email) {
    emit(state.copyWith(
      email: email,
      processState: ProcessState.idle, // Reset state
      message: NotifyMessage.empty, // Reset message
    ));
  }

  void passwordChanged(String password) {
    emit(state.copyWith(
      password: password,
      processState: ProcessState.idle, // Reset state
      message: NotifyMessage.empty, // Reset message
    ));
  }

  Future<void> signInWithEmailPassword() async {
    try {
      emit(state.copyWith(processState: ProcessState.loading));

      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: state.email, password: state.password);

      if (userCredential.user != null) {
        if (!userCredential.user!.emailVerified) {
          emit(state.copyWith(
              processState: ProcessState.failure,
              message: NotifyMessage.msg10,
              dialogName: DialogName.failure
          ));
        } else {
          emit(state.copyWith(
              processState: ProcessState.success,
              message: NotifyMessage.msg1,
              dialogName: DialogName.success
          ));
        }
      }
    } catch (error) {
      emit(state.copyWith(
          processState: ProcessState.failure,
          message: NotifyMessage.msg2,
          dialogName: DialogName.failure
      ));
    }
  }
}