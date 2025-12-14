import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_filter_argument.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_method.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/screens/product/filter/option_filter/option_filter.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';
import 'sales_filter_cubit.dart';
import 'sales_filter_state.dart';

class SalesFilterView extends StatefulWidget {
  final SalesFilterArgument arguments;

  const SalesFilterView({
    super.key,
    required this.arguments,
  });

  static Widget newInstance({required SalesFilterArgument arguments}) =>
      BlocProvider(
        create: (context) =>
            SalesFilterCubit()..initialize(initialFilterValue: arguments),
        child: SalesFilterView(arguments: arguments),
      );

  @override
  State<SalesFilterView> createState() => _SalesFilterViewState();
}

class _SalesFilterViewState extends State<SalesFilterView> {
  SalesFilterCubit get cubit => context.read<SalesFilterCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SalesFilterCubit, SalesFilterState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GradientIconButton(
              icon: Icons.chevron_left,
              onPressed: () => Navigator.pop(context),
              fillColor: Colors.transparent,
            ),
            title: GradientText(text: S.of(context).filter),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: GradientIconButton(
                  icon: Icons.check,
                  onPressed: () => Navigator.pop(context, state.filterArgument),
                  fillColor: Colors.transparent,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Payment Status Filter
                OptionFilter(
                  name: S.of(context).paymentStatus,
                  enumValues: PaymentStatus.values,
                  selectedValues: List<PaymentStatus>.from(
                      state.filterArgument.paymentStatusList),
                  onToggleSelection: (status) {
                    cubit.togglePaymentStatus(status);
                  },
                  labelBuilder: (status) => status.getLocalizedName(context),
                ),
                const SizedBox(height: 24),

                // Sales Status Filter
                OptionFilter(
                  name: S.of(context).salesStatus,
                  enumValues: SalesStatus.values,
                  selectedValues: List<SalesStatus>.from(
                      state.filterArgument.salesStatusList),
                  onToggleSelection: (status) {
                    cubit.toggleSalesStatus(status);
                  },
                  labelBuilder: (status) => status.getLocalizedName(context),
                ),
                const SizedBox(height: 24),

                // Payment Method Filter
                OptionFilter(
                  name: S.of(context).paymentMethod,
                  enumValues: PaymentMethod.values,
                  selectedValues: List<PaymentMethod>.from(
                      state.filterArgument.paymentMethodList),
                  onToggleSelection: (method) {
                    cubit.togglePaymentMethod(method);
                  },
                  labelBuilder: (method) => method.getLocalizedDescription(
                      Localizations.localeOf(context).languageCode == 'vi'),
                ),
                const SizedBox(height: 24),

                // Clear Filter Button
                if (state.filterArgument.hasActiveFilters)
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        cubit.resetFilters();
                      },
                      icon: const Icon(Icons.clear),
                      label: Text(S.of(context).clearFilter),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
