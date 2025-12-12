import 'package:equatable/equatable.dart';

class StakeholderScreenState extends Equatable {
  final int selectedTabIndex;
  final bool isChangingTab;

  const StakeholderScreenState({
    required this.selectedTabIndex,
    this.isChangingTab = false,
  });

  StakeholderScreenState copyWith({
    int? selectedTabIndex,
    bool? isChangingTab,
  }) {
    return StakeholderScreenState(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      isChangingTab: isChangingTab ?? this.isChangingTab,
    );
  }
  
  @override
  List<Object?> get props => [selectedTabIndex, isChangingTab];
}
