import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';

class VendorsScreenState extends Equatable {
  final List<Manufacturer> manufacturers;
  final bool isLoading;
  final String searchQuery;
  final int? selectedIndex;
  final String? userRole;

  const VendorsScreenState({
    this.manufacturers = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedIndex,
    this.userRole,
  });

  VendorsScreenState copyWith({
    List<Manufacturer>? manufacturers,
    bool? isLoading,
    String? searchQuery,
    int? selectedIndex,
    String? userRole,
  }) {
    return VendorsScreenState(
      manufacturers: manufacturers ?? this.manufacturers,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIndex: selectedIndex,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  List<Object?> get props => [
    manufacturers, 
    isLoading, 
    searchQuery, 
    selectedIndex,
    userRole,
  ];
}
