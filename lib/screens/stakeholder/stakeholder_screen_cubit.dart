import 'package:flutter_bloc/flutter_bloc.dart';
import 'stakeholder_screen_state.dart';

class StakeholderScreenCubit extends Cubit<StakeholderScreenState> {
  StakeholderScreenCubit() : super(const StakeholderScreenState());

  void changeTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }
}