import 'dart:html' as html show window, Event;
import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gizmoglobe_client/data/database/database.dart';
import 'package:gizmoglobe_client/firebase_options.dart';
import 'package:gizmoglobe_client/localization/app_localization.dart';
import 'package:gizmoglobe_client/presentation/resources/app_theme.dart';
import 'package:gizmoglobe_client/providers/locale_provider.dart';
import 'package:gizmoglobe_client/providers/theme_provider.dart';
import 'package:gizmoglobe_client/screens/authentication/forget_password_screen/forget_password_view.dart';
import 'package:gizmoglobe_client/screens/authentication/sign_in_screen/sign_in_view.dart';
import 'package:gizmoglobe_client/screens/authentication/sign_up_screen/sign_up_view.dart';
import 'package:gizmoglobe_client/screens/main/drawer/drawer_cubit.dart';
import 'package:gizmoglobe_client/screens/main/main_screen/main_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/main/main_screen/main_screen_view.dart';
import 'package:gizmoglobe_client/screens/chat/list/chat_list_screen_view.dart';
import 'package:gizmoglobe_client/screens/invoice/invoice_screen_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/stakeholder_screen_view.dart';
import 'package:gizmoglobe_client/screens/voucher/list/voucher_screen_view.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling for web
  if (kIsWeb) {
    // Set up error handling for web platform
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        print('Flutter Error: ${details.exception}');
        print('Stack trace: ${details.stack}');
      }
    };
  }

  await dotenv.load(fileName: ".env");
  await _setup();
  try {
    // Initialize Firebase with error handling
    if (kIsWeb) {
      // For web, try to initialize with a more robust approach
      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (webInitError) {
        if (kDebugMode) {
          print('Web Firebase init failed, trying fallback: $webInitError');
        }
        // Try without options as fallback
        await Firebase.initializeApp();
      }
    } else {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    // Only initialize App Check on mobile platforms
    if (!kIsWeb) {
      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider: kDebugMode
              ? AndroidProvider.debug
              : AndroidProvider.playIntegrity,
          appleProvider: AppleProvider.deviceCheck,
        );
        FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
      } catch (appCheckError) {
        if (kDebugMode) {
          print('App Check initialization failed: $appCheckError');
        }
        // Continue without App Check if it fails
      }
    }

    // Initialize database with error handling
    try {
      await Database().initialize();
    } catch (dbError) {
      if (kDebugMode) {
        print('Database initialization failed: $dbError');
      }
      // Continue without database if it fails
    }

    // Request permissions only on mobile
    if (!kIsWeb) {
      try {
        await Permission.camera.request();
        await Permission.photos.request();
      } catch (permissionError) {
        if (kDebugMode) {
          print('Permission request failed: $permissionError');
        }
      }
    }

    runApp(const ErrorBoundary(child: MyApp()));
  } catch (e) {
    if (kDebugMode) {
      print('Firebase initialization error: $e');
    }
    // Show error screen with more details
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Firebase Initialization Failed',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Error: $e',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Reload the page
                  if (kIsWeb) {
                    // ignore: avoid_web_libraries_in_flutter
                    // html.window.location.reload();
                  }
                },
                child: const Text('Reload Page'),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
}

// Page transition builder that disables animations (used for web)
class NoAnimationPageTransitionsBuilder extends PageTransitionsBuilder {
  const NoAnimationPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ],
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          if (kDebugMode) {
            print('Current locale: \\${localeProvider.locale}');
            print('Supported locales: \\${[
              const Locale('en'),
              const Locale('vi')
            ]}');
          }
          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (context) => MainScreenCubit()),
              BlocProvider(create: (context) => DrawerCubit()),
            ],
            child: MaterialApp(
              title: 'GizmoGlobe',
              themeMode: themeProvider.themeMode,
              locale: localeProvider.locale,
              supportedLocales: const [
                Locale('en'),
                Locale('vi'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              localeResolutionCallback: (locale, supportedLocales) {
                if (kDebugMode) {
                  print('Locale resolution callback called');
                  print('Requested locale: \\$locale');
                  print('Supported locales: \\$supportedLocales');
                }
                if (!supportedLocales.contains(locale)) {
                  if (kDebugMode) {
                    print('Locale not supported, returning Vietnamese');
                  }
                  return const Locale('vi');
                }
                return locale;
              },
              builder: (context, child) {
                if (kDebugMode) {
                  print('MaterialApp builder called');
                  print(
                      'Current locale in builder: \\${Localizations.localeOf(context)}');
                }
                return Localizations.override(
                  context: context,
                  locale: localeProvider.locale,
                  child: child!,
                );
              },
              theme: kIsWeb
                  ? AppTheme.lightTheme.copyWith(
                      pageTransitionsTheme: const PageTransitionsTheme(
                        builders: {
                          TargetPlatform.android:
                              NoAnimationPageTransitionsBuilder(),
                          TargetPlatform.iOS:
                              NoAnimationPageTransitionsBuilder(),
                          TargetPlatform.linux:
                              NoAnimationPageTransitionsBuilder(),
                          TargetPlatform.macOS:
                              NoAnimationPageTransitionsBuilder(),
                          TargetPlatform.windows:
                              NoAnimationPageTransitionsBuilder(),
                        },
                      ),
                    )
                  : AppTheme.lightTheme,
              darkTheme: kIsWeb
                  ? AppTheme.darkTheme.copyWith(
                      pageTransitionsTheme: const PageTransitionsTheme(
                        builders: {
                          TargetPlatform.android:
                              NoAnimationPageTransitionsBuilder(),
                          TargetPlatform.iOS:
                              NoAnimationPageTransitionsBuilder(),
                          TargetPlatform.linux:
                              NoAnimationPageTransitionsBuilder(),
                          TargetPlatform.macOS:
                              NoAnimationPageTransitionsBuilder(),
                          TargetPlatform.windows:
                              NoAnimationPageTransitionsBuilder(),
                        },
                      ),
                    )
                  : AppTheme.darkTheme,
              routes: {
                '/sign-in': (context) => SignInScreen.newInstance(),
                '/sign-up': (context) => SignUpScreen.newInstance(),
                '/forget-password': (context) =>
                    ForgetPasswordScreen.newInstance(),
                '/main': (context) => const MainRouteHandler(),
                '/chat': (context) => const ChatRouteHandler(),
                '/invoices': (context) => const InvoiceRouteHandler(),
                '/stakeholders': (context) => const StakeholderRouteHandler(),
                '/vouchers': (context) => const VoucherRouteHandler(),
              },
              home: const AuthWrapper(),
            ),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Get the current route name
        final currentRoute = ModalRoute.of(context)?.settings.name;
        final user = snapshot.data;
        final isAuthenticated =
            user != null; // More robust check: user must not be null

        // ABSOLUTE WEB SECURITY: If on web and not authenticated, BLOCK EVERYTHING
        if (kIsWeb && !isAuthenticated) {
          return SignInScreen.newInstance();
        }

        // CRITICAL WEB SECURITY: Check authentication FIRST, before any other logic
        // This prevents any bypass attempts on web platform
        if (kIsWeb) {
          // Block access if user is null, has no UID, or authentication is false
          if (user == null || user.uid.isEmpty || !isAuthenticated) {
            return SignInScreen.newInstance();
          }

          // Additional security: Ensure user has valid email
          if (user.email == null || user.email!.isEmpty) {
            return SignInScreen.newInstance();
          }
        }

        // Define protected routes that require authentication
        const protectedRoutes = ['/main', '/chat'];

        // Define public routes that don't require authentication
        const publicRoutes = ['/sign-in', '/sign-up', '/forget-password'];

        // If trying to access a protected route without authentication
        if (protectedRoutes.contains(currentRoute) && !isAuthenticated) {
          // Redirect to sign-in screen
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/sign-in');
          });
          return SignInScreen.newInstance();
        }

        // If authenticated and trying to access public auth routes, redirect to main
        if (isAuthenticated && publicRoutes.contains(currentRoute)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(context, '/main');
          });
          return const MainScreen();
        }

        // Handle specific route logic
        if (currentRoute == '/sign-up') {
          return SignUpScreen.newInstance();
        } else if (currentRoute == '/forget-password') {
          return ForgetPasswordScreen.newInstance();
        } else if (currentRoute == '/main' && isAuthenticated) {
          return const MainScreen();
        } else if (currentRoute == '/chat' && isAuthenticated) {
          return const ChatRouteHandler();
        } else if (currentRoute == '/invoices' && isAuthenticated) {
          return const InvoiceRouteHandler();
        } else if (currentRoute == '/stakeholders' && isAuthenticated) {
          return const StakeholderRouteHandler();
        } else if (currentRoute == '/vouchers' && isAuthenticated) {
          return const VoucherRouteHandler();
        } else if (currentRoute == '/sign-in') {
          return SignInScreen.newInstance();
        }

        // ABSOLUTE FINAL WEB SECURITY: Last chance to block web access
        if (kIsWeb && !isAuthenticated) {
          return SignInScreen.newInstance();
        }

        // Default behavior based on authentication status
        if (isAuthenticated) {
          return const MainScreen();
        } else {
          return SignInScreen.newInstance();
        }
      },
    );
  }
}

// Chat route handler for /#/chat and /#/chat?id=chat-document-id
class ChatRouteHandler extends StatefulWidget {
  const ChatRouteHandler({super.key});

  @override
  State<ChatRouteHandler> createState() => _ChatRouteHandlerState();
}

class _ChatRouteHandlerState extends State<ChatRouteHandler> {
  String? selectedChatId;

  @override
  void initState() {
    super.initState();
    _parseUrlParameters();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _parseUrlParameters() {
    if (kIsWeb) {
      // Parse URL parameters for web
      final uri = Uri.parse(html.window.location.href);
      selectedChatId = uri.queryParameters['id'];
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = user != null;

    if (!isAuthenticated) {
      return SignInScreen.newInstance();
    }

    // Return chat list screen with optional selected chat
    return ChatListScreen.newInstance(selectedChatId: selectedChatId);
  }
}

// Error boundary widget to catch and handle errors gracefully
class ErrorBoundary extends StatelessWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          return child;
        } catch (error, stackTrace) {
          if (kDebugMode) {
            print('Error caught by ErrorBoundary: $error');
            print('Stack trace: $stackTrace');
          }

          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Something went wrong',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please refresh the page or try again later.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Reload the page on web
                        if (kIsWeb) {
                          // ignore: avoid_web_libraries_in_flutter
                          // html.window.location.reload();
                        }
                      },
                      child: const Text('Reload'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

// Main route handler for /#/main and /#/main?index=section-index
class MainRouteHandler extends StatefulWidget {
  const MainRouteHandler({super.key});

  @override
  State<MainRouteHandler> createState() => _MainRouteHandlerState();
}

class _MainRouteHandlerState extends State<MainRouteHandler> {
  int? initialIndex;
  StreamSubscription<html.Event>? _hashChangeSubscription;

  @override
  void initState() {
    super.initState();
    _parseUrlParameters();

    // Listen to URL changes on web
    if (kIsWeb) {
      _hashChangeSubscription = html.window.onHashChange.listen((event) {
        if (mounted) {
          _parseUrlParameters();
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _hashChangeSubscription?.cancel();
    super.dispose();
  }

  void _parseUrlParameters() {
    if (kIsWeb) {
      // Parse URL parameters for web
      final uri = Uri.parse(html.window.location.href);
      final indexParam = uri.queryParameters['index'];
      if (indexParam != null) {
        initialIndex = int.tryParse(indexParam);
      } else {
        initialIndex = null; // No index specified, use default (home = 0)
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = user != null;

    if (!isAuthenticated) {
      return SignInScreen.newInstance();
    }

    // Return main screen with optional initial index
    return MainScreen(initialIndex: initialIndex);
  }
}

// Invoice route handler for /#/invoices and /#/invoices?tabs=incoming/sales/warranty
class InvoiceRouteHandler extends StatefulWidget {
  const InvoiceRouteHandler({super.key});

  @override
  State<InvoiceRouteHandler> createState() => _InvoiceRouteHandlerState();
}

class _InvoiceRouteHandlerState extends State<InvoiceRouteHandler> {
  int? initialTabIndex;

  @override
  void initState() {
    super.initState();
    _parseUrlParameters();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _parseUrlParameters() {
    if (kIsWeb) {
      // Parse URL parameters for web
      final uri = Uri.parse(html.window.location.href);
      final tabsParam = uri.queryParameters['tabs'];

      if (tabsParam != null) {
        switch (tabsParam.toLowerCase()) {
          case 'incoming':
            initialTabIndex = 1; // Incoming tab index
            break;
          case 'sales':
            initialTabIndex = 0; // Sales tab index
            break;
          case 'warranty':
            initialTabIndex = 2; // Warranty tab index
            break;
          default:
            initialTabIndex = 0; // Default to sales
        }
      } else {
        initialTabIndex = 0; // Default to sales tab if no tab specified
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = user != null;

    if (!isAuthenticated) {
      return SignInScreen.newInstance();
    }

    // Return invoice screen with optional initial tab index
    return InvoiceScreen.newInstanceWithTab(initialTabIndex: initialTabIndex);
  }
}

// Stakeholder route handler for /#/stakeholders and /#/stakeholders?tabs=customers/employees/vendors
class StakeholderRouteHandler extends StatefulWidget {
  const StakeholderRouteHandler({super.key});

  @override
  State<StakeholderRouteHandler> createState() =>
      _StakeholderRouteHandlerState();
}

class _StakeholderRouteHandlerState extends State<StakeholderRouteHandler> {
  int? initialTabIndex;

  @override
  void initState() {
    super.initState();
    _parseUrlParameters();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _parseUrlParameters() {
    if (kIsWeb) {
      // Parse URL parameters for web
      final uri = Uri.parse(html.window.location.href);
      final tabsParam = uri.queryParameters['tabs'];

      if (tabsParam != null) {
        switch (tabsParam.toLowerCase()) {
          case 'customers':
            initialTabIndex = 0; // Customers tab index
            break;
          case 'employees':
            initialTabIndex = 1; // Employees tab index
            break;
          case 'vendors':
            initialTabIndex = 2; // Vendors tab index
            break;
          default:
            initialTabIndex = 0; // Default to customers
        }
      } else {
        initialTabIndex = 0; // Default to customers tab if no tab specified
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = user != null;

    if (!isAuthenticated) {
      return SignInScreen.newInstance();
    }

    // Return stakeholder screen with optional initial tab index
    return StakeholderScreen.newInstanceWithTab(
        initialTabIndex: initialTabIndex);
  }
}

// Voucher route handler for /#/vouchers and /#/vouchers?tabs=all/ongoing/upcoming/inactive
class VoucherRouteHandler extends StatefulWidget {
  const VoucherRouteHandler({super.key});

  @override
  State<VoucherRouteHandler> createState() => _VoucherRouteHandlerState();
}

class _VoucherRouteHandlerState extends State<VoucherRouteHandler> {
  int? initialTabIndex;

  @override
  void initState() {
    super.initState();
    _parseUrlParameters();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _parseUrlParameters() {
    if (kIsWeb) {
      // Parse URL parameters for web
      final uri = Uri.parse(html.window.location.href);
      final tabsParam = uri.queryParameters['tabs'];

      if (tabsParam != null) {
        switch (tabsParam.toLowerCase()) {
          case 'all':
            initialTabIndex = 0; // All tab index
            break;
          case 'ongoing':
            initialTabIndex = 1; // Ongoing tab index
            break;
          case 'upcoming':
            initialTabIndex = 2; // Upcoming tab index
            break;
          case 'inactive':
            initialTabIndex = 3; // Inactive tab index
            break;
          default:
            initialTabIndex = 0; // Default to all
        }
      } else {
        initialTabIndex = 0; // Default to all tab if no tab specified
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check authentication
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = user != null;

    if (!isAuthenticated) {
      return SignInScreen.newInstance();
    }

    // Return voucher screen with optional initial tab index
    try {
      return VoucherScreen.newInstanceWithTab(initialTabIndex: initialTabIndex);
    } catch (e) {
      if (kDebugMode) {
        print('Error creating VoucherScreen: $e');
      }
      // Fallback to basic voucher screen
      return VoucherScreen.newInstance();
    }
  }
}
