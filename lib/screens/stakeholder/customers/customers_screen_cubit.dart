import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/customer.dart';
import 'customers_screen_state.dart';

class CustomersScreenCubit extends Cubit<CustomersScreenState> {
  final _firebase = Firebase();
  late final Stream<List<Customer>> _customersStream;
  StreamSubscription<List<Customer>>? _subscription;

  CustomersScreenCubit() : super(const CustomersScreenState()) {
    _customersStream = _firebase.customersStream();
    _listenToCustomers();
    loadCustomers();
  }

  void _listenToCustomers() {
    _subscription = _customersStream.listen((customers) {
      if (state.searchQuery.isEmpty) {
        emit(state.copyWith(customers: customers));
      } else {
        searchCustomers(state.searchQuery);
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  Future<void> loadCustomers() async {
    emit(state.copyWith(isLoading: true));
    try {
      final customers = await _firebase.getCustomers();
      emit(state.copyWith(
        customers: customers,
        isLoading: false,
      ));
    } catch (e) {
      print('Lỗi khi tải danh sách khách hàng: $e');
      emit(state.copyWith(isLoading: false));
    }
  }

  void searchCustomers(String query) {
    emit(state.copyWith(searchQuery: query));
    
    if (query.isEmpty) {
      loadCustomers();
      return;
    }

    final filteredCustomers = state.customers.where((customer) {
      return customer.customerName.toLowerCase().contains(query.toLowerCase()) ||
          customer.email.toLowerCase().contains(query.toLowerCase()) ||
          customer.phoneNumber.contains(query);
    }).toList();

    emit(state.copyWith(customers: filteredCustomers));
  }

  void setSelectedIndex(int? index) {
    emit(state.copyWith(selectedIndex: index));
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await _firebase.updateCustomer(customer);
      // No need to manually update state as the stream will handle it
    } catch (e) {
      print('Error updating customer: $e');
      // You might want to handle the error appropriately
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firebase.deleteCustomer(customerId);
      // No need to manually update state as the stream will handle it
    } catch (e) {
      print('Error deleting customer: $e');
      // You might want to handle the error appropriately
    }
  }

  Future<String?> createCustomer(String name, String email, String phone) async {
    try {
      final customer = Customer(
        customerID: null,
        customerName: name.trim(),
        email: email.trim(),
        phoneNumber: phone.trim(),
      );
      
      await _firebase.createCustomer(customer);
      return null; // Return null if successful
      
    } catch (e) {
      print('Error creating customer: $e');
      return e.toString(); // Return error message
    }
  }
}
