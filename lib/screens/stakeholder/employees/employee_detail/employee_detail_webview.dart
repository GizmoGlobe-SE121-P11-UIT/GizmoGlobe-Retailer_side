import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/objects/employee.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';

import '../../permissions/stakeholder_permissions.dart';
import '../employee_edit/employee_edit_view.dart';
import 'employee_detail_cubit.dart';
import 'employee_detail_state.dart';

class EmployeeDetailWebView extends StatefulWidget {
  final Employee employee;
  final bool readOnly;

  const EmployeeDetailWebView({
    super.key,
    required this.employee,
    this.readOnly = false,
  });

  static Widget newInstance({
    required Employee employee,
    bool readOnly = false,
  }) =>
      BlocProvider(
        create: (context) => EmployeeDetailCubit(employee),
        child: EmployeeDetailWebView(
          employee: employee,
          readOnly: readOnly,
        ),
      );

  @override
  State<EmployeeDetailWebView> createState() => _EmployeeDetailWebViewState();
}

class _EmployeeDetailWebViewState extends State<EmployeeDetailWebView> {
  EmployeeDetailCubit get cubit => context.read<EmployeeDetailCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeeDetailCubit, EmployeeDetailState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.height * 0.8,
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
                      Icons.person,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientText(text: S.of(context).employeeDetail),
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
                        _buildInfoSection(context, state),
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
                child: !widget.readOnly &&
                        StakeholderPermissions.canEditEmployees()
                    ? Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  final updatedEmployee =
                                      await EmployeeEditScreen.showModal(
                                    context,
                                    state.employee,
                                    state.userRole,
                                  );

                                  if (updatedEmployee != null) {
                                    cubit.updateEmployee(updatedEmployee);

                                    // Show success snackbar before closing
                                    _showSnackBar(
                                      title: S.of(context).success,
                                      message: "Employee updated successfully.",
                                      contentType: ContentType.success,
                                    );

                                    // Small delay to show snackbar before closing
                                    await Future.delayed(
                                        const Duration(milliseconds: 100));

                                    if (mounted) {
                                      Navigator.of(context)
                                          .pop(updatedEmployee);
                                    }
                                  }
                                } catch (e) {
                                  if (mounted) {
                                    _showErrorDialog(
                                        "Failed to update employee: ${e.toString()}");
                                  }
                                }
                              },
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              label: Text(S.of(context).edit,
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  )),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.tertiary,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          if (StakeholderPermissions.canFireEmployees())
                            const SizedBox(width: 16),
                          if (StakeholderPermissions.canFireEmployees())
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _handleDelete(context),
                                icon: Icon(
                                  Icons.delete,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                label: Text(S.of(context).delete,
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    )),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                        ],
                      )
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(BuildContext context, EmployeeDetailState state) {
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
            tag: 'employee_avatar_${state.employee.employeeID}',
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.employee.employeeName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .onPrimary
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${S.of(context).role}: ${state.employee.role.localizedName(context)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, EmployeeDetailState state) {
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
              _buildInfoRow(S.of(context).email, state.employee.email),
              _buildInfoRow(S.of(context).phone, state.employee.phoneNumber),
              _buildInfoRow(S.of(context).role,
                  state.employee.role.localizedName(context)),
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

  void _handleDelete(BuildContext context) async {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(S.of(context).deleteEmployee),
        content: Text(S.of(context).areYouSureDeleteEmployee),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              try {
                await cubit.deleteEmployee();
                if (mounted) {
                  // Show success snackbar before closing
                  _showSnackBar(
                    title: S.of(context).success,
                    message: "Employee deleted successfully.",
                    contentType: ContentType.success,
                  );

                  // Small delay to show snackbar before closing
                  await Future.delayed(const Duration(milliseconds: 100));

                  Navigator.pop(context);
                }
              } catch (e) {
                if (mounted) {
                  _showErrorDialog(
                      "Failed to delete employee: ${e.toString()}");
                }
              }
            },
            child: Text(
              S.of(context).delete,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar({
    required String title,
    required String message,
    required ContentType contentType,
  }) {
    if (!mounted) return;

    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: title,
        message: message,
        contentType: contentType,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showErrorDialog(String errorMessage) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).errorOccurred),
        content: Text(errorMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(S.of(context).confirm),
          ),
        ],
      ),
    );
  }
}
