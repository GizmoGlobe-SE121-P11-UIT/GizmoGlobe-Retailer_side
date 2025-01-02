import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/address_related/address.dart';
import 'package:gizmoglobe_client/objects/customer.dart';

class CustomerDetailState extends Equatable {
  final Customer customer;
  final bool isLoading;
  final String? error;
  final Address? newAddress;
  final String? userRole;

  const CustomerDetailState({
    required this.customer,
    this.isLoading = false,
    this.error,
    this.newAddress,
    this.userRole,
  });

  CustomerDetailState copyWith({
    Customer? customer,
    bool? isLoading,
    String? error,
    Address? newAddress,
    String? userRole,
  }) {
    return CustomerDetailState(
      customer: customer ?? this.customer,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      newAddress: newAddress ?? this.newAddress,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  List<Object?> get props => [customer, isLoading, error, newAddress, userRole];
} 