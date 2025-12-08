import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_screen_state.dart';
import '../../../enums/processing/sort_enum.dart';

class ProductScreenCubit extends Cubit<ProductScreenState> {
  ProductScreenCubit() : super(const ProductScreenState());

  void initialize(List<Product> initialProducts) {
    // Preserve loading state if currently loading
    emit(state.copyWith(initialProducts: initialProducts));
  }

  Future<void> updateSelectedTabIndex(int index) async {
    // Update tab index immediately and start loading
    emit(state.copyWith(
      selectedTabIndex: index,
      isChangingTab: true,
    ));

    // Wait at least 1 second before hiding loading indicator
    await Future.delayed(const Duration(seconds: 1));

    // Hide loading indicator after the delay
    emit(state.copyWith(isChangingTab: false));
  }

  void updateSearchText(String? searchText) {
    // Preserve loading state if currently loading
    emit(state.copyWith(
      searchText: searchText,
    ));
  }

  void updateSortOption(SortEnum selectedOption) {
    // Preserve loading state if currently loading
    emit(state.copyWith(selectedSortOption: selectedOption));
  }
}
