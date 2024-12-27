import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/stakeholder/stakeholder_screen_view.dart';
import 'stakeholder_screen_state.dart';

class StakeholderScreenCubit extends Cubit<StakeholderScreenState> {
  StakeholderScreenCubit() : super(const StakeholderScreenState());

  void changeTab(int index) {
    emit(state.copyWith(selectedTabIndex: index));
  }
}