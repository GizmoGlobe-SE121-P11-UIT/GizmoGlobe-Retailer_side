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
import '../../../objects/product_related/cpu_related/cpu.dart';
import '../../../objects/product_related/drive_related/drive.dart';
import '../../../objects/product_related/gpu_related/gpu.dart';
import '../../../objects/product_related/mainboard_related/mainboard.dart';
import '../../../objects/product_related/psu_related/psu.dart';
import '../../../objects/product_related/ram_related/ram.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  ProductDetailCubit(Product product)
      : super(ProductDetailState(product: product)) {
    _initializeTechnicalSpecs();
    _loadImages();
  }

  void _initializeTechnicalSpecs() {
    final product = state.product;
    final Map<String, String> specs = {};

    switch (product.category) {
      case CategoryEnum.ram:
        final ram = product as RAM;
        specs.addAll({
          'Type': ram.type.toString(),
          'Bus': '${ram.bus} MHz',
          'CL Latency': 'CL${ram.clLatency}',
          'Kit Stick Count': ram.kitStickCount.toString(),
          'Capacity per Stick': '${ram.capacityPerStickGb} GB',
        });
        break;

      case CategoryEnum.cpu:
        final cpu = product as CPU;
        specs.addAll({
          'Cores': cpu.core.toString(),
          'Threads': cpu.thread.toString(),
          'Base Clock': '${cpu.baseClock} GHz',
          'Turbo Clock': '${cpu.turboClock} GHz',
          'TDP': '${cpu.tdp} W',
          'Socket': cpu.socket.toString(),
        });
        break;

      case CategoryEnum.gpu:
        final gpu = product as GPU;
        specs.addAll({
          'Version': gpu.version.toString(),
          'Memory': gpu.memory.toString(),
          'Clock Speed': '${gpu.boostClock} MHz',
          'TDP': '${gpu.tdp} W',
          'I/O Ports': gpu.ports.map((port) => port.toString()).join('\n'),
        });
        break;

      case CategoryEnum.mainboard:
        final mainboard = product as Mainboard;
        specs.addAll({
          'Chipset': mainboard.chipsetCode.toString(),
          'Socket': mainboard.socket.toString(),
          'Form Factor': mainboard.formFactor.toString(),
          'RAM Spec': mainboard.ramSpec.toString(),
          'Storage:': mainboard.storageSlot.toString(),
          'PCIe Slots:':
              mainboard.pcieSlots.map((slot) => slot.toString()).join('\n'),
          'I/O Ports:':
              mainboard.ioPorts.map((port) => port.toString()).join('\n'),
        });
        break;

      case CategoryEnum.drive:
        final drive = product as Drive;
        specs.addAll({
          'Drive Type': drive.driveType.toString(),
          'Generation': drive.gen.toString(),
          'Capacity': '${drive.memoryGb} GB',
          'Interface': drive.interfaceType.toString(),
          'Form Factor': drive.formFactor.toString(),
          'Read Speed': '${drive.speed.readMbps} MB/s',
          'Write Speed': '${drive.speed.writeMbps} MB/s',
        });
        break;

      case CategoryEnum.psu:
        final psu = product as PSU;
        specs.addAll({
          'Wattage': '${psu.maxWattage} W',
          'Efficiency Rating': psu.efficiency.toString(),
          'Modularity': psu.modularity.toString(),
          'Connectors':
              psu.connectors.map((type) => type.toString()).join('\n'),
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

  Future<void> _loadImages() async {
    final productId = state.product.productID;
    if (productId == null) return;
    try {
      final urls = await Firebase().getProductImages(productId);
      emit(state.copyWith(imageUrls: urls));
    } catch (e) {
      if (kDebugMode) {
        print('Error loading product images: $e');
      }
    }
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

      emit(state.copyWith(
          processState: ProcessState.success,
          notifyMessage: NotifyMessage.msg15,
          dialogName: DialogName.success));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(state.copyWith(
          processState: ProcessState.failure,
          notifyMessage: NotifyMessage.msg16,
          dialogName: DialogName.failure));
    }
  }

  void updateProduct() {
    Product product = Database()
        .productList
        .firstWhere((element) => element.productID == state.product.productID);
    emit(state.copyWith(product: product));
    _initializeTechnicalSpecs();
  }

  void toIdle() {
    emit(state.copyWith(processState: ProcessState.idle));
  }
}
