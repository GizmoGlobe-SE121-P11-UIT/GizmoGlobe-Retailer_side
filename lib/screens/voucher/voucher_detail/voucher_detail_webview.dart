import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/functions/converter.dart';
import 'package:gizmoglobe_client/objects/voucher_related/limited_interface.dart';
import 'package:gizmoglobe_client/screens/voucher/voucher_detail/voucher_detail_cubit.dart';
import 'package:gizmoglobe_client/screens/voucher/voucher_detail/voucher_detail_state.dart';
import 'package:intl/intl.dart';

import '../../../data/database/database.dart';
import '../../../enums/processing/process_state_enum.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import '../../../objects/voucher_related/end_time_interface.dart';
import '../../../objects/voucher_related/percentage_interface.dart';
import '../../../objects/voucher_related/voucher.dart';
import '../../../widgets/dialog/information_dialog.dart';
import '../../../widgets/general/gradient_text.dart';
import '../../../screens/voucher/edit_voucher/edit_voucher_view.dart';
import '../../../widgets/general/status_badge.dart';

class VoucherDetailWebView extends StatefulWidget {
  final Voucher voucher;

  const VoucherDetailWebView({
    super.key,
    required this.voucher,
  });

  static Widget newInstance(Voucher voucher) => BlocProvider(
        create: (context) => VoucherDetailCubit(voucher),
        child: VoucherDetailWebView(voucher: voucher),
      );

  @override
  State<VoucherDetailWebView> createState() => _VoucherDetailWebViewState();
}

class _VoucherDetailWebViewState extends State<VoucherDetailWebView> {
  VoucherDetailCubit get cubit => context.read<VoucherDetailCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VoucherDetailCubit, VoucherDetailState>(
      listener: (context, state) {
        if (state.processState == ProcessState.success) {
          showDialog(
            context: context,
            builder: (context) => InformationDialog(
              title: state.dialogName.getLocalizedName(context),
              content: state.notifyMessage.getLocalizedMessage(context),
              onPressed: () {
                cubit.toIdle();
              },
            ),
          );
        } else if (state.processState == ProcessState.failure) {
          showDialog(
            context: context,
            builder: (context) => InformationDialog(
              title: state.dialogName.getLocalizedName(context),
              content: state.notifyMessage.getLocalizedMessage(context),
              onPressed: () {
                cubit.toIdle();
              },
            ),
          );
        }
      },
      builder: (context, state) {
        if (state.processState == ProcessState.loading) {
          return Container(
            width: 600,
            height: 500,
            constraints: const BoxConstraints(
              maxWidth: 800,
              maxHeight: 600,
            ),
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
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Container(
          width: MediaQuery.of(context).size.width * 0.6,
          height: MediaQuery.of(context).size.height * 0.7,
          constraints: const BoxConstraints(
            maxWidth: 800,
            maxHeight: 600,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header with close button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.card_giftcard,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientText(text: S.of(context).voucher),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      icon: const Icon(Icons.close),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderSection(context, state),
                        const SizedBox(height: 16),
                        _buildInfoSection(context, state),
                        const SizedBox(height: 16),
                        _buildStatusSection(context, state),
                        const SizedBox(height: 80), // Space for bottom buttons
                      ],
                    ),
                  ),
                ),
              ),
              // Bottom action buttons
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
                child: FutureBuilder<bool>(
                  future: Database().isUserAdmin(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final processState =
                                    await EditVoucherScreen.showModal(
                                  context,
                                  state.voucher,
                                );
                                if (processState == ProcessState.success) {
                                  if (mounted) {
                                    Navigator.of(context).pop(true);
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text(
                                S.of(context).edit,
                                style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.tertiary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: BlocBuilder<VoucherDetailCubit,
                                VoucherDetailState>(
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
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  label: Text(
                                    state.voucher.isEnabled
                                        ? S.of(context).disabled
                                        : S.of(context).enabled,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: state.voucher.isEnabled
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
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
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context, VoucherDetailState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: 'voucher_icon_${state.voucher.voucherID}',
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.card_giftcard,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state.voucher.voucherName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            state.voucher.isPercentage
                ? '${Converter.formatDouble(state.voucher.discountValue)}%'
                : '\$${Converter.formatDouble(state.voucher.discountValue)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, VoucherDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).voucher,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(
                S.of(context).discountValue,
                state.voucher.isPercentage
                    ? '${Converter.formatDouble(state.voucher.discountValue)}%'
                    : '\$${Converter.formatDouble(state.voucher.discountValue)}',
              ),
              if (state.voucher.isPercentage)
                _buildInfoRow(
                  S.of(context).maximumDiscountValue,
                  '\$${Converter.formatDouble((state.voucher as PercentageInterface).maximumDiscountValue)}',
                ),
              _buildInfoRow(
                S.of(context).minimumPurchase,
                '\$${Converter.formatDouble(state.voucher.minimumPurchase)}',
              ),
              if (state.voucher.isLimited)
                _buildInfoRow(
                  S.of(context).usageLeft,
                  '${(state.voucher as LimitedInterface).usageLeft} / ${(state.voucher as LimitedInterface).maximumUsage}',
                ),
              _buildInfoRow(
                S.of(context).maxUsagePerPerson,
                '${state.voucher.maxUsagePerPerson}',
              ),
              _buildInfoRow(
                S.of(context).startTime,
                DateFormat('hh:mm:ss dd/MM/yyyy')
                    .format(state.voucher.startTime),
              ),
              if (state.voucher.hasEndTime)
                _buildInfoRow(
                  S.of(context).endTime,
                  DateFormat('hh:mm:ss dd/MM/yyyy').format(
                    (state.voucher as EndTimeInterface).endTime,
                  ),
                )
              else
                _buildInfoRow(
                  S.of(context).endTime,
                  S.of(context).noEndTime,
                ),
              if (state.voucher.enDescription != null)
                _buildInfoRow(
                  S.of(context).enDescription,
                  state.voucher.enDescription!,
                ),
              if (state.voucher.viDescription != null)
                _buildInfoRow(
                  S.of(context).viDescription,
                  state.voucher.viDescription!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, VoucherDetailState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    S.of(context).status,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    '${S.of(context).visibility}: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  StatusBadge(
                    status: state.voucher.isVisible
                        ? S.of(context).visible
                        : S.of(context).hidden,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '${S.of(context).status}: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  StatusBadge(
                    status: state.voucher.isEnabled
                        ? S.of(context).active
                        : S.of(context).inactive,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
