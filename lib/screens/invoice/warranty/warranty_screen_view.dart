import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/widgets/general/field_with_icon.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'warranty_screen_cubit.dart';
import 'warranty_screen_state.dart';

class WarrantyScreen extends StatefulWidget {
  const WarrantyScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => WarrantyScreenCubit(),
        child: const WarrantyScreen(),
      );

  @override
  State<WarrantyScreen> createState() => _WarrantyScreenState();
}

class _WarrantyScreenState extends State<WarrantyScreen> {
  final TextEditingController searchController = TextEditingController();
  WarrantyScreenCubit get cubit => context.read<WarrantyScreenCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WarrantyScreenCubit, WarrantyScreenState>(
      builder: (context, state) {
        return GestureDetector(
          onTap: () {
            if (state.selectedIndex != null) {
              cubit.setSelectedIndex(null);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: FieldWithIcon(
                        controller: searchController,
                        hintText: 'Find warranty invoices...',
                        fillColor: Theme.of(context).colorScheme.surface,
                        onChanged: (value) {
                          cubit.searchInvoices(value);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    GradientIconButton(
                      icon: Icons.add,
                      iconSize: 32,
                      onPressed: () {
                        // TODO: Implement add warranty invoice
                      },
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
