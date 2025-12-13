import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../../../objects/invoice_related/rating.dart';
import '../../../objects/invoice_related/reply.dart';
import '../../../objects/product_related/cpu_related/cpu.dart';
import '../../../objects/product_related/drive_related/drive.dart';
import '../../../objects/product_related/gpu_related/gpu.dart';
import '../../../objects/product_related/mainboard_related/mainboard.dart';
import '../../../objects/product_related/psu_related/psu.dart';
import '../../../objects/product_related/ram_related/ram.dart';
import '../../invoice/sales/rating_reply/rating_reply_cubit.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final Firebase _firebase = Firebase();
  DocumentSnapshot? _lastRatingsDoc;

  ProductDetailCubit(Product product)
      : super(ProductDetailState(product: product)) {
    _initializeTechnicalSpecs();
    loadRatingsPage();
    refreshAverage();
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

  Future<void> loadRatingsPage({int limit = 5}) async {
    try {
      final productId = state.product.productID ?? '';
      if (productId.isEmpty) return;
      try {
        final page = await _firebase.getRatingsPageByProduct(productId, limit: limit);
        _lastRatingsDoc = page.lastDocument;
        emit(state.copyWith(ratings: page.ratings, hasMoreRatings: page.hasMore));
      } catch (e) {
        // Server-side paging may fail due to missing index; fallback to client-side full fetch then local pagination
        if (kDebugMode) print('Falling back to client-side fetch for ratings: $e');
        final all = await _firebase.getRatingsByProductWithUsername(productId);
        final initial = all.take(limit).toList();
        final hasMore = all.length > initial.length;
        // note: cannot set a lastDocument for client-side fallback; we'll store current offset
        _lastRatingsDoc = null;
        emit(state.copyWith(ratings: initial, hasMoreRatings: hasMore));
      }
    } catch (e) {
      if (kDebugMode) print('Error loading ratings page: $e');
    }
  }

  Future<void> refreshAverage() async {
    try {
      final productId = state.product.productID ?? '';
      if (productId.isEmpty) return;
      final result = await _firebase.getAverageRatingForProduct(productId);
      final avg = (result['average'] as num?)?.toDouble() ?? 0.0;
      final count = (result['count'] as int?) ?? (result['count'] as num?)?.toInt() ?? 0;
      emit(state.copyWith(averageRating: avg, totalRatingsCount: count));
    } catch (e) {
      if (kDebugMode) print('Error refreshing average rating: $e');
    }
  }

  Future<void> loadMoreRatings({int limit = 5}) async {
    try {
      final productId = state.product.productID ?? '';
      if (productId.isEmpty) return;

      // Try server-side paged fetch if we have a last doc; otherwise use client-side continuation
      if (_lastRatingsDoc != null) {
        final page = await _firebase.getRatingsPageByProduct(productId, startAfter: _lastRatingsDoc, limit: limit);
        _lastRatingsDoc = page.lastDocument;
        final combined = List<Rating>.from(state.ratings)..addAll(page.ratings);
        emit(state.copyWith(ratings: combined, hasMoreRatings: page.hasMore));
        return;
      }

      // Fallback client-side: fetch all and append next slice
      final all = await _firebase.getRatingsByProductWithUsername(productId);
      final current = state.ratings.length;
      if (current >= all.length) {
        emit(state.copyWith(hasMoreRatings: false));
        return;
      }
      final next = all.skip(current).take(limit).toList();
      final combined = List<Rating>.from(state.ratings)..addAll(next);
      final hasMore = combined.length < all.length;
      emit(state.copyWith(ratings: combined, hasMoreRatings: hasMore));
    } catch (e) {
      if (kDebugMode) print('Error loading more ratings: $e');
    }
  }

  /// Post a reply to a rating from the product detail screen
  Future<void> replyToRating({required String ratingId, required String comment, String? productId}) async {
    try {
      final reply = Reply(id: DateTime.now().millisecondsSinceEpoch.toString(), comment: comment, timestamp: DateTime.now());
      await Database().replyToRating(ratingId: ratingId, reply: reply, productId: productId);
      // refresh ratings shown in product detail
      await loadRatingsPage();
      await refreshAverage();
    } catch (e) {
      if (kDebugMode) print('ProductDetailCubit.replyToRating error: $e');
      rethrow;
    }
  }
}
