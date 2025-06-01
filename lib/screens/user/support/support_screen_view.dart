import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';

import '../../../widgets/general/gradient_icon_button.dart';
import '../../../widgets/general/gradient_text.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: GradientText(text: S.of(context).supportTitle),
        leading: GradientIconButton(
          icon: Icons.chevron_left,
          onPressed: () {
            Navigator.pop(context);
          },
          fillColor: Theme.of(context).colorScheme.surface,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).supportMembers,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildContactItem(
              icon: Icons.people_outlined,
              title: 'Tô Vĩnh Tiến',
              subtitle: '22521474',
              onTap: () => _showContactDetails(
                context,
                name: 'Tô Vĩnh Tiến',
                studentId: '22521474',
                role: S.of(context).supportRoleDeveloper,
                email: '22521474@gm.uit.edu.vn',
              ),
            ),
            _buildContactItem(
              icon: Icons.people_outlined,
              title: 'Đỗ Hồng Quân',
              subtitle: '22521175',
              onTap: () => _showContactDetails(
                context,
                name: 'Đỗ Hồng Quân',
                studentId: '22521175',
                role: S.of(context).supportRoleDeveloper,
                email: '22521175@gm.uit.edu.vn',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Icon(
          icon,
          size: 32,
          color: Colors.blue,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.blue,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  void _showContactDetails(
    BuildContext context, {
    required String name,
    required String studentId,
    required String role,
    required String email,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.badge_outlined,
                S.of(context).supportStudentId(studentId)),
            _buildDetailRow(
                Icons.work_outline, S.of(context).supportRole(role)),
            _buildDetailRow(
                Icons.email_outlined, S.of(context).supportEmail(email)),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
