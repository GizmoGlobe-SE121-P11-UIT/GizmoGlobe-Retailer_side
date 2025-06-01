import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/objects/employee.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_text.dart';

import '../employee_edit/employee_edit_view.dart';
import '../permissions/employee_permissions.dart';
import 'employee_detail_cubit.dart';
import 'employee_detail_state.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final Employee employee;
  final bool readOnly;

  const EmployeeDetailScreen({
    super.key,
    required this.employee,
    this.readOnly = false,
  });

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => EmployeeDetailCubit(widget.employee),
      child: BlocBuilder<EmployeeDetailCubit, EmployeeDetailState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: GradientIconButton(
                icon: Icons.chevron_left,
                onPressed: () => Navigator.pop(context),
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              title: GradientText(text: S.of(context).employeeDetail),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildHeaderSection(context, state),
                        const SizedBox(height: 24),
                        _buildInfoSection(context, state),
                      ],
                    ),
                  ),
                ),
                _buildActionButtons(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, EmployeeDetailState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
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
          const SizedBox(height: 16),
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
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              state.employee.role.toString(),
              style: const TextStyle(
                color: Colors.white,
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                    S.of(context).employeeInformation,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildInfoRow(S.of(context).email, state.employee.email),
              _buildInfoRow(S.of(context).phone, state.employee.phoneNumber),
              _buildInfoRow(S.of(context).role, state.employee.role.toString()),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, EmployeeDetailState state) {
    if (widget.readOnly) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          if (EmployeePermissions.canEditEmployee(
              state.userRole, state.employee))
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleEdit(context, state),
                icon: const Icon(Icons.edit, color: Colors.white),
                label: Text(S.of(context).edit,
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          if (EmployeePermissions.canEditEmployee(
                  state.userRole, state.employee) &&
              EmployeePermissions.canDeleteEmployee(
                  state.userRole, state.employee))
            const SizedBox(width: 16),
          if (EmployeePermissions.canDeleteEmployee(
              state.userRole, state.employee))
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _handleDelete(context),
                icon: const Icon(Icons.delete, color: Colors.white),
                label: Text(S.of(context).delete,
                    style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleEdit(BuildContext context, EmployeeDetailState state) async {
    final updatedEmployee = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmployeeEditScreen(
          employee: state.employee,
          userRole: state.userRole,
        ),
      ),
    );

    if (updatedEmployee != null) {
      final cubit = context.read<EmployeeDetailCubit>();
      cubit.updateEmployee(updatedEmployee);
    }
  }

  void _handleDelete(BuildContext context) async {
    final cubit = context.read<EmployeeDetailCubit>();
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
              await cubit.deleteEmployee();
              if (mounted) {
                Navigator.pop(context);
              }
            },
            child: Text(
              S.of(context).delete,
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
