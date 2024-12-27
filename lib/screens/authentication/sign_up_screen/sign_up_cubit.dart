import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gizmoglobe_client/enums/processing/dialog_name_enum.dart';
import 'package:gizmoglobe_client/enums/processing/notify_message_enum.dart';
import '../../../data/firebase/firebase.dart';
import 'sign_up_state.dart';
import '../../../enums/processing/process_state_enum.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Firebase _firebase = Firebase();

  SignUpCubit() : super(const SignUpState());

  // void updateUsername(String username) {
  //   emit(state.copyWith(
  //       username: username,
  //       processState: ProcessState.idle, // Reset state
  //       message: NotifyMessage.empty,  // Reset message
  //   ));
  // }

  void updateEmail(String email) {
    emit(state.copyWith(
        email: email,
        processState: ProcessState.idle, // Reset state
        message: NotifyMessage.empty,  // Reset message
    ));
  }

  void updatePassword(String password) {
    emit(state.copyWith(
        password: password,
        processState: ProcessState.idle, // Reset state
        message: NotifyMessage.empty,  // Reset message
    ));
  }

  void updateConfirmPassword(String confirmPassword) {
    emit(state.copyWith(
        confirmPassword: confirmPassword,
        processState: ProcessState.idle, // Reset state
        message: NotifyMessage.empty,  // Reset message
    ));
  }

  Future<void> signUp() async {
    try {
      // Kiểm tra password match
      if (state.password != state.confirmPassword) {
        emit(state.copyWith(
          processState: ProcessState.failure, 
          message: NotifyMessage.msg5
        ));
        return;
      }

      // Bắt đầu quá trình đăng ký
      emit(state.copyWith(processState: ProcessState.loading));

      // Kiểm tra email có tồn tại trong bảng users không
      bool userExists = await _firebase.checkUserExistsInDatabase(state.email);
      
      if (!userExists) {
        emit(state.copyWith(
          processState: ProcessState.failure,
          message: NotifyMessage.msg12,
          dialogName: DialogName.failure
        ));
        return;
      }

      // Kiểm tra email đã tồn tại trong auth
      final signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(state.email);
      if (signInMethods.isNotEmpty) {
        emit(state.copyWith(
          processState: ProcessState.failure,
          message: NotifyMessage.msg7,
          dialogName: DialogName.failure
        ));
        return;
      }

      // Tạo tài khoản Firebase Auth
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: state.email,
        password: state.password
      );

      if (userCredential.user != null) {
        try {
          // Gửi email xác thực
          await userCredential.user!.sendEmailVerification();
          
          // Tìm document trong users collection với email tương ứng
          QuerySnapshot userDocs = await _firestore
              .collection('users')
              .where('email', isEqualTo: state.email)
              .get();

          if (userDocs.docs.isNotEmpty) {
            String oldDocId = userDocs.docs.first.id;
            Map<String, dynamic> userData = userDocs.docs.first.data() as Map<String, dynamic>;

            // Cập nhật document ID trong users collection
            await _firestore.collection('users').doc(userCredential.user!.uid).set({
              ...userData,
              'userID': userCredential.user!.uid,
            });

            // Xóa document cũ
            await _firestore.collection('users').doc(oldDocId).delete();

            // Cập nhật document ID trong employees collection nếu có
            QuerySnapshot employeeDocs = await _firestore
                .collection('employees')
                .where('email', isEqualTo: state.email)
                .get();

            if (employeeDocs.docs.isNotEmpty) {
              String oldEmployeeDocId = employeeDocs.docs.first.id;
              Map<String, dynamic> employeeData = employeeDocs.docs.first.data() as Map<String, dynamic>;

              // Cập nhật document với ID mới
              await _firestore.collection('employees').doc(userCredential.user!.uid).set({
                ...employeeData,
                'employeeID': userCredential.user!.uid,
              });

              // Xóa document cũ
              await _firestore.collection('employees').doc(oldEmployeeDocId).delete();
            }
          }

          emit(state.copyWith(
            processState: ProcessState.success,
            dialogName: DialogName.success,
            message: NotifyMessage.msg6
          ));
        } catch (firestoreError) {
          print('Firestore Error: $firestoreError');
          // Xóa tài khoản Auth nếu có lỗi
          await userCredential.user?.delete();
          throw firestoreError;
        }
      }
    } catch (error) {
      print('Sign Up Error: $error');
      
      String errorMessage = 'Đăng ký thất bại';
      if (error is FirebaseAuthException) {
        switch (error.code) {
          case 'email-already-in-use':
            errorMessage = 'Email đã được sử dụng';
            break;
          case 'weak-password':
            errorMessage = 'Mật khẩu quá yếu';
            break;
          case 'invalid-email':
            errorMessage = 'Email không hợp lệ';
            break;
          default:
            errorMessage = error.message ?? 'Lỗi không xác định';
        }
      }

      emit(state.copyWith(
        processState: ProcessState.failure,
        dialogName: DialogName.failure,
        message: NotifyMessage.msg7
      ));
    }
  }
}