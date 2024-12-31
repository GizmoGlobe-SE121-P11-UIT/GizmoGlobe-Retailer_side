import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/data/database/database.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_state.dart';

import '../../../data/firebase/firebase.dart';
import '../../../enums/processing/dialog_name_enum.dart';
import '../../../enums/processing/notify_message_enum.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/product_related/category_enum.dart';
import '../../../enums/product_related/product_status_enum.dart';
import '../../../objects/product_related/cpu.dart';
import '../../../objects/product_related/drive.dart';
import '../../../objects/product_related/gpu.dart';
import '../../../objects/product_related/mainboard.dart';
import '../../../objects/product_related/psu.dart';
import '../../../objects/product_related/ram.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit(Product product) : super(ProductDetailState(product: product)) {
    _initializeTechnicalSpecs();
  }

  void _initializeTechnicalSpecs() {
    final product = state.product;
    final Map<String, String> specs = {};

    switch (product.category) {
      case CategoryEnum.ram:
        final ram = product as RAM;
        specs.addAll({
          'Bus': ram.bus.toString(),
          'Capacity': ram.capacity.toString(),
          'Type': ram.ramType.toString(),
        });
        break;

      case CategoryEnum.cpu:
        final cpu = product as CPU;
        specs.addAll({
          'Family': cpu.family.toString(),
          'Core': cpu.core.toString(),
          'Thread': cpu.thread.toString(),
          'Clock Speed': '${cpu.clockSpeed} GHz',
        });
        break;

      case CategoryEnum.gpu:
        final gpu = product as GPU;
        specs.addAll({
          'Series': gpu.series.toString(),
          'Memory': gpu.capacity.toString(),
          'Bus Width': gpu.bus.toString(),
          'Clock Speed': '${gpu.clockSpeed} MHz',
        });
        break;

      case CategoryEnum.mainboard:
        final mainboard = product as Mainboard;
        specs.addAll({
          'Form Factor': mainboard.formFactor.toString(),
          'Series': mainboard.series.toString(),
          'Compatibility': mainboard.compatibility.toString(),
        });
        break;

      case CategoryEnum.drive:
        final drive = product as Drive;
        specs.addAll({
          'Type': drive.type.toString(),
          'Capacity': drive.capacity.toString(),
        });
        break;

      case CategoryEnum.psu:
        final psu = product as PSU;
        specs.addAll({
          'Wattage': '${psu.wattage}W',
          'Efficiency': psu.efficiency.toString(),
          'Modular': psu.modular.toString(),
        });
        break;

      default:
        print('Unknown category');
    }

    emit(state.copyWith(technicalSpecs: specs));
  }

  void toLoading() {
    emit(state.copyWith(processState: ProcessState.loading));
  }

  Future<void> changeProductStatus() async {
    try {
      ProductStatusEnum status;
      if (state.product.status == ProductStatusEnum.discontinued) {
        if (state.product.stock == 0) {
          status = ProductStatusEnum.outOfStock;
        } else {
          status = ProductStatusEnum.active;
        }
      } else {
        status = ProductStatusEnum.discontinued;
      }

      await Firebase().changeProductStatus(state.product.productID!, status);

      Product product = state.product;
      product.updateProduct(status: status);
      emit(state.copyWith(product: product));

      emit(state.copyWith(processState: ProcessState.success, notifyMessage: NotifyMessage.msg15, dialogName: DialogName.success));
    } catch (e) {
      print(e);
      emit(state.copyWith(processState: ProcessState.failure, notifyMessage: NotifyMessage.msg16, dialogName: DialogName.failure));
    }
  }

  void updateProduct() {
    Product product = Database().productList.firstWhere((element) => element.productID == state.product.productID);
    emit(state.copyWith(product: product));
    _initializeTechnicalSpecs();
  }

  void toIdle() {
    emit(state.copyWith(processState: ProcessState.idle));
  }
}