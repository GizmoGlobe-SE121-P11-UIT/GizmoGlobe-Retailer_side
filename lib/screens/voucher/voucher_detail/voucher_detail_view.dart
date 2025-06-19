import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/functions/converter.dart';
import 'package:gizmoglobe_client/objects/voucher_related/limited_interface.dart';
import 'package:gizmoglobe_client/screens/voucher/voucher_detail/voucher_detail_cubit.dart';
import 'package:gizmoglobe_client/screens/voucher/voucher_detail/voucher_detail_state.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:intl/intl.dart';

import '../../../data/database/database.dart';
import '../../../enums/processing/process_state_enum.dart';
import '../../../generated/l10n.dart';
import '../../../objects/voucher_related/end_time_interface.dart';
import '../../../objects/voucher_related/percentage_interface.dart';
import '../../../objects/voucher_related/voucher.dart';
import '../../../widgets/dialog/information_dialog.dart';
import '../../../widgets/general/gradient_text.dart';
import '../../../screens/voucher/edit_voucher/edit_voucher_view.dart';
import '../../../widgets/general/status_badge.dart';

class VoucherDetailScreen extends StatefulWidget {
  final Voucher voucher;
  const VoucherDetailScreen({super.key, required this.voucher});

  static Widget newInstance(Voucher voucher) => BlocProvider(
        create: (context) => VoucherDetailCubit(voucher),
        child: VoucherDetailScreen(voucher: voucher),
      );

  @override
  State<VoucherDetailScreen> createState() => _VoucherDetailScreen();
}

class _VoucherDetailScreen extends State<VoucherDetailScreen> {
  VoucherDetailCubit get cubit => context.read<VoucherDetailCubit>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: BlocBuilder<VoucherDetailCubit, VoucherDetailState>(
          builder: (context, state) => GradientIconButton(
            icon: Icons.chevron_left,
            onPressed: () => {
              if (widget.voucher != state.voucher)
                {Navigator.pop(context, ProcessState.success)}
              else
                {Navigator.pop(context, state.processState)}
            },
            fillColor: Colors.transparent,
          ),
        ),
        title: BlocBuilder<VoucherDetailCubit, VoucherDetailState>(
          builder: (context, state) => GradientText(
            text: state.voucher.voucherName,
          ),
        ),
      ),
      body: BlocBuilder<VoucherDetailCubit, VoucherDetailState>(
        builder: (context, state) {
          return Stack(
            children: [
              Positioned.fill(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow(
                              title: S.of(context).voucher,
                              value: state.voucher.voucherName,
                              theme: theme,
                            ),
                            _buildInfoRow(
                              title: S.of(context).discountValue,
                              value: state.voucher.isPercentage
                                  ? '${Converter.formatDouble(state.voucher.discountValue)}%'
                                  : '\$${Converter.formatDouble(state.voucher.discountValue)}',
                              theme: theme,
                            ),
                            if (state.voucher.isPercentage)
                              _buildInfoRow(
                                title: S.of(context).maximumDiscountValue,
                                value:
                                    '\$${Converter.formatDouble((state.voucher as PercentageInterface).maximumDiscountValue)}',
                                theme: theme,
                              ),
                            _buildInfoRow(
                              title: S.of(context).minimumPurchase,
                              value:
                                  '\$${Converter.formatDouble(state.voucher.minimumPurchase)}',
                              theme: theme,
                            ),
                            if (state.voucher.isLimited)
                              _buildInfoRow(
                                title: S.of(context).usageLeft,
                                value:
                                    '${(state.voucher as LimitedInterface).usageLeft} / ${(state.voucher as LimitedInterface).maximumUsage}',
                                theme: theme,
                              ),
                            _buildInfoRow(
                              title: S.of(context).maxUsagePerPerson,
                              value: '${state.voucher.maxUsagePerPerson}',
                              theme: theme,
                            ),
                            _buildInfoRow(
                              title: S.of(context).startTime,
                              value: DateFormat('hh:mm:ss dd/MM/yyyy')
                                  .format(state.voucher.startTime),
                              theme: theme,
                            ),
                            if (state.voucher.hasEndTime)
                              _buildInfoRow(
                                title: S.of(context).endTime,
                                value: DateFormat('hh:mm:ss dd/MM/yyyy').format(
                                    (state.voucher as EndTimeInterface)
                                        .endTime),
                                theme: theme,
                              )
                            else
                              _buildInfoRow(
                                title: S.of(context).endTime,
                                value: S.of(context).noEndTime,
                                theme: theme,
                              ),
                            Row(
                              children: [
                                Text(
                                  '${S.of(context).visibility}: ',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                StatusBadge(
                                  status: state.voucher.isVisible
                                      ? S.of(context).visible
                                      : S.of(context).hidden,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  '${S.of(context).status}: ',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                StatusBadge(
                                  status: state.voucher.isEnabled
                                      ? S.of(context).enabled
                                      : S.of(context).disabled,
                                ),
                              ],
                            ),
                            if (state.voucher.enDescription != null)
                              _buildInfoRow(
                                title: S.of(context).enDescription,
                                value: state.voucher.enDescription!,
                                theme: theme,
                              ),

                            if (state.voucher.viDescription != null)
                              _buildInfoRow(
                                title: S.of(context).viDescription,
                                value: state.voucher.viDescription!,
                                theme: theme,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1), 
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: BlocConsumer<VoucherDetailCubit, VoucherDetailState>(
                    listener: (context, state) {
                      if (state.processState == ProcessState.success) {
                        showDialog(
                            context: context,
                            builder: (context) => InformationDialog(
                                  title: state.dialogName.getLocalizedName(context),
                                  content: state.notifyMessage.getLocalizedMessage(context),
                                  onPressed: () {
                                  },
                                ));
                      } else if (state.processState == ProcessState.failure) {
                        showDialog(
                            context: context,
                            builder: (context) => InformationDialog(
                                  title: state.dialogName.getLocalizedName(context),
                                  content: state.notifyMessage.getLocalizedMessage(context),
                                  onPressed: () {
                                    cubit.toIdle();
                                  },
                                ));
                      }
                    },
                    builder: (context, state) => FutureBuilder<bool>(
                      future: Database().isUserAdmin(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data == true) {
                          return Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    ProcessState? processState =
                                        await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditVoucherScreen.newInstance(state.voucher),
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.edit,
                                      color: theme.colorScheme.onPrimary),
                                  label: Text(
                                    S.of(context).edit,
                                    style: TextStyle(
                                        color: theme.colorScheme.onPrimary),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: BlocBuilder<VoucherDetailCubit, VoucherDetailState>(
                                  builder: (context, state) {
                                    return ElevatedButton.icon(
                                      onPressed: () {
                                        cubit.toLoading();
                                        cubit.changeVoucherStatus();
                                      },
                                      icon: Icon(
                                        state.voucher.isEnabled
                                            ? Icons.not_interested
                                            : Icons.check,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                      label: Text(
                                        state.voucher.isEnabled
                                            ? S.of(context).disabled
                                            : S.of(context).enabled,
                                        style:
                                        TextStyle(color: theme.colorScheme.onPrimary),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: state.voucher.isEnabled
                                            ? theme.colorScheme.error
                                            : theme.colorScheme.secondary,
                                        padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String value,
    required ThemeData theme,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
