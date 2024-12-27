import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';

class VendorDetailState extends Equatable {
  final Manufacturer manufacturer;

  const VendorDetailState({
    required this.manufacturer,
  });

  VendorDetailState copyWith({
    Manufacturer? manufacturer,
  }) {
    return VendorDetailState(
      manufacturer: manufacturer ?? this.manufacturer,
    );
  }

  @override
  List<Object?> get props => [manufacturer];
} 