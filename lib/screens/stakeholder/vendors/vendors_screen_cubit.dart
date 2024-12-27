import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'vendors_screen_state.dart';

class VendorsScreenCubit extends Cubit<VendorsScreenState> {
  final _firebase = Firebase();
  late final Stream<List<Manufacturer>> _manufacturersStream;
  StreamSubscription<List<Manufacturer>>? _subscription;

  VendorsScreenCubit() : super(const VendorsScreenState()) {
    _manufacturersStream = _firebase.manufacturersStream();
    _listenToManufacturers();
    loadManufacturers();
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
      print('Lỗi khi tải danh sách nhà sản xuất: $e');
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
      await _firebase.updateManufacturer(manufacturer);
    } catch (e) {
      print('Error updating manufacturer: $e');
    }
  }

  Future<void> deleteManufacturer(String manufacturerId) async {
    try {
      await _firebase.deleteManufacturer(manufacturerId);
    } catch (e) {
      print('Error deleting manufacturer: $e');
    }
  }

  Future<String?> createManufacturer(String name) async {
    try {
      final manufacturer = Manufacturer(
        manufacturerID: name.trim(),
        manufacturerName: name.trim(),
      );
      await _firebase.createManufacturer(manufacturer);
      return null;
    } catch (e) {
      print('Error creating manufacturer: $e');
      return e.toString();
    }
  }
}
