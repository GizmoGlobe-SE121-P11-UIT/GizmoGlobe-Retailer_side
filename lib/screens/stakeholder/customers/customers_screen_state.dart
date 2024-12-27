import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/customer.dart';

class CustomersScreenState extends Equatable {
  final List<Customer> customers;
  final bool isLoading;
  final String searchQuery;
  final int? selectedIndex;

  const CustomersScreenState({
    this.customers = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedIndex,
  });

  CustomersScreenState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    String? searchQuery,
    int? selectedIndex,
  }) {
    return CustomersScreenState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIndex: selectedIndex,
    );
  }
  
  @override
  List<Object?> get props => [customers, isLoading, searchQuery, selectedIndex];
}
