import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import '../../../enums/stakeholders/manufacturer_status.dart';
import 'vendors_screen_state.dart';

class VendorsScreenCubit extends Cubit<VendorsScreenState> {
  final _firebase = Firebase();
  late final Stream<List<Manufacturer>> _manufacturersStream;
  StreamSubscription<List<Manufacturer>>? _subscription;

  VendorsScreenCubit() : super(const VendorsScreenState()) {
    _manufacturersStream = _firebase.manufacturersStream();
    _listenToManufacturers();
    loadManufacturers();
    _loadUserRole();
  }

  void _listenToManufacturers() {
    _subscription = _manufacturersStream.listen((manufacturers) {
      if (state.searchQuery.isEmpty) {
        emit(state.copyWith(manufacturers: manufacturers));
      } else {
        searchManufacturers(state.searchQuery);
      }
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  Future<void> loadManufacturers() async {
    emit(state.copyWith(isLoading: true));
    try {
      final manufacturers = await _firebase.getManufacturers();
      emit(state.copyWith(
        manufacturers: manufacturers,
        isLoading: false,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading manufacturer list: $e');
      } // Lỗi khi tải danh sách nhà sản xuất
      emit(state.copyWith(isLoading: false));
    }
  }

  void searchManufacturers(String query) {
    emit(state.copyWith(searchQuery: query));
    
    if (query.isEmpty) {
      loadManufacturers();
      return;
    }

    final filteredManufacturers = state.manufacturers.where((manufacturer) {
      return manufacturer.manufacturerName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    emit(state.copyWith(manufacturers: filteredManufacturers));
  }

  void setSelectedIndex(int? index) {
    emit(state.copyWith(selectedIndex: index));
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

  Future<void> deactivateManufacturer(Manufacturer manufacturer) async {
    try {
      final updatedManufacturer = manufacturer.copyWith(
        status: ManufacturerStatus.inactive,
      );
      await _firebase.updateManufacturer(updatedManufacturer);
    } catch (e) {
      if (kDebugMode) {
        print('Error deactivating manufacturer: $e');
      } // Lỗi khi vô hiệu hóa nhà sản xuất
    }
  }

  Future<String?> createManufacturer(String name, ManufacturerStatus status) async {
    try {
      final manufacturer = Manufacturer(
        manufacturerID: name.trim(),
        manufacturerName: name.trim(),
        status: status,
      );
      await _firebase.createManufacturer(manufacturer);
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating manufacturer: $e');
      } // Lỗi khi tạo nhà sản xuất
      return e.toString();
    }
  }

  Future<void> toggleManufacturerStatus(Manufacturer manufacturer) async {
    try {
      final newStatus = manufacturer.status == ManufacturerStatus.active
        ? ManufacturerStatus.inactive
        : ManufacturerStatus.active;
        
      final updatedManufacturer = manufacturer.copyWith(
        status: newStatus,
      );
      await _firebase.updateManufacturerAndProducts(updatedManufacturer);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling manufacturer status: $e');
      } // Lỗi khi chuyển đổi trạng thái nhà sản xuất
    }
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
}