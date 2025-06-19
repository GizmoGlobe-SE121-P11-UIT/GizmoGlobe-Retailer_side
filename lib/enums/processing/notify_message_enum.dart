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
      case NotifyMessage.msg17:
        return S.of(context).voucherAddedSuccess;
      case NotifyMessage.msg18:
        return S.of(context).voucherAddFailed;
      case NotifyMessage.msg19:
        return S.of(context).voucherDeletedSuccess;
      case NotifyMessage.msg20:
        return S.of(context).voucherDeleteFailed;
      case NotifyMessage.msg21:
        return S.of(context).descriptionGenerated;
      case NotifyMessage.msg22:
        return S.of(context).voucherEditSuccess;
      case NotifyMessage.msg23:
        return S.of(context).errorUpdatingVoucher;
      case NotifyMessage.msg24:
        return S.of(context).voucherUpdateSuccess;
      case NotifyMessage.msg25:
        return S.of(context).voucherUpdateFailed;
      case NotifyMessage.msg26:
        return S.of(context).giveVoucherSuccess;
      case NotifyMessage.msg27:
        return S.of(context).giveVoucherFailed;
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
