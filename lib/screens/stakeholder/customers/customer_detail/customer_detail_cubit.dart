import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
import 'customer_detail_state.dart';

class CustomerDetailCubit extends Cubit<CustomerDetailState> {
  final Firebase _firebase = Firebase();

  CustomerDetailCubit(Customer customer) 
      : super(CustomerDetailState(customer: customer));

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
} 