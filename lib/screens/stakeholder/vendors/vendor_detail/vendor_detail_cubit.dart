import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'vendor_detail_state.dart';

class VendorDetailCubit extends Cubit<VendorDetailState> {
  final _firebase = Firebase();

  VendorDetailCubit(Manufacturer manufacturer)
      : super(VendorDetailState(manufacturer: manufacturer));

  Future<void> updateManufacturer(Manufacturer manufacturer) async {
    try {
      await _firebase.updateManufacturer(manufacturer);
      emit(state.copyWith(manufacturer: manufacturer));
    } catch (e) {
      print('Error updating manufacturer: $e');
    }
  }

  Future<void> deleteManufacturer() async {
    try {
      await _firebase.deleteManufacturer(state.manufacturer.manufacturerID!);
    } catch (e) {
      print('Error deleting manufacturer: $e');
    }
  }
} 