import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';

class VendorsScreenState extends Equatable {
  final List<Manufacturer> manufacturers;
  final bool isLoading;
  final String searchQuery;
  final int? selectedIndex;

  const VendorsScreenState({
    this.manufacturers = const [],
    this.isLoading = false,
    this.searchQuery = '',
    this.selectedIndex,
  });

  VendorsScreenState copyWith({
    List<Manufacturer>? manufacturers,
    bool? isLoading,
    String? searchQuery,
    int? selectedIndex,
  }) {
    return VendorsScreenState(
      manufacturers: manufacturers ?? this.manufacturers,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedIndex: selectedIndex,
    );
  }

  @override
  List<Object?> get props => [manufacturers, isLoading, searchQuery, selectedIndex];
}
