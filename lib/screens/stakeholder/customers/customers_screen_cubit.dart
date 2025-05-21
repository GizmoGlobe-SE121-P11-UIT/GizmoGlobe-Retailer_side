import 'dart:async';
import 'package:flutter/foundation.dart';
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
    _loadUserRole();
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
      if (kDebugMode) {
        print('Error loading customer list: $e');
      } // Lỗi khi tải danh sách khách hàng
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
      if (kDebugMode) {
        print('Error updating customer: $e');
      } // Lỗi khi cập nhật thông tin khách hàng
      // You might want to handle the error appropriately
    }
  }

  Future<void> deleteCustomer(String customerId) async {
    try {
      await _firebase.deleteCustomer(customerId);
      // No need to manually update state as the stream will handle it
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting customer: $e');
      } // Lỗi khi xóa khách hàng
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
      if (kDebugMode) {
        print('Error creating customer: $e');
      } // Lỗi khi tạo khách hàng
      return e.toString(); // Return error message
    }
  }

  Future<void> _loadUserRole() async {
    try {
      final userRole = await _firebase.getUserRole();
      emit(state.copyWith(userRole: userRole));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading user role: $e');
      } // Lỗi khi tải vai trò người dùng
    }
  }
}