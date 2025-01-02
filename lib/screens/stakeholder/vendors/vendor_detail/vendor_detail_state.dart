import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';

class VendorDetailState extends Equatable {
  final Manufacturer manufacturer;
  final String? userRole;

  const VendorDetailState({
    required this.manufacturer,
    this.userRole,
  });

  VendorDetailState copyWith({
    Manufacturer? manufacturer,
    String? userRole,
  }) {
    return VendorDetailState(
      manufacturer: manufacturer ?? this.manufacturer,
      userRole: userRole ?? this.userRole,
    );
  }

  @override
  List<Object?> get props => [manufacturer, userRole];
} 