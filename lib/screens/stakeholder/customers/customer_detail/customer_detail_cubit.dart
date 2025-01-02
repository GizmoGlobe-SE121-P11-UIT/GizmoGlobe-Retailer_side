import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/database/database.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
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
  }

  Future<void> _loadUserRole() async {
    try {
      final userRole = await _firebase.getUserRole();
      emit(state.copyWith(userRole: userRole));
    } catch (e) {
      print('Error loading user role: $e');
    }
  }

  Future<void> updateCustomer(Customer updatedCustomer) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _firebase.updateCustomer(updatedCustomer);
      emit(state.copyWith(
        customer: updatedCustomer,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> deleteCustomer() async {
    emit(state.copyWith(isLoading: true));
    try {
      await _firebase.deleteCustomer(state.customer.customerID!);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
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
    emit(state.copyWith(isLoading: true));
    try {
      await _firebase.createAddress(state.newAddress!);

      emit(state.copyWith(
        isLoading: false,
        newAddress: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }
} 