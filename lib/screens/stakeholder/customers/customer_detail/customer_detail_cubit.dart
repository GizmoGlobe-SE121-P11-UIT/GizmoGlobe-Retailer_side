import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
import 'package:gizmoglobe_client/objects/voucher_related/owned_voucher.dart';
import 'package:gizmoglobe_client/objects/voucher_related/voucher.dart';
import '../../../../enums/processing/dialog_name_enum.dart';
import '../../../../enums/processing/notify_message_enum.dart';
import '../../../../enums/processing/process_state_enum.dart';
import '../../../../enums/voucher_related/voucher_status.dart';
import '../../../../objects/address_related/address.dart';
import '../../../../objects/address_related/district.dart';
import '../../../../objects/address_related/province.dart';
import '../../../../objects/address_related/ward.dart';
import 'customer_detail_state.dart';

class CustomerDetailCubit extends Cubit<CustomerDetailState> {
  final Firebase _firebase = Firebase();

  CustomerDetailCubit(Customer customer)
      : super(CustomerDetailState(customer: customer)) {
    _loadUserRole();
    _loadVouchers();
  }

  Future<void> _loadUserRole() async {
    try {
      final userRole = await _firebase.getUserRole();
      emit(state.copyWith(userRole: userRole));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user role: $e');
      }
    }
  }

  Future<void> _loadVouchers() async {
    try {
      final vouchers = await _firebase.getVouchers();
      final ownedVouchers = await _firebase.getOwnedVouchers(state.customer.customerID!);
      final ownedVoucherIds = ownedVouchers.map((ov) => ov.voucherID).toSet();

      final availableVouchers = (vouchers).where((v) {
        return v.isEnabled &&
            v.voucherTimeStatus != VoucherTimeStatus.expired &&
            !v.isVisible &&
            !v.voucherRanOut &&
            !ownedVoucherIds.contains(v.voucherID);
      }).toList();

      emit(state.copyWith(vouchers: availableVouchers));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading vouchers: $e');
      } // Lỗi khi tải voucher
    }
  }

  Future<void> updateCustomer(Customer updatedCustomer) async {
    toLoading();
    try {
      await _firebase.updateCustomer(updatedCustomer);
      emit(state.copyWith(
        customer: updatedCustomer,
        processState: ProcessState.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        processState: ProcessState.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> deleteCustomer() async {
    toLoading();
    try {
      await _firebase.deleteCustomer(state.customer.customerID!);
      emit(state.copyWith(processState: ProcessState.success));
    } catch (e) {
      emit(state.copyWith(
        processState: ProcessState.failure,
        error: e.toString(),
      ));
    }
  }

  void updateNewAddress({
    String? receiverName,
    String? receiverPhone,
    Province? province,
    District? district,
    Ward? ward,
    String? street,
    bool? isDefault,
  }) {
    emit(state.copyWith(
      newAddress: Address(
        customerID: state.customer.customerID!,
        receiverName: receiverName ?? state.newAddress?.receiverName ?? '',
        receiverPhone: receiverPhone ?? state.newAddress?.receiverPhone ?? '',
        province: province ?? state.newAddress?.province,
        district: district ?? state.newAddress?.district,
        ward: ward ?? state.newAddress?.ward,
        street: street ?? state.newAddress?.street,
        hidden: isDefault ?? state.newAddress?.hidden ?? false,
      ),
    ));
  }

  Future<void> addAddress() async {
    toLoading();
    try {
      await _firebase.createAddress(state.newAddress!);

      emit(state.copyWith(
        processState: ProcessState.success,
        newAddress: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        processState: ProcessState.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> giftVoucher(Voucher voucher) async {
    try {
      OwnedVoucher ownedVoucher = OwnedVoucher.newOwnedVoucher(
        voucher: voucher,
        customerID: state.customer.customerID!,
      );

      await _firebase.addOwnedVoucher(ownedVoucher);

      final updatedVouchers = state.vouchers.where((v) => v.voucherID != voucher.voucherID).toList();

      emit(state.copyWith(
        processState: ProcessState.success,
        vouchers: updatedVouchers,
        notifyMessage: NotifyMessage.msg26,
        dialogName: DialogName.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        processState: ProcessState.failure,
        notifyMessage: NotifyMessage.msg27,
        dialogName: DialogName.failure,
      ));
    }
  }

  void toIdle() {
    emit(state.copyWith(
      processState: ProcessState.idle,
    ));
  }

  void toLoading() {
    emit(state.copyWith(
      processState: ProcessState.loading,
    ));
  }
}