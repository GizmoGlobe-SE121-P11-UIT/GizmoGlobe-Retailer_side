import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/enums/stakeholders/manufacturer_status.dart';
import 'vendor_detail_state.dart';

class VendorDetailCubit extends Cubit<VendorDetailState> {
  final _firebase = Firebase();

  VendorDetailCubit(Manufacturer manufacturer)
      : super(VendorDetailState(manufacturer: manufacturer)) {
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final userRole = await _firebase.getUserRole();
      if (!isClosed) {
        emit(state.copyWith(userRole: userRole));
      }
    } catch (e) {
      // Error loading user role
    }
  }

  Future<void> updateManufacturer(Manufacturer manufacturer) async {
    try {
      await _firebase.updateManufacturerAndProducts(manufacturer);
    } catch (e) {
      // Error updating manufacturer
    }
  }

  Future<void> deactivateManufacturer() async {
    if (isClosed) return;
    try {
      final updatedManufacturer = state.manufacturer.copyWith(
        status: ManufacturerStatus.inactive,
      );
      await _firebase.updateManufacturer(updatedManufacturer);
      if (!isClosed) {
        emit(state.copyWith(manufacturer: updatedManufacturer));
      }
    } catch (e) {
      // Error deactivating manufacturer
    }
  }

  Future<void> toggleManufacturerStatus() async {
    if (isClosed) return;
    try {
      final newStatus = state.manufacturer.status == ManufacturerStatus.active
          ? ManufacturerStatus.inactive
          : ManufacturerStatus.active;

      final updatedManufacturer = state.manufacturer.copyWith(
        status: newStatus,
      );
      await _firebase.updateManufacturerAndProducts(updatedManufacturer);
      if (!isClosed) {
        emit(state.copyWith(manufacturer: updatedManufacturer));
      }
    } catch (e) {
      // Error toggling manufacturer status
    }
  }
}
