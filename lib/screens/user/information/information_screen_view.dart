import 'package:flutter/material.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';

import '../../../widgets/general/gradient_icon_button.dart';
import '../../../widgets/general/gradient_text.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const GradientText(text: 'Information'), //Thông tin
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
              S.of(context).aboutGizmoGlobe,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              title: S.of(context).aboutUsTitle,
              content: S.of(context).aboutUsContent,
            ),
            _buildInfoSection(
              title: S.of(context).ourMissionTitle,
              content: S.of(context).ourMissionContent,
            ),
            _buildInfoSection(
              title: S.of(context).contactInformationTitle,
              content: S.of(context).contactInformationContent,
            ),
            _buildInfoSection(
              title: S.of(context).businessHoursTitle,
              content: S.of(context).businessHoursContent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
