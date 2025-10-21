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
import 'package:gizmoglobe_client/generated/l10n.dart';
import 'package:gizmoglobe_client/presentation/resources/app_theme.dart';
import 'package:gizmoglobe_client/providers/locale_provider.dart';
import 'package:gizmoglobe_client/providers/theme_provider.dart';
import 'package:gizmoglobe_client/screens/authentication/forget_password_screen/forget_password_view.dart';
import 'package:gizmoglobe_client/screens/authentication/sign_in_screen/sign_in_view.dart';
import 'package:gizmoglobe_client/screens/authentication/sign_up_screen/sign_up_view.dart';
import 'package:gizmoglobe_client/screens/main/drawer/drawer_cubit.dart';
import 'package:gizmoglobe_client/screens/main/main_screen/main_screen_cubit.dart';
import 'package:gizmoglobe_client/screens/main/main_screen/main_screen_view.dart';
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
                S.delegate,
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
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              routes: {
                '/sign-in': (context) => SignInScreen.newInstance(),
                '/sign-up': (context) => SignUpScreen.newInstance(),
                '/forget-password': (context) =>
                    ForgetPasswordScreen.newInstance(),
                '/main': (context) => const MainScreen(),
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

        // If we're on the sign-up screen, don't redirect
        if (currentRoute == '/sign-up') {
          return SignUpScreen.newInstance();
        } else if (snapshot.hasData) {
          return const MainScreen();
        }

        // For all other cases, show sign in screen
        return SignInScreen.newInstance();
      },
    );
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
