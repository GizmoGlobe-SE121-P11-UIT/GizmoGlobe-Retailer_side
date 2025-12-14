import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/invoice_related/sales_filter_argument.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_method.dart';
import 'package:gizmoglobe_client/enums/invoice_related/payment_status.dart';
import 'package:gizmoglobe_client/enums/invoice_related/sales_status.dart';
import 'package:gizmoglobe_client/screens/product/filter/option_filter/option_filter.dart';
import 'sales_filter_cubit.dart';
import 'sales_filter_state.dart';

class SalesFilterWebView extends StatefulWidget {
  final SalesFilterArgument arguments;

  const SalesFilterWebView({
    super.key,
    required this.arguments,
  });

  static Widget newInstance({required SalesFilterArgument arguments}) =>
      BlocProvider(
        create: (context) =>
            SalesFilterCubit()..initialize(initialFilterValue: arguments),
        child: SalesFilterWebView(arguments: arguments),
      );

  @override
  State<SalesFilterWebView> createState() => _SalesFilterWebViewState();
}

class _SalesFilterWebViewState extends State<SalesFilterWebView> {
  SalesFilterCubit get cubit => context.read<SalesFilterCubit>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 600,
          height: 500,
          constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: BlocBuilder<SalesFilterCubit, SalesFilterState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.filter_list,
                            color: colorScheme.primary, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            S.of(context).filter,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          tooltip: S.of(context).confirm,
                          color: colorScheme.primary,
                          onPressed: () =>
                              Navigator.pop(context, state.filterArgument),
                          icon: const Icon(Icons.check),
                        ),
                        IconButton(
                          tooltip: S.of(context).cancel,
                          color: colorScheme.primary,
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),

                  // Body
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Subtract padding (24 on each side) to get actual content width
                        final maxW = constraints.maxWidth - 48;
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
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
                                availableWidth: maxW,
                                labelBuilder: (status) =>
                                    status.getLocalizedName(context),
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
                                availableWidth: maxW,
                                labelBuilder: (status) =>
                                    status.getLocalizedName(context),
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
                                availableWidth: maxW,
                                labelBuilder: (method) =>
                                    method.getLocalizedDescription(
                                        Localizations.localeOf(context)
                                                .languageCode ==
                                            'vi'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Footer with reset button
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        if (state.filterArgument.hasActiveFilters)
                          Expanded(
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
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
