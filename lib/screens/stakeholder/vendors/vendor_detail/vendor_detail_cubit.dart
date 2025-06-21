import 'package:flutter/foundation.dart';
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
      if (kDebugMode) {
        print('Error loading user role: $e');
      } // Lỗi khi tải vai trò người dùng
    }
  }

  Future<void> updateManufacturer(Manufacturer manufacturer) async {
    try {
      await _firebase.updateManufacturerAndProducts(manufacturer);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating manufacturer: $e');
      } // Lỗi khi cập nhật nhà sản xuất
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
      if (kDebugMode) {
        print('Error deactivating manufacturer: $e');
      } // Lỗi khi vô hiệu hóa nhà sản xuất
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
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling manufacturer status: $e');
      } // Lỗi khi chuyển đổi trạng thái nhà sản xuất
    }
  }
}
