import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';

enum NotifyMessage {
  empty(''),
  msg1('signInSuccess'),
  msg2('signInFailed'),
  msg3('verificationLinkFailed'),
  msg4('changePasswordFailed'),
  msg5('passwordsDoNotMatch'),
  msg6('verificationEmailSent'),
  msg7('signUpFailed'),
  msg8('resetPasswordLinkSent'),
  msg9('signOutFailed'),
  msg10('emailNotVerified'),
  msg11('invalidEmailOrPassword'),
  msg12('emailNotRegistered'),
  msg13('productAddedSuccess'),
  msg14('productAddFailed'),
  msg15('productUpdatedSuccess'),
  msg16('productUpdateFailed'),
  msg17('Voucher added successfully.'), // Voucher đã được thêm thành công
  msg18('Failed to add voucher. Please try again.'), // Không thể thêm voucher. Vui lòng thử lại
  msg19('Voucher deleted successfully.'), // Voucher đã được xóa thành công
  msg20('Failed to delete voucher. Please try again.'), // Không thể xóa voucher. Vui lòng thử lại
  error('unexpectedError');
  
  final String message;
  const NotifyMessage(this.message);

  String getName() {
    return name;
  }

  String getLocalizedMessage(BuildContext context) {
    switch (this) {
      case NotifyMessage.empty:
        return '';
      case NotifyMessage.msg1:
        return S.of(context).signInSuccess;
      case NotifyMessage.msg2:
        return S.of(context).signInFailed;
      case NotifyMessage.msg3:
        return S.of(context).verificationLinkFailed;
      case NotifyMessage.msg4:
        return S.of(context).changePasswordFailed;
      case NotifyMessage.msg5:
        return S.of(context).passwordsDoNotMatch;
      case NotifyMessage.msg6:
        return S.of(context).verificationEmailSent;
      case NotifyMessage.msg7:
        return S.of(context).signUpFailed;
      case NotifyMessage.msg8:
        return S.of(context).resetPasswordLinkSent;
      case NotifyMessage.msg9:
        return S.of(context).signOutFailed;
      case NotifyMessage.msg10:
        return S.of(context).emailNotVerified;
      case NotifyMessage.msg11:
        return S.of(context).invalidEmailOrPassword;
      case NotifyMessage.msg12:
        return S.of(context).emailNotRegistered;
      case NotifyMessage.msg13:
        return S.of(context).productAddedSuccess;
      case NotifyMessage.msg14:
        return S.of(context).productAddFailed;
      case NotifyMessage.msg15:
        return S.of(context).productUpdatedSuccess;
      case NotifyMessage.msg16:
        return S.of(context).productUpdateFailed;
      case NotifyMessage.error:
        return S.of(context).unexpectedError;
    }
  }

  @override
  String toString() => message;
}

extension NotifyMessageExtension on NotifyMessage {
  static NotifyMessage fromName(String name) {
    return NotifyMessage.values.firstWhere((e) => e.getName() == name);
  }
}
