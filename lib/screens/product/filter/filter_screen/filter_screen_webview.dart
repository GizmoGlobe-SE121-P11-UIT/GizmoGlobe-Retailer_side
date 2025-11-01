import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';

import '../../../../objects/product_related/filter_argument.dart';
import '../../../../objects/manufacturer.dart';
// for selected tab indices mapping context
import '../manufacturer_filter/manufacturer_filter.dart';
import '../option_filter/option_filter.dart';
import '../range_filter/range_filter.dart';
import 'filter_screen_cubit.dart';
import 'filter_screen_state.dart';

import '../../../../enums/product_related/ram_enums/ram_type.dart';
import '../../../../enums/product_related/cpu_enums/cpu_series.dart';
import '../../../../enums/product_related/cpu_enums/socket.dart';
import '../../../../enums/product_related/psu_enums/psu_modular.dart';
import '../../../../enums/product_related/psu_enums/psu_efficiency.dart';
import '../../../../enums/product_related/gpu_enums/gpu_series.dart';
import '../../../../enums/product_related/gpu_enums/gpu_version.dart';
import '../../../../enums/product_related/drive_enums/drive_form_factor.dart';
import '../../../../enums/product_related/drive_enums/drive_gen.dart';
import '../../../../enums/product_related/drive_enums/drive_type.dart';
import '../../../../enums/product_related/drive_enums/interface_type.dart';
import '../../../../enums/product_related/mainboard_enums/mainboard_form_factor.dart';

class FilterScreenWebView extends StatefulWidget {
  final FilterArgument arguments;
  final int selectedTabIndex;
  final List<Manufacturer> manufacturerList;

  const FilterScreenWebView(
      {super.key,
      required this.arguments,
      required this.selectedTabIndex,
      required this.manufacturerList});

  static Widget newInstance(
          {required FilterArgument arguments,
          required int selectedTabIndex,
          required List<Manufacturer> manufacturerList}) =>
      BlocProvider(
        create: (context) => FilterScreenCubit()
          ..initialize(
            initialFilterValue: arguments,
            selectedTabIndex: selectedTabIndex,
            manufacturerList: manufacturerList,
          ),
        child: FilterScreenWebView(
          arguments: arguments,
          selectedTabIndex: selectedTabIndex,
          manufacturerList: manufacturerList,
        ),
      );

  @override
  State<FilterScreenWebView> createState() => _FilterScreenWebViewState();
}

class _FilterScreenWebViewState extends State<FilterScreenWebView> {
  FilterScreenCubit get cubit => context.read<FilterScreenCubit>();

  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    minPriceController.text = widget.arguments.minPrice;
    maxPriceController.text = widget.arguments.maxPrice;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 800,
          height: 600,
          constraints: const BoxConstraints(maxWidth: 900, maxHeight: 700),
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
          child: BlocBuilder<FilterScreenCubit, FilterScreenState>(
            builder: (context, state) {
              return Column(
                children: [
                  // Header styled like SalesDetailWebView
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
                        final maxW = constraints.maxWidth;
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ManufacturerFilter(
                                availableWidth: maxW,
                                selectedManufacturers:
                                    state.filterArgument.manufacturerList,
                                onToggleSelection: cubit.toggleManufacturer,
                                manufacturerList: state.manufacturerList,
                              ),
                              const SizedBox(height: 16.0),
                              RangeFilter(
                                name: S.of(context).price,
                                fromController: minPriceController,
                                toController: maxPriceController,
                                onFromValueChanged: (value) => cubit
                                    .updateFilterArgument(state.filterArgument
                                        .copyWith(minPrice: value)),
                                onToValueChanged: (value) => cubit
                                    .updateFilterArgument(state.filterArgument
                                        .copyWith(maxPrice: value)),
                                fromValue: state.filterArgument.minPrice,
                                toValue: state.filterArgument.maxPrice,
                              ),
                              const SizedBox(height: 16.0),
                              _buildTabSpecificUI(state, cubit, maxW),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Footer actions with shadow
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
                    child: const SizedBox.shrink(),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTabSpecificUI(
      FilterScreenState state, FilterScreenCubit cubit, double maxW) {
    switch (state.selectedTabIndex) {
      case 1:
        return _buildRamFilterUI(state, cubit, maxW);
      case 2:
        return _buildCpuFilterUI(state, cubit, maxW);
      case 3:
        return _buildPsuFilterUI(state, cubit, maxW);
      case 4:
        return _buildGpuFilterUI(state, cubit, maxW);
      case 5:
        return _buildDriveFilterUI(state, cubit, maxW);
      case 6:
        return _buildMainboardFilterUI(state, cubit, maxW);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildRamFilterUI(
      FilterScreenState state, FilterScreenCubit cubit, double maxW) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionFilter(
          name: 'Type',
          enumValues: RAMType.values,
          selectedValues: List<RAMType>.from(state.filterArgument.ramType),
          onToggleSelection: (type) {
            final selected = List<RAMType>.from(state.filterArgument.ramType);
            if (selected.contains(type)) {
              selected.remove(type);
            } else {
              selected.add(type);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(ramType: selected));
          },
          availableWidth: maxW,
        ),
        const SizedBox(height: 16),
        RangeFilter(
          name: 'Total RAM (GB)',
          fromController:
              TextEditingController(text: state.filterArgument.minMemoryGb),
          toController:
              TextEditingController(text: state.filterArgument.maxMemoryGb),
          onFromValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(minMemoryGb: value)),
          onToValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(maxMemoryGb: value)),
          fromValue: state.filterArgument.minMemoryGb,
          toValue: state.filterArgument.maxMemoryGb,
        ),
      ],
    );
  }

  Widget _buildCpuFilterUI(
      FilterScreenState state, FilterScreenCubit cubit, double maxW) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionFilter(
          name: 'Series',
          enumValues: CPUSeries.getValues(),
          selectedValues: List<CPUSeries>.from(state.filterArgument.cpuSeries),
          onToggleSelection: (family) {
            final selected =
                List<CPUSeries>.from(state.filterArgument.cpuSeries);
            if (selected.contains(family)) {
              selected.remove(family);
            } else {
              selected.add(family);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(cpuSeries: selected));
          },
          availableWidth: maxW,
        ),
        const SizedBox(height: 16),
        RangeFilter(
          name: 'CPU clock speed (GHz)',
          fromController:
              TextEditingController(text: state.filterArgument.minClockSpeed),
          toController:
              TextEditingController(text: state.filterArgument.maxClockSpeed),
          onFromValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(minClockSpeed: value)),
          onToValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(maxClockSpeed: value)),
          fromValue: state.filterArgument.minClockSpeed,
          toValue: state.filterArgument.minClockSpeed,
        ),
        const SizedBox(height: 16),
        RangeFilter(
          name: 'TDP',
          fromController:
              TextEditingController(text: state.filterArgument.minTdp),
          toController:
              TextEditingController(text: state.filterArgument.maxTdp),
          onFromValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(minTdp: value)),
          onToValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(maxTdp: value)),
          fromValue: state.filterArgument.minTdp,
          toValue: state.filterArgument.maxTdp,
        ),
        const SizedBox(height: 16),
        OptionFilter(
          name: 'CPU socket',
          enumValues: Socket.getValues(),
          selectedValues: List<Socket>.from(state.filterArgument.sockets),
          onToggleSelection: (socket) {
            final selected = List<Socket>.from(state.filterArgument.sockets);
            if (selected.contains(socket)) {
              selected.remove(socket);
            } else {
              selected.add(socket);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(sockets: selected));
          },
          availableWidth: maxW,
        )
      ],
    );
  }

  Widget _buildPsuFilterUI(
      FilterScreenState state, FilterScreenCubit cubit, double maxW) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionFilter(
          name: 'Modular',
          enumValues: PSUModular.getValues(),
          selectedValues:
              List<PSUModular>.from(state.filterArgument.psuModularity),
          onToggleSelection: (modular) {
            final selected =
                List<PSUModular>.from(state.filterArgument.psuModularity);
            if (selected.contains(modular)) {
              selected.remove(modular);
            } else {
              selected.add(modular);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(psuModularity: selected));
          },
          availableWidth: maxW,
        ),
        const SizedBox(height: 16.0),
        OptionFilter(
          name: 'Efficiency',
          enumValues: PSUEfficiency.getValues(),
          selectedValues:
              List<PSUEfficiency>.from(state.filterArgument.psuEfficiency),
          onToggleSelection: (efficiency) {
            final selected =
                List<PSUEfficiency>.from(state.filterArgument.psuEfficiency);
            if (selected.contains(efficiency)) {
              selected.remove(efficiency);
            } else {
              selected.add(efficiency);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(psuEfficiency: selected));
          },
          availableWidth: maxW,
        ),
        const SizedBox(height: 16.0),
        RangeFilter(
          name: 'PSU wattage',
          fromController:
              TextEditingController(text: state.filterArgument.minTdp),
          toController:
              TextEditingController(text: state.filterArgument.maxTdp),
          onFromValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(minTdp: value)),
          onToValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(maxTdp: value)),
          fromValue: state.filterArgument.minTdp,
          toValue: state.filterArgument.maxTdp,
        ),
      ],
    );
  }

  Widget _buildGpuFilterUI(
      FilterScreenState state, FilterScreenCubit cubit, double maxW) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionFilter(
          name: 'GPU series',
          enumValues: GPUSeries.getValues(),
          selectedValues: List<GPUSeries>.from(state.filterArgument.gpuSeries),
          onToggleSelection: (series) {
            final selected =
                List<GPUSeries>.from(state.filterArgument.gpuSeries);
            if (selected.contains(series)) {
              selected.remove(series);
            } else {
              selected.add(series);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(gpuSeries: selected));
          },
          availableWidth: maxW,
        ),
        const SizedBox(height: 16),
        OptionFilter(
          name: 'GPU version',
          enumValues: GPUVersion.getValues(),
          selectedValues:
              List<GPUVersion>.from(state.filterArgument.gpuVersion),
          onToggleSelection: (capacity) {
            final selected =
                List<GPUVersion>.from(state.filterArgument.gpuVersion);
            if (selected.contains(capacity)) {
              selected.remove(capacity);
            } else {
              selected.add(capacity);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(gpuVersion: selected));
          },
          availableWidth: maxW,
        ),
        const SizedBox(height: 16),
        RangeFilter(
          name: 'GPU clock speed',
          fromController:
              TextEditingController(text: state.filterArgument.minClockSpeed),
          toController:
              TextEditingController(text: state.filterArgument.maxClockSpeed),
          onFromValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(minClockSpeed: value)),
          onToValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(maxClockSpeed: value)),
          fromValue: state.filterArgument.minTdp,
          toValue: state.filterArgument.maxTdp,
        ),
        const SizedBox(height: 16),
        RangeFilter(
          name: 'TDP',
          fromController:
              TextEditingController(text: state.filterArgument.minTdp),
          toController:
              TextEditingController(text: state.filterArgument.maxTdp),
          onFromValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(minTdp: value)),
          onToValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(maxTdp: value)),
          fromValue: state.filterArgument.minTdp,
          toValue: state.filterArgument.maxTdp,
        ),
        const SizedBox(height: 16),
        RangeFilter(
          name: 'Memory (GB)',
          fromController:
              TextEditingController(text: state.filterArgument.minMemoryGb),
          toController:
              TextEditingController(text: state.filterArgument.maxMemoryGb),
          onFromValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(minMemoryGb: value)),
          onToValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(maxMemoryGb: value)),
          fromValue: state.filterArgument.minMemoryGb,
          toValue: state.filterArgument.maxMemoryGb,
        ),
      ],
    );
  }

  Widget _buildDriveFilterUI(
      FilterScreenState state, FilterScreenCubit cubit, double maxW) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionFilter(
          name: 'Type',
          enumValues: DriveType.getValues(),
          selectedValues: List<DriveType>.from(state.filterArgument.driveType),
          onToggleSelection: (type) {
            final selected =
                List<DriveType>.from(state.filterArgument.driveType);
            if (selected.contains(type)) {
              selected.remove(type);
            } else {
              selected.add(type);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(driveType: selected));
          },
          availableWidth: maxW,
        ),
        const SizedBox(height: 16),
        OptionFilter(
          name: 'Drive form factor',
          enumValues: DriveFormFactor.getValues(),
          selectedValues:
              List<DriveFormFactor>.from(state.filterArgument.driveFormFactor),
          onToggleSelection: (formFactor) {
            final selected = List<DriveFormFactor>.from(
                state.filterArgument.driveFormFactor);
            if (selected.contains(formFactor)) {
              selected.remove(formFactor);
            } else {
              selected.add(formFactor);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(driveFormFactor: selected));
          },
          availableWidth: maxW,
        ),
        const SizedBox(height: 16),
        OptionFilter(
          name: 'Interface',
          enumValues: InterfaceType.getValues(),
          selectedValues:
              List<InterfaceType>.from(state.filterArgument.interfaceType),
          onToggleSelection: (interfaceType) {
            final selected =
                List<InterfaceType>.from(state.filterArgument.interfaceType);
            if (selected.contains(interfaceType)) {
              selected.remove(interfaceType);
            } else {
              selected.add(interfaceType);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(interfaceType: selected));
          },
          availableWidth: maxW,
        ),
        const SizedBox(height: 16),
        OptionFilter(
          name: 'Generation',
          enumValues: DriveGen.getValues(),
          selectedValues: List<DriveGen>.from(state.filterArgument.gen),
          onToggleSelection: (gen) {
            final selected = List<DriveGen>.from(state.filterArgument.gen);
            if (selected.contains(gen)) {
              selected.remove(gen);
            } else {
              selected.add(gen);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(gen: selected));
          },
          availableWidth: maxW,
        ),
        const SizedBox(height: 16),
        RangeFilter(
          name: 'Capacity (GB)',
          fromController:
              TextEditingController(text: state.filterArgument.minMemoryGb),
          toController:
              TextEditingController(text: state.filterArgument.maxMemoryGb),
          onFromValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(minMemoryGb: value)),
          onToValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(maxMemoryGb: value)),
          fromValue: state.filterArgument.minMemoryGb,
          toValue: state.filterArgument.maxMemoryGb,
        ),
      ],
    );
  }

  Widget _buildMainboardFilterUI(
      FilterScreenState state, FilterScreenCubit cubit, double maxW) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionFilter(
          name: 'Mainboard form factor',
          enumValues: MainboardFormFactor.getValues(),
          selectedValues: List<MainboardFormFactor>.from(
              state.filterArgument.mainboardFormFactor),
          onToggleSelection: (formFactor) {
            final selected = List<MainboardFormFactor>.from(
                state.filterArgument.mainboardFormFactor);
            if (selected.contains(formFactor)) {
              selected.remove(formFactor);
            } else {
              selected.add(formFactor);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(mainboardFormFactor: selected));
          },
          availableWidth: maxW,
        ),
        const SizedBox(height: 16.0),
        OptionFilter(
          name: 'Socket',
          enumValues: Socket.getValues(),
          selectedValues: List<Socket>.from(state.filterArgument.sockets),
          onToggleSelection: (socket) {
            final selected = List<Socket>.from(state.filterArgument.sockets);
            if (selected.contains(socket)) {
              selected.remove(socket);
            } else {
              selected.add(socket);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(sockets: selected));
          },
          availableWidth: maxW,
        ),
        const SizedBox(height: 16),
        OptionFilter(
          name: 'RAM type',
          enumValues: RAMType.getValues(),
          selectedValues: List<RAMType>.from(state.filterArgument.ramType),
          onToggleSelection: (type) {
            final selected = List<RAMType>.from(state.filterArgument.ramType);
            if (selected.contains(type)) {
              selected.remove(type);
            } else {
              selected.add(type);
            }
            cubit.updateFilterArgument(
                state.filterArgument.copyWith(ramType: selected));
          },
          availableWidth: maxW,
        ),
        const SizedBox(height: 16),
        RangeFilter(
          name: 'Total RAM (GB)',
          fromController:
              TextEditingController(text: state.filterArgument.minMemoryGb),
          toController:
              TextEditingController(text: state.filterArgument.maxMemoryGb),
          onFromValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(minMemoryGb: value)),
          onToValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(maxMemoryGb: value)),
          fromValue: state.filterArgument.minMemoryGb,
          toValue: state.filterArgument.maxMemoryGb,
        ),
        const SizedBox(height: 16),
        RangeFilter(
          name: 'M.2 Slots',
          fromController:
              TextEditingController(text: state.filterArgument.minM2Slots),
          toController:
              TextEditingController(text: state.filterArgument.maxM2Slots),
          onFromValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(minM2Slots: value)),
          onToValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(maxM2Slots: value)),
          fromValue: state.filterArgument.minM2Slots,
          toValue: state.filterArgument.maxM2Slots,
        ),
        const SizedBox(height: 16),
        RangeFilter(
          name: 'SATA Ports',
          fromController:
              TextEditingController(text: state.filterArgument.minSataPorts),
          toController:
              TextEditingController(text: state.filterArgument.maxSataPorts),
          onFromValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(minSataPorts: value)),
          onToValueChanged: (value) => cubit.updateFilterArgument(
              state.filterArgument.copyWith(maxSataPorts: value)),
          fromValue: state.filterArgument.minSataPorts,
          toValue: state.filterArgument.maxSataPorts,
        ),
      ],
    );
  }
}
