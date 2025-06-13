import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/screens/user/information/information_screen_view.dart';
import 'package:gizmoglobe_client/screens/user/support/support_screen_view.dart';
import 'package:provider/provider.dart';

import '../../../data/firebase/firebase.dart';
import '../../../providers/theme_provider.dart';
import '../../../providers/locale_provider.dart';
import 'user_screen_cubit.dart';
import 'user_screen_state.dart';
import '../../../widgets/dialog/information_dialog.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  static Widget newInstance() => BlocProvider(
        create: (context) => UserScreenCubit(),
        child: const UserScreen(),
      );

  @override
  State<UserScreen> createState() => _UserScreen();
}

class _UserScreen extends State<UserScreen> {
  UserScreenCubit get cubit => context.read<UserScreenCubit>();

  @override
  void initState() {
    super.initState();
    cubit.getUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _showUpdateSamplesModal(context),
      //   child: const Icon(Icons.cloud_upload),
      // ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).primaryColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                  child: BlocBuilder<UserScreenCubit, UserScreenState>(
                    builder: (context, state) {
                      return Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.username,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.email_outlined,
                                        size: 16,
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        state.email,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.white
                                              .withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),

            // Quick Actions
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickActionItem(
                          icon: Icons.info_outline,
                          title: S.of(context).informationTitle, //Thông tin
                          color: Colors.blue,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InformationScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickActionItem(
                          icon: Icons.headset_mic_outlined,
                          title: S.of(context).supportTitle, //Hỗ trợ
                          color: Colors.orange,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SupportScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Account Settings
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context).accountSettings, //Cài đặt tài khoản
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsItem(
                    icon: Icons.person_outline,
                    title: S.of(context).editProfile, //Chỉnh sửa hồ sơ
                    subtitle: S
                        .of(context)
                        .updatePersonalInfo, //Cập nhật thông tin cá nhân
                    onTap: () => showEditProfileBottomSheet(context),
                    iconColor: Colors.blue,
                  ),
                  _buildSettingsItem(
                    icon: Icons.lock_outline,
                    title: S.of(context).changePassword,
                    subtitle: S.of(context).manageAccountSecurity,
                    onTap: () => showChangePasswordBottomSheet(context),
                    iconColor: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  _buildSettingsItem(
                    icon: Icons.settings_outlined,
                    title: S.of(context).appSettings,
                    subtitle: S.of(context).customizeAppPreferences,
                    onTap: () => showAppSettingsBottomSheet(context),
                    iconColor: Colors.purple,
                  ),
                  const SizedBox(height: 32),

                  // Logout Button
                  Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Theme.of(context).colorScheme.error,
                          Theme.of(context)
                              .colorScheme
                              .error
                              .withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => cubit.logOut(context),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.logout_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                S.of(context).signOut, //Đăng xuất
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // void _showUpdateSamplesModal(BuildContext context) {
  //   final scaffoldMessenger = ScaffoldMessenger.of(context);
  //
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  //     ),
  //     builder: (context) => Container(
  //       padding: const EdgeInsets.all(24),
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           const Text(
  //             "Update Sample Data",
  //             style: TextStyle(
  //               fontSize: 24,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           const SizedBox(height: 20),
  //           ListTile(
  //             leading: Container(
  //               padding: const EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: Colors.blue.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: const Icon(Icons.people, color: Colors.blue),
  //             ),
  //             title: const Text("Update Customer Samples"),
  //             subtitle: const Text("Push sample customer data to Firestore"),
  //             onTap: () async {
  //               Navigator.pop(context);
  //               try {
  //                 await Firebase().pushCustomerSampleData();
  //                 scaffoldMessenger.showSnackBar(
  //                   const SnackBar(content: Text("Customer samples updated successfully")),
  //                 );
  //               } catch (e) {
  //                 scaffoldMessenger.showSnackBar(
  //                   SnackBar(content: Text("Error: ${e.toString()}")),
  //                 );
  //               }
  //             },
  //           ),
  //           const SizedBox(height: 12),
  //           ListTile(
  //             leading: Container(
  //               padding: const EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: Colors.green.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: const Icon(Icons.inventory, color: Colors.green),
  //             ),
  //             title: const Text("Update Product Samples"),
  //             subtitle: const Text("Push sample product data to Firestore"),
  //             onTap: () async {
  //               Navigator.pop(context);
  //               try {
  //                 await pushProductSamplesToFirebase();
  //                 scaffoldMessenger.showSnackBar(
  //                   const SnackBar(content: Text("Product samples updated successfully")),
  //                 );
  //               } catch (e) {
  //                 scaffoldMessenger.showSnackBar(
  //                   SnackBar(content: Text("Error: ${e.toString()}")),
  //                 );
  //               }
  //             },
  //           ),
  //           const SizedBox(height: 12),
  //           ListTile(
  //             leading: Container(
  //               padding: const EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: Colors.orange.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: const Icon(Icons.location_on, color: Colors.orange),
  //             ),
  //             title: const Text("Update Address Samples"),
  //             subtitle: const Text("Push sample address data to Firestore"),
  //             onTap: () async {
  //               Navigator.pop(context);
  //               try {
  //                 await pushAddressSamplesToFirebase();
  //                 scaffoldMessenger.showSnackBar(
  //                   const SnackBar(content: Text("Address samples updated successfully")),
  //                 );
  //               } catch (e) {
  //                 scaffoldMessenger.showSnackBar(
  //                   SnackBar(content: Text("Error: ${e.toString()}")),
  //                 );
  //               }
  //             },
  //           ),
  //           const SizedBox(height: 12),
  //           ListTile(
  //             leading: Container(
  //               padding: const EdgeInsets.all(8),
  //               decoration: BoxDecoration(
  //                 color: Colors.purple.withOpacity(0.1),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: const Icon(Icons.receipt_long, color: Colors.purple),
  //             ),
  //             title: const Text("Update Sales Invoice Samples"),
  //             subtitle: const Text("Push sample sales invoice data to Firestore"),
  //             onTap: () async {
  //               Navigator.pop(context);
  //               try {
  //                 await pushSalesInvoiceSampleData();
  //                 scaffoldMessenger.showSnackBar(
  //                   const SnackBar(content: Text("Sales invoice samples updated successfully")),
  //                 );
  //               } catch (e) {
  //                 scaffoldMessenger.showSnackBar(
  //                   SnackBar(content: Text("Error: ${e.toString()}")),
  //                 );
  //               }
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildStatItem({
  //   required IconData icon,
  //   required String label,
  //   required String value,
  // }) {
  //   return Column(
  //     children: [
  //       Icon(
  //         icon,
  //         color: Colors.white,
  //         size: 24,
  //       ),
  //       const SizedBox(height: 8),
  //       Text(
  //         value,
  //         style: const TextStyle(
  //           color: Colors.white,
  //           fontSize: 20,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //       const SizedBox(height: 4),
  //       Text(
  //         label,
  //         style: TextStyle(
  //           color: Colors.white.withOpacity(0.8),
  //           fontSize: 14,
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showEditProfileBottomSheet(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.of(context).editProfile,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  label: Text(
                    S.of(context).username,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6), 
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null && usernameController.text.isNotEmpty) {
                      await Firebase().updateUserProfile(
                        user.uid,
                        usernameController.text,
                      );
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => InformationDialog(
                          title: S.of(context).updateProfileSuccess,
                          content: S.of(context).updateProfileSuccess,
                          buttonText: S.of(context).saveChanges,
                        ),
                      );
                    }
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => InformationDialog(
                        title: S.of(context).errorWithMessage(e.toString()),
                        content: S.of(context).errorWithMessage(e.toString()),
                        buttonText: S.of(context).saveChanges,
                      ),
                    );
                  }
                },
                child: Text(S.of(context).saveChanges),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void showChangePasswordBottomSheet(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      showDialog(
        context: context,
        builder: (context) => InformationDialog(
          title: S.of(context).noUserSignedIn,
          content: S.of(context).noUserSignedIn,
          buttonText: S.of(context).saveChanges,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                S.of(context).changePassword,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                S.of(context).passwordResetEmailWillBeSent(user.email ?? ''),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: user.email!,
                    );

                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => InformationDialog(
                        title: S.of(context).passwordResetEmailSentSuccess,
                        content: S.of(context).passwordResetEmailSentSuccess,
                        buttonText: S.of(context).saveChanges,
                      ),
                    );
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (context) => InformationDialog(
                        title: S.of(context).errorWithMessage(e.toString()),
                        content: S.of(context).errorWithMessage(e.toString()),
                        buttonText: S.of(context).saveChanges,
                      ),
                    );
                  }
                },
                child: Text(S.of(context).sendPasswordResetEmail),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void showAppSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const AppSettingsContent(),
    );
  }
}

class AppSettingsContent extends StatelessWidget {
  const AppSettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).appSettings,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return _buildAppSettingItem(
                  context: context,
                  icon: Icons.dark_mode_outlined,
                  title: S.of(context).themeMode,
                  subtitle: S.of(context).switchBetweenLightAndDark,
                  trailing: Switch(
                    value: themeProvider.isDarkMode,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            Consumer<LocaleProvider>(
              builder: (context, localeProvider, child) {
                return _buildAppSettingItem(
                  context: context,
                  icon: Icons.language_outlined,
                  title: S.of(context).language,
                  subtitle: S.of(context).changeAppLanguage,
                  trailing: DropdownButton<String>(
                    value: localeProvider.currentLanguage,
                    items: [
                      DropdownMenuItem(
                        value: 'en',
                        child: Text(S.of(context).english),
                      ),
                      DropdownMenuItem(
                        value: 'vi',
                        child: Text(S.of(context).vietnamese),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        localeProvider.setLocale(Locale(value));
                      }
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6), 
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
