import 'package:equatable/equatable.dart';

class StakeholderScreenState extends Equatable {
  final int selectedTabIndex;

  const StakeholderScreenState({
    this.selectedTabIndex = 0,
  });

  StakeholderScreenState copyWith({
    int? selectedTabIndex,
  }) {
    return StakeholderScreenState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
    );
  }
  
  @override
  List<Object?> get props => [selectedTabIndex];
}
