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
      emit(state.copyWith(userRole: userRole));
    } catch (e) {
      print('Error loading user role: $e');
    }
  }

  Future<void> updateManufacturer(Manufacturer manufacturer) async {
    try {
      await _firebase.updateManufacturer(manufacturer);
      emit(state.copyWith(manufacturer: manufacturer));
    } catch (e) {
      print('Error updating manufacturer: $e');
    }
  }

  Future<void> deactivateManufacturer() async {
    try {
      final updatedManufacturer = state.manufacturer.copyWith(
        status: ManufacturerStatus.inactive,
      );
      await _firebase.updateManufacturer(updatedManufacturer);
      emit(state.copyWith(manufacturer: updatedManufacturer));
    } catch (e) {
      print('Error deactivating manufacturer: $e');
    }
  }

  Future<void> toggleManufacturerStatus() async {
    try {
      final newStatus = state.manufacturer.status == ManufacturerStatus.active
        ? ManufacturerStatus.inactive
        : ManufacturerStatus.active;
        
      final updatedManufacturer = state.manufacturer.copyWith(
        status: newStatus,
      );
      await _firebase.updateManufacturerAndProducts(updatedManufacturer);
      emit(state.copyWith(manufacturer: updatedManufacturer));
    } catch (e) {
      print('Error toggling manufacturer status: $e');
    }
  }
} 