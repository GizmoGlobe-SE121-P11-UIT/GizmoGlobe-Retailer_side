import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/enums/processing/process_state_enum.dart';
import 'package:gizmoglobe_client/objects/address_related/address.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
import 'package:gizmoglobe_client/objects/voucher_related/owned_voucher.dart';

import '../../../../enums/processing/dialog_name_enum.dart';
import '../../../../enums/processing/notify_message_enum.dart';
import '../../../../objects/voucher_related/voucher.dart';

class CustomerDetailState extends Equatable {
  final Customer customer;
  final String? error;
  final Address? newAddress;
  final String? userRole;
  final DialogName dialogName;
  final NotifyMessage notifyMessage;
  final ProcessState processState;

  final List<Voucher> vouchers;

  const CustomerDetailState({
    required this.customer,
    this.error,
    this.newAddress,
    this.userRole,
    this.vouchers = const [],
    this.dialogName = DialogName.empty,
    this.notifyMessage = NotifyMessage.empty,
    this.processState = ProcessState.idle,
  });

  CustomerDetailState copyWith({
    Customer? customer,
    String? error,
    Address? newAddress,
    String? userRole,
    List<Voucher>? vouchers,
    List<OwnedVoucher>? ownedVouchers,
    DialogName? dialogName,
    NotifyMessage? notifyMessage,
    ProcessState? processState,
  }) {
    return CustomerDetailState(
      customer: customer ?? this.customer,
      error: error,
      newAddress: newAddress ?? this.newAddress,
      userRole: userRole ?? this.userRole,
      vouchers: vouchers ?? [],
      dialogName: dialogName ?? this.dialogName,
      notifyMessage: notifyMessage ?? this.notifyMessage,
      processState: processState ?? this.processState,
    );
  }

  @override
  List<Object?> get props => [
    customer,
    error,
    newAddress,
    userRole,
    vouchers,
    dialogName,
    notifyMessage,
    processState,
  ];
} 