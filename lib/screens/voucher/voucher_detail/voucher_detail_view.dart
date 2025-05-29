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
import '../../../objects/voucher_related/end_time_interface.dart';
import '../../../objects/voucher_related/percentage_interface.dart';
import '../../../objects/voucher_related/voucher.dart';
import '../../../widgets/dialog/information_dialog.dart';
import '../../../widgets/general/gradient_text.dart';


class VoucherDetailScreen extends StatefulWidget {
  final Voucher voucher;
  const VoucherDetailScreen({super.key, required this.voucher});

  static Widget newInstance(Voucher voucher) =>
      BlocProvider(
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
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: BlocBuilder<VoucherDetailCubit, VoucherDetailState>(
          builder: (context, state) =>
              GradientIconButton(
                icon: Icons.chevron_left,
                onPressed: () =>
                {
                  if (widget.voucher != state.voucher) {
                    Navigator.pop(context, ProcessState.success)
                  } else
                    {
                      Navigator.pop(context, state.processState)
                    }
                },
                fillColor: Colors.transparent,
              ),
        ),
        title: BlocBuilder<VoucherDetailCubit, VoucherDetailState>(
          builder: (context, state) =>
              GradientText(
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
                              title: 'Voucher',
                              value: state.voucher.voucherName,
                            ),

                            _buildInfoRow(
                              title: 'Discount',
                              value: state.voucher.isPercentage
                                  ? '${Converter.formatDouble(state.voucher
                                  .discountValue)}% maximum \$${Converter
                                  .formatDouble(
                                  (state.voucher as PercentageInterface)
                                      .maximumDiscountValue)}'
                                  : '\$${Converter.formatDouble(
                                  state.voucher.discountValue)}',
                            ),

                            _buildInfoRow(
                              title: 'Minimum purchase',
                              value: '\$${Converter.formatDouble(
                                  state.voucher.minimumPurchase)}',
                            ),

                            if (state.voucher.isLimited)
                              _buildInfoRow(
                                title: 'Usage',
                                value: '${(state.voucher as LimitedInterface).usageLeft} / ${(state.voucher as LimitedInterface).maximumUsage}',
                              ),

                            _buildInfoRow(
                              title: 'Maximum usage per person',
                              value: '${state.voucher.maxUsagePerPerson}',
                            ),

                            _buildInfoRow(
                              title: 'Start time',
                              value: DateFormat('hh:mm:ss dd/MM/yyyy').format(
                                  state.voucher.startTime),
                            ),

                            if (state.voucher.hasEndTime)
                              _buildInfoRow(
                                title: 'End time',
                                value: DateFormat('hh:mm:ss dd/MM/yyyy').format(
                                    (state.voucher as EndTimeInterface).endTime),
                              )
                            else
                              _buildInfoRow(
                                title: 'End time',
                                value: 'No end time',
                              ),

                            _buildInfoRow(
                                title: 'Visibility',
                                value: state.voucher.isVisible ? 'Visible' : 'Hidden'
                            ),

                            _buildInfoRow(
                                title: 'Status',
                                value: state.voucher.isEnabled ? 'Enabled' : 'Disabled'
                            ),

                            if (state.voucher.description != null)
                              _buildInfoRow(
                                title: 'Description',
                                value: state.voucher.description!,
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
                    color: Theme.of(context).scaffoldBackgroundColor,
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
                            builder:  (context) =>
                                InformationDialog(
                                  title: state.dialogName.toString(),
                                  content: state.notifyMessage.toString(),
                                  onPressed: () {},
                                )
                        );
                      } else if (state.processState == ProcessState.failure) {
                        showDialog(
                            context: context,
                            builder:  (context) =>
                                InformationDialog(
                                  title: state.dialogName.toString(),
                                  content: state.notifyMessage.toString(),
                                  onPressed: () {
                                    cubit.toIdle();
                                  },
                                )
                        );
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
                                    // ProcessState processState = await Navigator.push(
                                    //   context,
                                    //   MaterialPageRoute(
                                    //     builder: (context) => EditProductScreen.newInstance(state.product),
                                    //   ),
                                    // );
                                    //
                                    // if (processState == ProcessState.success) {
                                    //   cubit.updateProduct();
                                    // }
                                  },
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  label: const Text('Edit', style: TextStyle(color: Colors.white)), //Chỉnh sửa
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    cubit.toLoading();
                                    cubit.changeVoucherStatus();
                                  },
                                  icon: Icon(
                                    state.voucher.isEnabled
                                        ? Icons.not_interested
                                        : Icons.check,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    state.voucher.isEnabled
                                        ? 'Disable'
                                        : 'Enable',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: state.voucher.isEnabled
                                        ? Colors.red
                                        : Colors.green,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
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
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}