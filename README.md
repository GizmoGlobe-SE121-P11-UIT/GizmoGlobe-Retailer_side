# 🛒 GizmoGlobe - Retailer Management System

**GizmoGlobe Retailer** là một ứng dụng di động quản lý cửa hàng bán lẻ linh kiện máy tính được phát triển bằng Flutter. Ứng dụng cung cấp giải pháp toàn diện cho việc quản lý sản phẩm, khách hàng, nhân viên, hóa đơn và nhiều tính năng khác.

## 🚀 Tính năng chính

### 📦 Quản lý sản phẩm

- **Danh mục sản phẩm**: CPU, GPU, RAM, PSU, Mainboard, Drive
- **Thêm/sửa/xóa sản phẩm** với thông tin chi tiết
- **Quản lý kho hàng** và theo dõi tồn kho
- **Hệ thống lọc và tìm kiếm** nâng cao
- **Quản lý giá** và chiết khấu
- **Upload hình ảnh** sản phẩm

### 👥 Quản lý đối tác

- **Khách hàng**: Quản lý thông tin, địa chỉ, điểm tích lũy
- **Nhân viên**: Quản lý thông tin nhân viên và quyền hạn
- **Nhà cung cấp**: Quản lý thông tin nhà cung cấp

### 📋 Quản lý hóa đơn

- **Hóa đơn bán hàng**: Tạo và quản lý đơn hàng
- **Hóa đơn nhập hàng**: Quản lý việc nhập kho
- **Hóa đơn bảo hành**: Xử lý các yêu cầu bảo hành

### 🎟️ Hệ thống voucher

- **Tạo và quản lý voucher** giảm giá
- **Áp dụng voucher** cho đơn hàng
- **Theo dõi hiệu quả** các chương trình khuyến mãi

### 💬 Hệ thống chat

- **Chat real-time** với khách hàng
- **Quản lý cuộc hội thoại**
- **Thông báo tin nhắn mới**

### 📊 Dashboard và báo cáo

- **Tổng quan doanh thu** theo tháng
- **Thống kê sản phẩm** và khách hàng
- **Biểu đồ trực quan** với FL Chart
- **Báo cáo hiệu suất** bán hàng

### 🌐 Đa ngôn ngữ

- Hỗ trợ **Tiếng Việt** và **Tiếng Anh**
- Tự động chuyển đổi ngôn ngữ theo cài đặt

## 🛠️ Công nghệ sử dụng

### Frontend

- **Flutter** 3.3.0+ - Framework phát triển ứng dụng đa nền tảng
- **Dart** - Ngôn ngữ lập trình chính

### State Management

- **Flutter BLoC** - Quản lý trạng thái ứng dụng
- **Provider** - Quản lý theme và ngôn ngữ

### Backend & Database

- **Firebase** - Backend as a Service
  - **Firebase Auth** - Xác thực người dùng
  - **Cloud Firestore** - Cơ sở dữ liệu NoSQL
  - **Firebase Storage** - Lưu trữ hình ảnh
  - **Firebase App Check** - Bảo mật ứng dụng

### UI/UX Libraries

- **Material Design** - Thiết kế giao diện
- **Font Awesome Flutter** - Icon set
- **FL Chart** - Biểu đồ và thống kê
- **Pie Chart** - Biểu đồ tròn
- **Flutter ColorPicker** - Chọn màu sắc

### Utilities

- **Image Picker** - Chọn ảnh từ gallery/camera
- **File Picker** - Chọn file
- **HTTP & Dio** - Gọi API
- **Shared Preferences** - Lưu trữ local
- **Permission Handler** - Quản lý quyền
- **Intl** - Quốc tế hóa
- **Equatable** - So sánh objects

### Payment

- **Flutter Stripe** - Tích hợp thanh toán

## 📁 Cấu trúc dự án

```
lib/
├── data/
│   ├── database/           # Database và local data
│   └── firebase/          # Firebase configurations
├── enums/                 # Các enum định nghĩa
│   ├── invoice_related/
│   ├── product_related/
│   ├── stakeholders/
│   └── voucher_related/
├── functions/            # Utility functions
├── generated/           # Generated files (l10n)
├── l10n/               # Localization files
├── objects/            # Data models
│   ├── address_related/
│   ├── chat_related/
│   ├── invoice_related/
│   ├── product_related/
│   └── voucher_related/
├── presentation/       # UI resources
│   └── resources/
├── providers/         # State providers
├── screens/          # UI Screens
│   ├── authentication/
│   ├── chat/
│   ├── home/
│   ├── invoice/
│   ├── main/
│   ├── product/
│   ├── stakeholder/
│   ├── user/
│   └── voucher/
└── widgets/          # Reusable UI components
    ├── chat/
    ├── dialog/
    ├── filter/
    ├── general/
    └── voucher/
```

## 🚀 Cài đặt và chạy dự án

### Người dùng cơ bản có thể cài đặt thông qua file .APK ở trong thư mục /release đã được build sẵn.

### Yêu cầu hệ thống

- Flutter SDK 3.3.0 hoặc mới hơn
- Dart SDK
- Android Studio / VS Code
- Firebase CLI

### Các bước cài đặt

1. **Clone repository**

```bash
git clone <repository-url>
cd SE121.P11-GizmoGlobe-Retailer_side
```

2. **Cài đặt dependencies**

```bash
flutter pub get
```

3. **Cấu hình Firebase**

- Tạo project Firebase mới tại [Firebase Console](https://console.firebase.google.com)
- Thêm ứng dụng Android/iOS vào project
- Tải file `google-services.json` (Android) vào `android/app/`
<!-- - Tải file `GoogleService-Info.plist` (iOS) vào `ios/Runner/` -->

4. **Cấu hình environment variables**

- Tạo file `.env` ở thư mục root
- Thêm các biến môi trường cần thiết

5. **Generate code**

```bash
flutter packages pub run build_runner build
```

6. **Chạy ứng dụng**

```bash
flutter run
```

## 📱 Hỗ trợ nền tảng

- ✅ **Android** 6.0+ (API level 23+)
<!-- - ✅ **iOS** 11.0+
- ⚠️ **Web** (Limited support) -->

## 🔐 Bảo mật

- **Firebase App Check** cho bảo mật API
- **Firebase Auth** cho xác thực người dùng
- **Permission Handler** cho quản lý quyền truy cập
- **Input validation** và **error handling**

## 🌟 Tính năng nổi bật

- **Responsive Design** - Tương thích với nhiều kích thước màn hình
- **Dark/Light Theme** - Hỗ trợ chế độ sáng/tối
- **Real-time Updates** - Cập nhật dữ liệu thời gian thực với Firebase
- **Material Design 3** - Giao diện hiện đại theo chuẩn Google

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.


## 🙏 Acknowledgements

- [Flutter](https://flutter.dev)
- [Firebase](https://firebase.google.com)
- [Material Design](https://material.io)
- [Font Awesome](https://fontawesome.com)
- [FL Chart](https://github.com/imaNNeoFighT/fl_chart)

---

**GizmoGlobe Retailer** - Giải pháp quản lý cửa hàng linh kiện máy tính toàn diện và hiện đại. 🚀✨
