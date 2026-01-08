import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';

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
  msg17('voucherAddedSuccess'),
  msg18('voucherAddFailed'),
  msg19('voucherDeletedSuccess'),
  msg20('voucherDeleteFailed'),
  msg21('descriptionGenerated'),
  msg22('voucherEditSuccess'),
  msg23('voucherEditFailed'),
  msg24('voucherUpdateSuccess'),
  msg25('voucherUpdateFailed'),
  msg26('giveVoucherSuccess'),
  msg27('giveVoucherFailed'),
  msg28('addressAddedSuccess'),
  msg29('addressAddFailed'),
  msg30('addressUpdatedSuccess'),
  msg31('addressUpdateFailed'),
  error('unexpectedError');

  final String message;
  const NotifyMessage(this.message);

  String getName() {
    return name;
  }

  String getLocalizedMessage(BuildContext context, [String? reason]) {
    String message = '';
    switch (this) {
      case NotifyMessage.empty:
        message = '';
      case NotifyMessage.msg1:
        message = S.of(context).signInSuccess;
      case NotifyMessage.msg2:
        message = S.of(context).signInFailed;
      case NotifyMessage.msg3:
        message = S.of(context).verificationLinkFailed;
      case NotifyMessage.msg4:
        message = S.of(context).changePasswordFailed;
      case NotifyMessage.msg5:
        message = S.of(context).passwordsDoNotMatch;
      case NotifyMessage.msg6:
        message = S.of(context).verificationEmailSent;
      case NotifyMessage.msg7:
        message = S.of(context).signUpFailed;
      case NotifyMessage.msg8:
        message = S.of(context).resetPasswordLinkSent;
      case NotifyMessage.msg9:
        message = S.of(context).signOutFailed;
      case NotifyMessage.msg10:
        message = S.of(context).emailNotVerified;
      case NotifyMessage.msg11:
        message = S.of(context).invalidEmailOrPassword;
      case NotifyMessage.msg12:
        message = S.of(context).emailNotRegistered;
      case NotifyMessage.msg13:
        message = S.of(context).productAddedSuccess;
      case NotifyMessage.msg14:
        message = S.of(context).productAddFailed;
      case NotifyMessage.msg15:
        message = S.of(context).productUpdatedSuccess;
      case NotifyMessage.msg16:
        message = S.of(context).productUpdateFailed;
      case NotifyMessage.msg17:
        message = S.of(context).voucherAddedSuccess;
      case NotifyMessage.msg18:
        message = S.of(context).voucherAddFailed;
      case NotifyMessage.msg19:
        message = S.of(context).voucherDeletedSuccess;
      case NotifyMessage.msg20:
        message = S.of(context).voucherDeleteFailed;
      case NotifyMessage.msg21:
        message = S.of(context).descriptionGenerated;
      case NotifyMessage.msg22:
        message = S.of(context).voucherEditSuccess;
      case NotifyMessage.msg23:
        message = S.of(context).errorUpdatingVoucher;
      case NotifyMessage.msg24:
        message = S.of(context).voucherUpdateSuccess;
      case NotifyMessage.msg25:
        message = S.of(context).voucherUpdateFailed;
      case NotifyMessage.msg26:
        message = S.of(context).giveVoucherSuccess;
      case NotifyMessage.msg27:
        message = S.of(context).giveVoucherFailed;
      case NotifyMessage.msg28:
        message = S.of(context).addressAddedSuccess;
      case NotifyMessage.msg29:
        message = S.of(context).addressAddFailed;
      case NotifyMessage.msg30:
        message = S.of(context).addressUpdatedSuccess;
      case NotifyMessage.msg31:
        message = S.of(context).addressUpdateFailed;
      case NotifyMessage.error:
        message = S.of(context).unexpectedError;
    }

    if (reason != null && reason.isNotEmpty) {
      return '$message\nReason: $reason';
    }
    return message;
  }

  @override
  String toString() => message;
}

extension NotifyMessageExtension on NotifyMessage {
  static NotifyMessage fromName(String name) {
    return NotifyMessage.values.firstWhere((e) => e.getName() == name);
  }
}
