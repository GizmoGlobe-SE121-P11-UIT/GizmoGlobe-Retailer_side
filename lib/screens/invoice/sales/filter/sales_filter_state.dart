import 'package:equatable/equatable.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_filter_argument.dart';

class SalesFilterState extends Equatable {
  final SalesFilterArgument filterArgument;

  const SalesFilterState({
    this.filterArgument = const SalesFilterArgument(),
  });

  SalesFilterState copyWith({
    SalesFilterArgument? filterArgument,
  }) {
    return SalesFilterState(
      filterArgument: filterArgument ?? this.filterArgument,
    );
  }

  @override
  List<Object?> get props => [filterArgument];
}
