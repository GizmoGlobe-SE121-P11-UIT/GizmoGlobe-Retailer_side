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
import '../../../../objects/product_related/cpu.dart';
import '../../../../objects/product_related/drive.dart';
import '../../../../objects/product_related/filter_argument.dart';
import '../../../../objects/product_related/gpu.dart';
import '../../../../objects/product_related/mainboard.dart';
import '../../../../objects/product_related/psu.dart';
import '../../../../objects/product_related/ram.dart';
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
    applyFilters();
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
    emit(state.copyWith(filterArgument: state.filterArgument.copyWith(categoryList: [CategoryEnum.nonEmptyValues[index]])));
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


      if (!matchesMinMax(product.stock.toDouble(), state.filterArgument.minStock, state.filterArgument.maxStock)) {
        return false;
      }

      final bool matchesCategory;
      final index = getIndex();
      switch (index) {
        case 0:
          matchesCategory = state.filterArgument.categoryList.contains(product.category);
          break;
        case 1:
          matchesCategory = product.category == CategoryEnum.ram;
          break;
        case 2:
          matchesCategory = product.category == CategoryEnum.cpu;
          break;
        case 3:
          matchesCategory = product.category == CategoryEnum.psu;
          break;
        case 4:
          matchesCategory = product.category == CategoryEnum.gpu;
          break;
        case 5:
          matchesCategory = product.category == CategoryEnum.drive;
          break;
        case 6:
          matchesCategory = product.category == CategoryEnum.mainboard;
          break;
        default:
          matchesCategory = false;
      }

      if (!matchesCategory) {
        return false;
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
  List<Manufacturer> getManufacturerList();

  bool matchesMinMax(double value, String? minStr, String? maxStr) {
    final double min = double.tryParse(minStr ?? '') ?? 0;
    final double max = double.tryParse(maxStr ?? '') ?? double.infinity;
    return value >= min && value <= max;
  }

  bool matchFilter(Product product, FilterArgument filterArgument) {
    switch (product.category) {
      case CategoryEnum.ram:
        product as RAM;
        return filterArgument.ramBusList.contains(product.bus) &&
            filterArgument.ramCapacityList.contains(product.capacity) &&
            filterArgument.ramTypeList.contains(product.ramType);

      case CategoryEnum.cpu:
        product as CPU;
        final matchesCpuCore = matchesMinMax(product.core.toDouble(), state.filterArgument.minCpuCore, state.filterArgument.maxCpuCore);
        final matchesCpuThread = matchesMinMax(product.thread.toDouble(), state.filterArgument.minCpuThread, state.filterArgument.maxCpuThread);
        final matchesCpuClockSpeed = matchesMinMax(product.clockSpeed.toDouble(), state.filterArgument.minCpuClockSpeed, state.filterArgument.maxCpuClockSpeed);
        return filterArgument.cpuFamilyList.contains(product.family) &&
            matchesCpuCore &&
            matchesCpuThread &&
            matchesCpuClockSpeed;

      case CategoryEnum.gpu:
        product as GPU;
        final matchesGpuClockSpeed = matchesMinMax(product.clockSpeed, state.filterArgument.minGpuClockSpeed, state.filterArgument.maxGpuClockSpeed);
        return filterArgument.gpuBusList.contains(product.bus) &&
            filterArgument.gpuCapacityList.contains(product.capacity) &&
            filterArgument.gpuSeriesList.contains(product.series) &&
            matchesGpuClockSpeed;

      case CategoryEnum.mainboard:
        product as Mainboard;
        return filterArgument.mainboardFormFactorList.contains(product.formFactor) &&
            filterArgument.mainboardSeriesList.contains(product.series) &&
            filterArgument.mainboardCompatibilityList.contains(product.compatibility);

      case CategoryEnum.drive:
        product as Drive;
        return filterArgument.driveTypeList.contains(product.type) &&
            filterArgument.driveCapacityList.contains(product.capacity);

      case CategoryEnum.psu:
        product as PSU;
        final matchesPsuWattage = matchesMinMax(product.wattage.toDouble(), state.filterArgument.minPsuWattage, state.filterArgument.maxPsuWattage);
        return filterArgument.psuModularList.contains(product.modular) &&
            filterArgument.psuEfficiencyList.contains(product.efficiency) &&
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