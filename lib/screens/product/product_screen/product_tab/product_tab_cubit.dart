import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/enums/product_related/category_enum.dart';
import 'package:gizmoglobe_client/enums/product_related/product_status_enum.dart';
import 'package:gizmoglobe_client/objects/manufacturer.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/data/database/database.dart';

import '../../../../data/firebase/firebase.dart';
import '../../../../enums/processing/process_state_enum.dart';
import '../../../../enums/processing/sort_enum.dart';
import '../../../../objects/product_related/cpu_related/cpu.dart';
import '../../../../objects/product_related/drive_related/drive.dart';
import '../../../../objects/product_related/filter_argument.dart';
import '../../../../objects/product_related/gpu_related/gpu.dart';
import '../../../../objects/product_related/mainboard_related/mainboard.dart';
import '../../../../objects/product_related/psu_related/psu.dart';
import '../../../../objects/product_related/ram_related/ram.dart';
import 'product_tab_state.dart';

abstract class TabCubit extends Cubit<TabState> {
  TabCubit() : super(const TabState());

  void initialize(FilterArgument filter, {String? searchText, required List<Product> initialProducts}) {
    emit(state.copyWith(
      productList: initialProducts.isEmpty ? Database().productList : initialProducts,
      filteredProductList: initialProducts.isEmpty ? Database().productList : initialProducts,
      searchText: searchText ?? '',
    ));

    emit(state.copyWith(
      manufacturerList: getManufacturerList(),
      filterArgument: filter.copyWith(manufacturerList: getManufacturerList()
      ),
    ));
    // Set the active category based on this tab's index so filters apply correctly on init
    final initialCategory = _categoryForIndex(getIndex());
    emit(state.copyWith(activeCategory: initialCategory));
    applyFilters();
  }

  // Map tab index explicitly to a category. Keeps mapping clear and resilient to enum order changes.
  CategoryEnum _categoryForIndex(int index) {
    switch (index) {
      case 1:
        return CategoryEnum.ram;
      case 2:
        return CategoryEnum.cpu;
      case 3:
        return CategoryEnum.psu;
      case 4:
        return CategoryEnum.gpu;
      case 5:
        return CategoryEnum.drive;
      case 6:
        return CategoryEnum.mainboard;
      default:
        return CategoryEnum.empty;
    }
  }

  Future<void> _fetchProducts() async {
    try {
      List<Product> products = await Firebase().getProducts();
      Database().updateProductList(products);

      emit(state.copyWith(productList: Database().productList, filteredProductList: Database().productList));
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  void updateFilter({FilterArgument? filter}) {
    emit(state.copyWith(filterArgument: filter));
  }

  void toLoading() {
    emit(state.copyWith(processState: ProcessState.loading));
  }

  void updateSearchText(String? searchText) {
    emit(state.copyWith(searchText: searchText));
    applyFilters();
  }

  void updateTabIndex(int index) {
    // Set the active category for this tab and reapply filters
    final newCategory = _categoryForIndex(index);
    emit(state.copyWith(activeCategory: newCategory));
    applyFilters();
  }

  void updateSortOption(SortEnum selectedOption) {
    emit(state.copyWith(selectedSortOption: selectedOption));
    applyFilters();
  }

  void updateProduct(List<Product> products) {
    emit(state.copyWith(productList: products));
    applyFilters();
  }

  void setSelectedProduct(Product? product) {
    emit(state.copyWith(selectedProduct: product));
  }

  void applyFilters() {
    if (kDebugMode) {
      print('Apply filter');
    } //Áp dụng bộ lọc
    final filteredProducts = state.productList.where((product) {
      if (!product.productName.toLowerCase().contains(state.searchText.toLowerCase())) {
        return false;
      }

      if (!state.filterArgument.manufacturerList.any((manufacturer) => manufacturer.manufacturerID == product.manufacturer.manufacturerID)) {
        return false;
      }


      if (!matchesMinMax(
          (product.sellingPrice * (100 - product.discount) * 1000).toDouble(),
          state.filterArgument.minPrice,
          state.filterArgument.maxPrice
      )) {
        return false;
      }

      // Determine matching by using the activeCategory stored in state.
      final index = getIndex();
      final CategoryEnum tabCategory = _categoryForIndex(index);
      // If this is the 'All' tab (tabCategory == empty), respect activeCategory if set, otherwise accept all.
      if (tabCategory == CategoryEnum.empty) {
        if (state.activeCategory != CategoryEnum.empty && product.category != state.activeCategory) {
          return false;
        }
      } else {
        if (product.category != tabCategory) {
          return false;
        }
      }

      return matchFilter(product, state.filterArgument);
    }).toList();

    switch (state.selectedSortOption) {
      case SortEnum.releaseOldest:
        filteredProducts.sort((a, b) => a.release.compareTo(b.release));
        break;
      case SortEnum.stockHighest:
        filteredProducts.sort((a, b) => b.stock.compareTo(a.stock));
        break;
      case SortEnum.stockLowest:
        filteredProducts.sort((a, b) => a.stock.compareTo(b.stock));
        break;
      case SortEnum.salesHighest:
        filteredProducts.sort((a, b) => b.sales.compareTo(a.sales));
        break;
      case SortEnum.salesLowest:
        filteredProducts.sort((a, b) => a.sales.compareTo(b.sales));
        break;
      default:
        filteredProducts.sort((a, b) => b.release.compareTo(a.release));
    }

    emit(state.copyWith(filteredProductList: filteredProducts));
  }

  Future<void> changeStatus(Product product) async {
    try {
      ProductStatusEnum status;
      if (product.status == ProductStatusEnum.discontinued) {
        if (product.stock == 0) {
          status = ProductStatusEnum.outOfStock;
        } else {
          status = ProductStatusEnum.active;
        }
      } else {
        status = ProductStatusEnum.discontinued;
      }

      await Firebase().changeProductStatus(product.productID!, status);
      await reloadProducts();

      emit(state.copyWith(processState: ProcessState.success));
      applyFilters();
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(state.copyWith(processState: ProcessState.failure));
    }
  }

  Future<void> reloadProducts() async {
    toLoading();
    await _fetchProducts();
    emit(state.copyWith(manufacturerList: getManufacturerList()));
    applyFilters();
    emit(state.copyWith(processState: ProcessState.idle));
  }

  int getIndex();

  List<Manufacturer> getManufacturerList() {
    return Database().manufacturerList;
  }

  bool matchesMinMax(double value, String? minStr, String? maxStr) {
    final double min = double.tryParse(minStr ?? '') ?? 0;
    final double max = double.tryParse(maxStr ?? '') ?? double.infinity;
    return value >= min && value <= max;
  }

  bool matchedCpuClockSpeed(double baseClock, double turboClock, String? minStr, String? maxStr) {;
    final double min = double.tryParse(minStr ?? '') ?? 0;
    final double max = double.tryParse(maxStr ?? '') ?? double.infinity;
    return turboClock >= min && baseClock <= max;
  }

  bool matchFilter(Product product, FilterArgument filterArgument) {
    switch (product.category) {
      case CategoryEnum.ram:
        product as RAM;
        final matchesRamCapacity = matchesMinMax(
          (product.capacityPerStickGb * product.kitStickCount).toDouble(),
          state.filterArgument.minMemoryGb,
          state.filterArgument.maxMemoryGb
        );
        return filterArgument.ramType.contains(product.type) &&
            matchesRamCapacity;

      case CategoryEnum.cpu:
        product as CPU;
        final matchesCpuClockSpeed = matchedCpuClockSpeed(
            product.baseClock,
            product.turboClock,
            state.filterArgument.minClockSpeed,
            state.filterArgument.maxClockSpeed
        );
        final matchesCpuTdp = matchesMinMax(
            product.tdp.toDouble(),
            state.filterArgument.minTdp,
            state.filterArgument.maxTdp
        );
        return filterArgument.cpuSeries.contains(product.series) &&
            filterArgument.sockets.contains(product.socket) &&
            matchesCpuClockSpeed &&
            matchesCpuTdp;

      case CategoryEnum.gpu:
        product as GPU;
        final matchesGpuClockSpeed = matchesMinMax(
            product.boostClock,
            state.filterArgument.minClockSpeed,
            state.filterArgument.maxClockSpeed
        );
        final matchesGpuCapacity = matchesMinMax(
            product.memory.toDouble(),
            state.filterArgument.minMemoryGb,
            state.filterArgument.maxMemoryGb
        );
        final matchesGpuTdp = matchesMinMax(
            product.tdp.toDouble(),
            state.filterArgument.minTdp,
            state.filterArgument.maxTdp
        );
        return filterArgument.gpuVersion.contains(product.version) &&
            filterArgument.gpuSeries.contains(product.series) &&
            matchesGpuClockSpeed &&
            matchesGpuCapacity &&
            matchesGpuTdp;

      case CategoryEnum.mainboard:
        product as Mainboard;
        final matchesMainboardCapacity = matchesMinMax(
          (product.ramSpec.maxSingleDimmGb * product.ramSpec.slots).toDouble(),
          state.filterArgument.minMemoryGb,
          state.filterArgument.maxMemoryGb
        );
        final matchesMainboardM2Slot = matchesMinMax(
          product.storageSlot.m2Slots.toDouble(),
          state.filterArgument.minM2Slots,
          state.filterArgument.maxM2Slots
        );
        final matchesMainboardSataSlot = matchesMinMax(
            product.storageSlot.sataPorts.toDouble(),
            state.filterArgument.minSataPorts,
            state.filterArgument.maxSataPorts
        );
        return filterArgument.mainboardFormFactor.contains(product.formFactor) &&
            filterArgument.sockets.contains(product.socket) &&
            filterArgument.ramType.contains(product.ramSpec.type) &&
            matchesMainboardCapacity &&
            matchesMainboardM2Slot &&
            matchesMainboardSataSlot;

      case CategoryEnum.drive:
        product as Drive;
        final matchesDriveCapacity = matchesMinMax(
          product.memoryGb.toDouble(),
          state.filterArgument.minMemoryGb,
          state.filterArgument.maxMemoryGb
        );
        return filterArgument.driveType.contains(product.driveType) &&
            filterArgument.driveFormFactor.contains(product.formFactor) &&
            filterArgument.interfaceType.contains(product.interfaceType) &&
            filterArgument.gen.contains(product.gen) &&
            matchesDriveCapacity;

      case CategoryEnum.psu:
        product as PSU;
        final matchesPsuWattage = matchesMinMax(
            product.maxWattage.toDouble(),
            state.filterArgument.minTdp,
            state.filterArgument.maxTdp
        );
        return filterArgument.psuModularity.contains(product.modularity) &&
            filterArgument.psuEfficiency.contains(product.efficiency) &&
            matchesPsuWattage;
      default:
        return false;
    }
  }
}

class AllTabCubit extends TabCubit {
  @override
  int getIndex() {
    return 0;
  }

  @override
  List<Manufacturer> getManufacturerList() {
    return Database().manufacturerList;
  }
}

class RamTabCubit extends TabCubit {
  @override
  int getIndex() {
    return 1;
  }

  @override
  List<Manufacturer> getManufacturerList() {
    return state.productList
        .where((product) => product.category == CategoryEnum.ram)
        .map((product) => product.manufacturer)
        .toSet()
        .toList();
  }
}

class CpuTabCubit extends TabCubit {
  @override
  int getIndex() {
    return 2;
  }

  @override
  List<Manufacturer> getManufacturerList() {
    return state.productList
        .where((product) => product.category == CategoryEnum.cpu)
        .map((product) => product.manufacturer)
        .toSet()
        .toList();
  }
}

class PsuTabCubit extends TabCubit {
  @override
  int getIndex() {
    return 3;
  }

  @override
  List<Manufacturer> getManufacturerList() {
    return state.productList
        .where((product) => product.category == CategoryEnum.psu)
        .map((product) => product.manufacturer)
        .toSet()
        .toList();
  }
}

class GpuTabCubit extends TabCubit {
  @override
  int getIndex() {
    return 4;
  }

  @override
  List<Manufacturer> getManufacturerList() {
    return state.productList
        .where((product) => product.category == CategoryEnum.gpu)
        .map((product) => product.manufacturer)
        .toSet()
        .toList();
  }
}

class DriveTabCubit extends TabCubit {
  @override
  int getIndex() {
    return 5;
  }

  @override
  List<Manufacturer> getManufacturerList() {
    return state.productList
        .where((product) => product.category == CategoryEnum.drive)
        .map((product) => product.manufacturer)
        .toSet()
        .toList();
  }
}

class MainboardTabCubit extends TabCubit {
  @override
  int getIndex() {
    return 6;
  }

  @override
  List<Manufacturer> getManufacturerList() {
    return state.productList
        .where((product) => product.category == CategoryEnum.mainboard)
        .map((product) => product.manufacturer)
        .toSet()
        .toList();
  }
}