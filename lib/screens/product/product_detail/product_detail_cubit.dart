import 'package:flutter/foundation.dart';
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
          'Bus': ram.bus.toString(), //Tốc độ bus
          'Capacity': ram.capacity.toString(), //Dung lượng
          'Type': ram.ramType.toString(), //Loại RAM
        });
        break;

      case CategoryEnum.cpu:
        final cpu = product as CPU;
        specs.addAll({
          'Family': cpu.family.toString(), //Thế hệ
          'Core': cpu.core.toString(), //Số nhân
          'Thread': cpu.thread.toString(), //Số luồng
          'Clock Speed': '${cpu.clockSpeed} GHz', //Tốc độ xung nhịp
        });
        break;

      case CategoryEnum.gpu:
        final gpu = product as GPU;
        specs.addAll({
          'Series': gpu.series.toString(), //Dòng sản phẩm
          'Memory': gpu.capacity.toString(), //Dung lượng
          'Bus Width': gpu.bus.toString(), //Băng thông
          'Clock Speed': '${gpu.clockSpeed} MHz', //Tốc độ xung nhịp
        });
        break;

      case CategoryEnum.mainboard:
        final mainboard = product as Mainboard;
        specs.addAll({
          'Form Factor': mainboard.formFactor.toString(), //Kích thước
          'Series': mainboard.series.toString(), //Dòng sản phẩm
          'Compatibility': mainboard.compatibility.toString(), //Tương thích
        });
        break;

      case CategoryEnum.drive:
        final drive = product as Drive;
        specs.addAll({
          'Type': drive.type.toString(), //Loại ổ đĩa
          'Capacity': drive.capacity.toString(), //Dung lượng
        });
        break;

      case CategoryEnum.psu:
        final psu = product as PSU;
        specs.addAll({
          'Wattage': '${psu.wattage}W', //Công suất
          'Efficiency': psu.efficiency.toString(), //Hiệu suất
          'Modular': psu.modular.toString(), //Modular
        });
        break;

      default:
        if (kDebugMode) {
          print('Unknown category');
        } //Danh mục không xác định
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
      if (kDebugMode) {
        print(e);
      }
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