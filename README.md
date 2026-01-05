# GizmoGlobe Retailer

A comprehensive Flutter-based inventory and sales management application for computer component retailers. This application enables retailers to manage products, customers, vendors, employees, invoices, vouchers, and communicate with customers through a built-in chat system.

<p align="center">
  <img src="lib/GIzmoGlobe.png" alt="GizmoGlobe Logo" width="200">
</p>

## 🌐 Live Demo

**Production URL:** [https://gizmoglobe-retailer.web.app](https://gizmoglobe-retailer.web.app)

## 📋 Table of Contents

- [Features](#-features)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
- [Environment Configuration](#-environment-configuration)
- [Firebase Setup](#-firebase-setup)
- [Running the Application](#-running-the-application)
- [Deployment](#-deployment)
- [Localization](#-localization)
- [Architecture](#-architecture)

## ✨ Features

### 📦 Product Management

- **CRUD Operations**: Create, read, update, and delete products
- **Multi-Category Support**: CPU, GPU, RAM, Mainboard, PSU, Drives (HDD/SSD)
- **Advanced Filtering**: Filter by category, manufacturer, price, status
- **Product Images**: Multiple images per product with Firebase Storage integration
- **Stock Management**: Track inventory levels and product statuses

### 🧾 Invoice Management

- **Sales Invoices**: Process customer orders with detailed line items
- **Incoming Invoices**: Track vendor purchases and stock replenishment
- **Warranty Invoices**: Manage product warranties and claims
- **Status Tracking**: Pending, Processing, Completed, Cancelled states
- **Payment Methods**: Cash, Bank Transfer, Credit Card support

### 👥 Stakeholder Management

- **Customers**: Customer profiles, purchase history, ratings
- **Employees**: Staff accounts with role-based permissions
- **Vendors**: Supplier information and incoming invoice tracking
- **Manufacturers**: Brand management for products

### 🎫 Voucher System

- **Voucher Types**: Percentage discounts, fixed amount discounts
- **Distribution Types**: Public, Customer-specific, Limited quantity
- **Validity Periods**: Start/end date management
- **Usage Tracking**: Monitor voucher redemptions

### 💬 Chat System

- **Real-time Messaging**: Firebase-powered customer communication
- **Conversation List**: Manage multiple customer conversations
- **Message History**: Full conversation history preservation

### 📊 Business Reports

- **PDF Generation**: Comprehensive business reports with charts
- **Financial Overview**: Revenue, costs, and profit analysis
- **Sales Analysis**: Top products, category breakdown
- **Customer Insights**: Top customers, spending patterns
- **Inventory Reports**: Stock levels and movement

### 🔐 Authentication

- **Email/Password**: Traditional authentication
- **Google Sign-In**: OAuth integration
- **Password Recovery**: Email-based password reset
- **Role-Based Access**: Admin and employee permission levels

### 🌍 Internationalization

- **English**: Full English language support
- **Vietnamese**: Complete Vietnamese localization

## 🛠 Tech Stack

| Technology           | Purpose                     |
| -------------------- | --------------------------- |
| **Flutter**          | Cross-platform UI framework |
| **Dart**             | Programming language        |
| **Firebase Auth**    | Authentication service      |
| **Cloud Firestore**  | NoSQL database              |
| **Firebase Storage** | File/image storage          |
| **Cloud Functions**  | Serverless backend logic    |
| **Firebase Hosting** | Web deployment              |
| **BLoC/Cubit**       | State management            |
| **Provider**         | Dependency injection        |
| **flutter_dotenv**   | Environment configuration   |
| **pdf**              | PDF generation              |
| **fl_chart**         | Data visualization          |

## 📁 Project Structure

```
lib/
├── main.dart                 # Application entry point & routing
├── app.dart                  # App configuration
├── app_view.dart             # Root widget
├── auth.dart                 # Authentication wrapper
├── firebase_options.dart     # Firebase configuration
│
├── components/               # Shared UI components
│   └── general/              # General-purpose components
│
├── data/                     # Data layer
│   ├── database/             # Local database assets (JSON)
│   ├── firebase/             # Firebase service (84KB, 97+ methods)
│   │   └── firebase.dart     # Centralized Firebase operations
│   └── new_data/             # Data initialization scripts
│
├── enums/                    # Enumeration types (27 files)
│   ├── invoice_related/      # Invoice statuses, payment methods
│   ├── processing/           # Processing states
│   ├── product_related/      # Categories, product statuses
│   │   ├── cpu_enums/        # CPU-specific enums
│   │   ├── gpu_enums/        # GPU-specific enums
│   │   ├── ram_enums/        # RAM-specific enums
│   │   ├── drive_enums/      # Drive-specific enums
│   │   ├── mainboard_enums/  # Mainboard-specific enums
│   │   └── psu_enums/        # PSU-specific enums
│   ├── stakeholders/         # Customer/employee types
│   └── voucher_related/      # Voucher types
│
├── functions/                # Utility functions
│   ├── converter.dart        # Data type converters
│   ├── custom_exception.dart # Custom exception classes
│   ├── getdata.dart          # Data fetching utilities
│   └── helper.dart           # Helper functions
│
├── localization/             # i18n support
│   ├── app_localization.dart # Localization configuration
│   ├── en.dart               # English translations (23KB)
│   └── vi.dart               # Vietnamese translations (28KB)
│
├── objects/                  # Data models (52+ files)
│   ├── address_related/      # Address models
│   ├── chat_related/         # Chat/message models
│   ├── invoice_related/      # Invoice models (10 files)
│   │   ├── sales_invoice.dart
│   │   ├── incoming_invoice.dart
│   │   ├── warranty_invoice.dart
│   │   ├── rating.dart
│   │   └── reply.dart
│   ├── product_related/      # Product models (19 files)
│   │   ├── product.dart
│   │   ├── product_factory.dart
│   │   ├── product_argument.dart
│   │   ├── cpu_related/
│   │   ├── gpu_related/
│   │   ├── ram_related/
│   │   ├── mainboard_related/
│   │   ├── drive_related/
│   │   └── psu_related/
│   ├── voucher_related/      # Voucher models (7 files)
│   │   ├── voucher.dart
│   │   ├── voucher_factory.dart
│   │   └── voucher_argument.dart
│   ├── customer.dart         # Customer model
│   ├── employee.dart         # Employee model
│   └── manufacturer.dart     # Manufacturer model
│
├── presentation/             # UI resources
│   └── resources/            # Themes, colors, styles
│
├── providers/                # State providers
│   ├── language_provider.dart    # Language state
│   ├── locale_provider.dart      # Locale state
│   └── theme_provider.dart       # Theme state
│
├── screens/                  # UI screens (167 files)
│   ├── authentication/       # Auth screens (12 files)
│   │   ├── sign_in_screen/
│   │   ├── sign_up_screen/
│   │   └── forget_password_screen/
│   ├── chat/                 # Chat screens (8 files)
│   │   ├── list/             # Conversation list
│   │   └── conversation/     # Chat conversation
│   ├── home/                 # Dashboard (4 files)
│   │   └── home_screen/
│   ├── invoice/              # Invoice management (51 files)
│   │   ├── sales/            # Sales invoices (24 files)
│   │   │   ├── sales_add/
│   │   │   ├── sales_detail/
│   │   │   ├── sales_edit/
│   │   │   ├── rating_reply/
│   │   │   ├── filter/
│   │   │   └── permissions/
│   │   ├── incoming/         # Incoming invoices (12 files)
│   │   │   ├── incoming_add/
│   │   │   ├── incoming_detail/
│   │   │   └── permissions/
│   │   └── warranty/         # Warranty invoices (12 files)
│   │       ├── warranty_add/
│   │       ├── warranty_detail/
│   │       └── permissions/
│   ├── main/                 # Main layout (6 files)
│   │   ├── drawer/           # Navigation drawer
│   │   └── main_screen/      # Main container
│   ├── media/                # Media handling (2 files)
│   ├── product/              # Product management (23 files)
│   │   ├── add_product/
│   │   ├── product_detail/
│   │   ├── product_screen/
│   │   ├── filter/
│   │   ├── mixin/
│   │   └── permissions/
│   ├── stakeholder/          # Stakeholder management (37 files)
│   │   ├── customers/        # Customer screens (11 files)
│   │   ├── employees/        # Employee screens (11 files)
│   │   ├── vendors/          # Vendor screens (11 files)
│   │   └── permissions/
│   ├── starting/             # Splash/onboarding (2 files)
│   ├── user/                 # User profile (6 files)
│   │   ├── user_screen/
│   │   ├── information/
│   │   └── support/
│   └── voucher/              # Voucher management (16 files)
│       ├── add_voucher/
│       ├── edit_voucher/
│       ├── list/
│       └── voucher_detail/
│
├── services/                 # Business services
│   ├── invoices/             # Invoice services
│   │   ├── incoming/
│   │   └── sales/
│   └── reports/              # Report generation
│       └── business_report_pdf_service.dart  # PDF reports (55KB)
│
├── utils/                    # Utilities
│   ├── app_navigator.dart        # Navigation utilities
│   ├── mobile_utils.dart         # Mobile-specific utilities
│   ├── platform_specific_utils.dart
│   ├── platform_utils.dart       # Platform detection
│   ├── web_utils.dart            # Web-specific utilities
│   └── web_utils_stub.dart       # Web stub for non-web platforms
│
└── widgets/                  # Reusable widgets (35 files)
    ├── chat/                 # Chat widgets
    ├── dialog/               # Dialog widgets
    ├── filter/               # Filter widgets (6 files)
    ├── general/              # General widgets (19 files)
    │   ├── address_picker.dart
    │   ├── gradient_dropdown.dart
    │   ├── searchable_dropdown.dart
    │   ├── status_badge.dart
    │   └── ...
    ├── invoice/              # Invoice widgets
    ├── product/              # Product widgets
    ├── snackbar/             # Notification widgets
    └── voucher/              # Voucher widgets
```

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK**: 3.3.0 or higher
- **Dart SDK**: 3.3.0 or higher
- **Firebase CLI**: For deployment
- **Node.js**: For Firebase Functions

### Installation

1. **Clone the repository**

   ```bash
   git clone https://github.com/your-username/SE121.P11-GizmoGlobe-Retailer_side.git
   cd SE121.P11-GizmoGlobe-Retailer_side
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

## ⚙️ Environment Configuration

Create a `.env` file in the project root with the following variables:

```env
# Firebase Configuration
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_WEB_API_KEY=your-web-api-key
FIREBASE_WEB_APP_ID=your-web-app-id
FIREBASE_WEB_MESSAGING_SENDER_ID=your-sender-id
FIREBASE_WEB_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_WEB_STORAGE_BUCKET=your-project.firebasestorage.app
FIREBASE_WEB_MEASUREMENT_ID=G-XXXXXXXXXX

# Android Configuration
FIREBASE_ANDROID_API_KEY=your-android-api-key
FIREBASE_ANDROID_APP_ID=your-android-app-id

# iOS Configuration
FIREBASE_IOS_API_KEY=your-ios-api-key
FIREBASE_IOS_APP_ID=your-ios-app-id

# Stripe (Optional)
STRIPE_PUBLISHABLE_KEY=pk_test_xxx
```

> **Note**: For web deployments, use `.env.web` which contains only public configuration keys (no secrets).

## 🔥 Firebase Setup

1. **Create a Firebase project** at [Firebase Console](https://console.firebase.google.com/)

2. **Enable services**:

   - Authentication (Email/Password, Google Sign-In)
   - Cloud Firestore
   - Firebase Storage
   - Firebase Hosting

3. **Configure Firebase**:

   ```bash
   firebase login
   firebase init
   ```

4. **Deploy Firestore rules and indexes** (if applicable)

## 🏃 Running the Application

### Development

```bash
# Run on Chrome (Web)
flutter run -d chrome

# Run on Android
flutter run -d android

# Run on iOS
flutter run -d ios

# Run with specific port (Web)
flutter run -d chrome --web-port 5173
```

### Build

```bash
# Build for Web
flutter build web --release

# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

## 🚢 Deployment

### Automatic Deployment (GitHub Actions)

The project is configured with GitHub Actions for automatic deployment:

- **On Push to `main`**: Deploys to production Firebase Hosting
- **On Pull Request**: Creates a preview deployment

### Manual Deployment

```bash
# Build the web app
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### GitHub Actions Secrets Required

Add these secrets to your GitHub repository:

| Secret Name                                    | Description                   |
| ---------------------------------------------- | ----------------------------- |
| `FIREBASE_SERVICE_ACCOUNT_SE121P11_GIZMOGLOBE` | Firebase service account JSON |

## 🌐 Localization

The application supports:

| Language   | File                       | Status      |
| ---------- | -------------------------- | ----------- |
| English    | `lib/localization/en.dart` | ✅ Complete |
| Vietnamese | `lib/localization/vi.dart` | ✅ Complete |

### Adding a New Language

1. Create a new file in `lib/localization/` (e.g., `fr.dart`)
2. Copy the structure from `en.dart`
3. Translate all strings
4. Register the language in `app_localization.dart`

## 🏗 Architecture

### State Management

The application uses **BLoC/Cubit** pattern for state management:

```
Screen (View) → Cubit (Business Logic) → State
                    ↓
              Firebase Service
```

### Each Screen Module Contains

```
screen_name/
├── screen_name_cubit.dart   # Business logic
├── screen_name_state.dart   # State definitions
├── screen_name_view.dart    # Mobile UI
└── screen_name_webview.dart # Web-optimized UI (optional)
```

### Data Flow

```
UI Layer (Widgets/Screens)
         ↓
State Management (Cubit/BLoC)
         ↓
Data Layer (Firebase Service)
         ↓
Firebase (Firestore/Auth/Storage)
```

## 📄 License

This project is part of the SE121.P11 course at UIT (University of Information Technology).

## 👥 Contributors

- **Project**: SE121.P11 - GizmoGlobe
- **Course**: Software Engineering

---

<p align="center">
  Made with ❤️ using Flutter
</p>
