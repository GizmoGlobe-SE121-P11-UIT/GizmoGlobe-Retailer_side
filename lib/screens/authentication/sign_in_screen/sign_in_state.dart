import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/enums/processing/dialog_name_enum.dart';
import 'package:gizmoglobe_client/enums/processing/notify_message_enum.dart';

import '../../../enums/processing/process_state_enum.dart';

class SignInState with EquatableMixin  {
  final ProcessState processState;
  final DialogName dialogName;
  final NotifyMessage message;
  final String email;
  final String password;

  const SignInState({
    this.processState = ProcessState.idle,
    this.dialogName = DialogName.empty,
    this.message = NotifyMessage.empty,
    this.email = '',
    this.password = '',
  });

  @override
  List<Object?> get props => [processState, dialogName, message, email, password];

  SignInState copyWith({
    ProcessState? processState,
    DialogName? dialogName,
    NotifyMessage? message,
    String? email,
    String? password,
  }) {
    return SignInState(
      processState: processState ?? this.processState,
      dialogName: dialogName ?? this.dialogName,
      message: message ?? this.message,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}