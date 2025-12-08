import 'package:gizmoglobe_client/utils/platform_specific_utils.dart';
import 'dart:async';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
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
import 'package:gizmoglobe_client/screens/invoice/invoice_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/stakeholder/stakeholder_screen_view.dart';
import 'package:gizmoglobe_client/screens/stakeholder/stakeholder_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/voucher/list/voucher_screen_view.dart';
import 'package:gizmoglobe_client/screens/voucher/list/voucher_screen_webview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:gizmoglobe_client/screens/product/product_screen/product_screen_view.dart';
import 'package:gizmoglobe_client/components/general/web_sidebar.dart';
import 'package:gizmoglobe_client/components/general/web_header.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_webview.dart';
import 'package:gizmoglobe_client/objects/product_related/product.dart';
import 'package:gizmoglobe_client/data/firebase/firebase.dart'
    as FirebaseService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling for web
  if (kIsWeb) {
    // Use native hash-based navigation for Flutter web
    setUrlStrategy(const HashUrlStrategy());
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
                if (!supportedLocales.contains(locale)) {
                  return const Locale('vi');
                }
                return locale;
              },
              builder: (context, child) {
                return child!;
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
                '/stakeholders/customers': (context) =>
                    const StakeholderRouteHandler(),
                '/stakeholders/employees': (context) =>
                    const StakeholderRouteHandler(),
                '/stakeholders/vendors': (context) =>
                    const StakeholderRouteHandler(),
                '/vouchers': (context) => const VoucherRouteHandler(),
              },
              onGenerateRoute: (settings) {
                // Robust route handling for both query params and hash-like nested paths
                final name = settings.name ?? '/';
                final uri = Uri.parse(name);
                final path = uri.path;

                // Normalize common nested web paths to their base handlers
                String normalized = path;
                if (path.startsWith('/invoices')) {
                  normalized = '/invoices';
                } else if (path.startsWith('/vouchers')) {
                  normalized = '/vouchers';
                } else if (path.startsWith('/stakeholders')) {
                  normalized = '/stakeholders';
                }

                return MaterialPageRoute(
                  settings: RouteSettings(
                    name: normalized,
                    arguments: settings.arguments,
                  ),
                  builder: (context) {
                    switch (normalized) {
                      case '/invoices':
                        return const InvoiceRouteHandler();
                      case '/product':
                        return const ProductRouteHandler();
                      case '/chat':
                        return const ChatRouteHandler();
                      case '/stakeholders':
                      case '/stakeholders/customers':
                      case '/stakeholders/employees':
                      case '/stakeholders/vendors':
                        return const StakeholderRouteHandler();
                      case '/vouchers':
                        return const VoucherRouteHandler();
                      case '/main':
                        return const MainRouteHandler();
                      case '/sign-in':
                        return SignInScreen.newInstance();
                      case '/sign-up':
                        return SignUpScreen.newInstance();
                      case '/forget-password':
                        return ForgetPasswordScreen.newInstance();
                      default:
                        return const AuthWrapper();
                    }
                  },
                );
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
        } else if ((currentRoute == '/stakeholders' ||
                currentRoute == '/stakeholders/customers' ||
                currentRoute == '/stakeholders/employees' ||
                currentRoute == '/stakeholders/vendors') &&
            isAuthenticated) {
          return const StakeholderRouteHandler();
        } else if (currentRoute == '/vouchers' && isAuthenticated) {
          return const VoucherRouteHandler();
        } else if (kIsWeb && isAuthenticated) {
          // Handle deep links via hash for web: /#/product and nested paths
          final uri = Uri.parse(PlatformSpecificUtils.getCurrentUrl());
          final hash = uri.fragment;
          if (hash.startsWith('/product')) {
            return const ProductRouteHandler();
          }
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
      final uri = Uri.parse(PlatformSpecificUtils.getCurrentUrl());
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
  StreamSubscription<dynamic>? _hashChangeSubscription;

  @override
  void initState() {
    super.initState();
    _parseUrlParameters();

    // Listen to URL changes on web
    if (kIsWeb) {
      _hashChangeSubscription =
          PlatformSpecificUtils.onHashChange.listen((event) {
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
      final uri = Uri.parse(PlatformSpecificUtils.getCurrentUrl());
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

// Invoice route handler for /#/invoices and /#/invoices/{sales|incoming|warranty}
class InvoiceRouteHandler extends StatefulWidget {
  const InvoiceRouteHandler({super.key});

  @override
  State<InvoiceRouteHandler> createState() => _InvoiceRouteHandlerState();
}

class _InvoiceRouteHandlerState extends State<InvoiceRouteHandler> {
  int? initialTabIndex;
  StreamSubscription<dynamic>? _hashChangeSubscription;

  @override
  void initState() {
    super.initState();
    _parseUrlParameters();

    // Listen to URL changes on web
    if (kIsWeb) {
      _hashChangeSubscription =
          PlatformSpecificUtils.onHashChange.listen((event) {
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
      // Parse hash for web routing
      final uri = Uri.parse(PlatformSpecificUtils.getCurrentUrl());
      final hash = uri.fragment;

      // Expected formats:
      //  - /#/invoices
      //  - /#/invoices/{sales|incoming|warranty}
      if (hash.startsWith('/invoices')) {
        final pathSegments = hash.split('/');
        if (pathSegments.length >= 3 && pathSegments[2].isNotEmpty) {
          final tabName = pathSegments[2].toLowerCase();
          switch (tabName) {
            case 'sales':
              initialTabIndex = 0;
              break;
            case 'incoming':
              initialTabIndex = 1;
              break;
            case 'warranty':
              initialTabIndex = 2;
              break;
            default:
              initialTabIndex = null; // Don't reset if invalid tab name
          }
        } else {
          initialTabIndex =
              null; // Don't reset if no tab specified - preserve current state
        }
      } else {
        initialTabIndex = null; // Don't reset if not on invoices route
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

    // If no tab specified but we have a preserved tab, update URL to reflect it
    if (kIsWeb && initialTabIndex == null) {
      final preservedTabIndex = InvoiceScreenCubit.lastSelectedTabIndex;
      String tabName;
      switch (preservedTabIndex) {
        case 0:
          tabName = 'sales';
          break;
        case 1:
          tabName = 'incoming';
          break;
        case 2:
          tabName = 'warranty';
          break;
        default:
          tabName = 'sales';
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PlatformSpecificUtils.replaceState('/#/invoices/$tabName');
      });
    }

    // Return invoice screen with optional initial tab index
    return InvoiceScreen.newInstanceWithTab(initialTabIndex: initialTabIndex);
  }
}

// Stakeholder route handler for /#/stakeholders, /#/stakeholders/customers, /#/stakeholders/employees, /#/stakeholders/vendors
class StakeholderRouteHandler extends StatefulWidget {
  const StakeholderRouteHandler({super.key});

  @override
  State<StakeholderRouteHandler> createState() =>
      _StakeholderRouteHandlerState();
}

class _StakeholderRouteHandlerState extends State<StakeholderRouteHandler> {
  int? initialTabIndex;
  StreamSubscription<dynamic>? _hashChangeSubscription;

  @override
  void initState() {
    super.initState();
    _parseUrlParameters();

    // Listen to URL changes on web
    if (kIsWeb) {
      _hashChangeSubscription =
          PlatformSpecificUtils.onHashChange.listen((event) {
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
      // Parse hash for web routing
      final uri = Uri.parse(PlatformSpecificUtils.getCurrentUrl());
      final hash = uri.fragment;

      // Parse hash like /#/stakeholders/customers, /#/stakeholders/employees, /#/stakeholders/vendors
      if (hash.startsWith('/stakeholders')) {
        final pathSegments = hash.split('/');
        if (pathSegments.length >= 3 && pathSegments[2].isNotEmpty) {
          final tabName = pathSegments[2].toLowerCase();
          switch (tabName) {
            case 'customers':
              initialTabIndex = 0;
              break;
            case 'employees':
              initialTabIndex = 1;
              break;
            case 'vendors':
              initialTabIndex = 2;
              break;
            default:
              initialTabIndex = null; // Don't reset if invalid tab name
          }
        } else {
          initialTabIndex =
              null; // Don't reset if no tab specified - preserve current state
        }
      } else {
        initialTabIndex = null; // Don't reset if not on stakeholders route
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

    // If no tab specified but we have a preserved tab, update URL to reflect it
    if (kIsWeb && initialTabIndex == null) {
      final preservedTabIndex = StakeholderScreenCubit.lastSelectedTabIndex;
      String tabName;
      switch (preservedTabIndex) {
        case 0:
          tabName = 'customers';
          break;
        case 1:
          tabName = 'employees';
          break;
        case 2:
          tabName = 'vendors';
          break;
        default:
          tabName = 'customers';
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PlatformSpecificUtils.replaceState('/#/stakeholders/$tabName');
      });
    }

    // Return stakeholder screen with optional initial tab index
    return StakeholderScreen.newInstanceWithTab(
        initialTabIndex: initialTabIndex);
  }
}

// Voucher route handler for /#/vouchers and /#/vouchers/{all|ongoing|upcoming|inactive}
class VoucherRouteHandler extends StatefulWidget {
  const VoucherRouteHandler({super.key});

  @override
  State<VoucherRouteHandler> createState() => _VoucherRouteHandlerState();
}

class _VoucherRouteHandlerState extends State<VoucherRouteHandler> {
  int? initialTabIndex;
  StreamSubscription<dynamic>? _hashChangeSubscription;

  @override
  void initState() {
    super.initState();
    _parseUrlParameters();

    // Listen to URL changes on web
    if (kIsWeb) {
      _hashChangeSubscription =
          PlatformSpecificUtils.onHashChange.listen((event) {
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
      // Parse hash for web routing
      final uri = Uri.parse(PlatformSpecificUtils.getCurrentUrl());
      final hash = uri.fragment;

      // Expected formats:
      //  - /#/vouchers
      //  - /#/vouchers/{all|ongoing|upcoming|inactive}
      if (hash.startsWith('/vouchers')) {
        final pathSegments = hash.split('/');
        if (pathSegments.length >= 3 && pathSegments[2].isNotEmpty) {
          final tabName = pathSegments[2].toLowerCase();
          switch (tabName) {
            case 'all':
              initialTabIndex = 0;
              break;
            case 'ongoing':
              initialTabIndex = 1;
              break;
            case 'upcoming':
              initialTabIndex = 2;
              break;
            case 'inactive':
              initialTabIndex = 3;
              break;
            default:
              initialTabIndex = null; // Don't reset if invalid tab name
          }
        } else {
          initialTabIndex =
              null; // Don't reset if no tab specified - preserve current state
        }
      } else {
        initialTabIndex = null; // Don't reset if not on vouchers route
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

    // If no tab specified but we have a preserved tab, update URL to reflect it
    if (kIsWeb && initialTabIndex == null) {
      final preservedTabIndex = VoucherScreenWebView.lastSelectedTabIndex;
      String tabName;
      switch (preservedTabIndex) {
        case 0:
          tabName = 'all';
          break;
        case 1:
          tabName = 'ongoing';
          break;
        case 2:
          tabName = 'upcoming';
          break;
        case 3:
          tabName = 'inactive';
          break;
        default:
          tabName = 'all';
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PlatformSpecificUtils.replaceState('/#/vouchers/$tabName');
      });
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

// Product route handler for /#/product and /#/product/{all|ram|cpu|psu|gpu|drive|mainboard}
class ProductRouteHandler extends StatefulWidget {
  const ProductRouteHandler({super.key});

  @override
  State<ProductRouteHandler> createState() => _ProductRouteHandlerState();
}

class _ProductRouteHandlerState extends State<ProductRouteHandler> {
  int? initialTabIndex;
  StreamSubscription<dynamic>? _hashChangeSubscription;
  String? selectedProductId;
  Product? selectedProduct;
  Future<Product?>? _productFuture;

  @override
  void initState() {
    super.initState();
    _parseUrlParameters();

    if (kIsWeb) {
      _hashChangeSubscription =
          PlatformSpecificUtils.onHashChange.listen((event) {
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
      final uri = Uri.parse(PlatformSpecificUtils.getCurrentUrl());
      final hash = uri.fragment;

      // Expected: /#/product or /#/product/{tab}
      if (hash.startsWith('/product')) {
        final segments = hash.split('/');
        String tab = segments.length >= 3 ? segments[2].toLowerCase() : 'all';
        selectedProductId =
            segments.length >= 4 && segments[3].isNotEmpty ? segments[3] : null;
        switch (tab) {
          case 'all':
            initialTabIndex = 0;
            break;
          case 'ram':
            initialTabIndex = 1;
            break;
          case 'cpu':
            initialTabIndex = 2;
            break;
          case 'psu':
            initialTabIndex = 3;
            break;
          case 'gpu':
            initialTabIndex = 4;
            break;
          case 'drive':
            initialTabIndex = 5;
            break;
          case 'mainboard':
            initialTabIndex = 6;
            break;
          default:
            initialTabIndex = 0;
            break;
        }

        // Resolve product if present
        if (selectedProductId != null) {
          try {
            selectedProduct = Database()
                .productList
                .firstWhere((p) => p.productID == selectedProductId);
            _productFuture = null; // Product found locally
          } catch (_) {
            selectedProduct = null;
            // Product not found locally, fetch from Firebase
            _productFuture =
                FirebaseService.Firebase().getProduct(selectedProductId!);
          }
        } else {
          selectedProduct = null;
          _productFuture = null;
        }
      } else {
        initialTabIndex = 0;
        selectedProductId = null;
        selectedProduct = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isAuthenticated = user != null;
    if (!isAuthenticated) {
      return SignInScreen.newInstance();
    }
    if (!kIsWeb) {
      return ProductScreen.newInstanceWithTab(initialTabIndex: initialTabIndex);
    }

    // Late resolve product if ID present but product not yet found
    if (selectedProductId != null &&
        selectedProduct == null &&
        _productFuture == null) {
      try {
        selectedProduct = Database()
            .productList
            .firstWhere((p) => p.productID == selectedProductId);
      } catch (_) {
        // Product not found locally, fetch from Firebase
        _productFuture =
            FirebaseService.Firebase().getProduct(selectedProductId!);
      }
    }

    final items = buildDefaultSidebarItems(
      home: AppLocalizations.of(context).home,
      product: AppLocalizations.of(context).product,
      invoice: AppLocalizations.of(context).invoice,
      stakeholder: AppLocalizations.of(context).stakeholder,
      voucher: AppLocalizations.of(context).voucher,
      profile: AppLocalizations.of(context).profile,
    );

    return Scaffold(
      body: Column(
        children: [
          const WebHeader(
            unreadChats: 0,
            isSidebarCompact: false,
          ),
          Expanded(
            child: Row(
              children: [
                WebSidebarModes(
                  currentIndex: 1, // Product index
                  onItemSelected: (value) {
                    // Navigation handled inside sidebar; no-op here
                  },
                  items: items,
                  onCompactModeChanged: (isCompact) {},
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _productFuture != null
                      ? FutureBuilder<Product?>(
                          future: _productFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(
                                child: CircularProgressIndicator(
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              );
                            }
                            if (snapshot.hasData && snapshot.data != null) {
                              // Update selectedProduct for future renders
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (mounted) {
                                  setState(() {
                                    selectedProduct = snapshot.data;
                                    _productFuture = null;
                                  });
                                }
                              });
                              return ProductDetailWebView.newInstance(
                                  snapshot.data!);
                            }
                            // Product not found, show product list
                            return ProductScreen.newInstanceWithTab(
                              initialTabIndex: initialTabIndex,
                            );
                          },
                        )
                      : selectedProductId != null && selectedProduct == null
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : selectedProduct != null
                              ? ProductDetailWebView.newInstance(
                                  selectedProduct!)
                              : ProductScreen.newInstanceWithTab(
                                  initialTabIndex: initialTabIndex,
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
