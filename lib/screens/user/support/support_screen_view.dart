import 'package:flutter/material.dart';

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
        title: const GradientText(text: 'Support'),
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
            const Text(
              'Members of teams',
              style: TextStyle(
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
                role: 'Developer',
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
                role: 'Developer',
                email: '22521175@gm.uit.edu.vn',
              ),
            ),
            _buildContactItem(
              icon: Icons.people_outlined,
              title: 'Trần Nhật Tân',
              subtitle: '22521312',
              onTap: () => _showContactDetails(
                context,
                name: 'Trần Nhật Tân',
                studentId: '22521312',
                role: 'Developer',
                email: '22521312@gm.uit.edu.vn',
              ),
            ),
            _buildContactItem(
              icon: Icons.people_outlined,
              title: 'Nguyễn Duy Vũ',
              subtitle: '22521693',
              onTap: () => _showContactDetails(
                context,
                name: 'Nguyễn Duy Vũ',
                studentId: '22521693',
                role: 'Developer',
                email: '22521693@gm.uit.edu.vn',
              ),
            ),
            _buildContactItem(
              icon: Icons.people_outlined,
              title: 'Phan Nguyên Khoa',
              subtitle: '2252XXXX',
              onTap: () => _showContactDetails(
                context,
                name: 'Phan Nguyên Khoa',
                studentId: '2252XXXX',
                role: 'Developer',
                email: '2252XXXX@gm.uit.edu.vn',
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
            _buildDetailRow(Icons.badge_outlined, 'Student ID: $studentId'),
            _buildDetailRow(Icons.work_outline, 'Role: $role'),
            _buildDetailRow(Icons.email_outlined, 'Email: $email'),
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