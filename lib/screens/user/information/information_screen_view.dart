import 'package:flutter/material.dart';

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
            const Text(
              'About GizmoGlobe', //Về GizmoGlobe
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            _buildInfoSection(
              title: 'About Us', //Về chúng tôi
              content: 'GizmoGlobe is your trusted provider for computer hardware solutions.', //Giải pháp phần cứng máy tính đáng tin cậy của bạn
            ),
            _buildInfoSection(
              title: 'Our Mission', //Sứ mệnh của chúng tôi
              content: 'To provide excellent service and quality products to you, our beloved customers.', //Cung cấp dịch vụ xuất sắc và sản phẩm chất lượng cho bạn, khách hàng thân yêu của chúng tôi
            ),
            _buildInfoSection(
              title: 'Contact Information', //Thông tin liên hệ
              content: 'Address: UIT', //Địa chỉ: UIT
            ),
            _buildInfoSection(
              title: 'Business Hours', //Giờ làm việc
              content: 'Monday - Friday: 9:00 AM - 6:00 PM\nSaturday: 10:00 AM - 4:00 PM\nSunday: Closed',
              //Thứ Hai - Thứ Sáu: 9:00 sáng - 6:00 chiều\nThứ Bảy: 10:00 sáng - 4:00 chiều\nChủ Nhật: Đóng cửa
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