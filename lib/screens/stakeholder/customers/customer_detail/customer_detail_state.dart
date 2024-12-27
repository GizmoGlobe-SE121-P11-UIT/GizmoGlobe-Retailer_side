import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/customer.dart';

class CustomerDetailState extends Equatable {
  final Customer customer;
  final bool isLoading;
  final String? error;

  const CustomerDetailState({
    required this.customer,
    this.isLoading = false,
    this.error,
  });

  CustomerDetailState copyWith({
    Customer? customer,
    bool? isLoading,
    String? error,
  }) {
    return CustomerDetailState(
      customer: customer ?? this.customer,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [customer, isLoading, error];
} 