import 'package:firebase_ui_auth/firebase_ui_auth.dart'; // new
import 'package:flutter/material.dart';
import 'package:medication_management_module/services/notifications_service.dart';
import 'package:my_flutter_app/screens/user_profile_screen.dart';
import 'package:go_router/go_router.dart'; // new
import 'package:provider/provider.dart'; // Import provider for state management

import 'app_state.dart'; // Import the app state management
import 'home_page.dart'; // Import the home page
import 'screens/todays_meds.dart'; // Import todays medications
import 'screens/med_manage.dart';
import 'src/theme.dart';

/// Application entry point
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service
  await NotificationService().init();

  // Run the app
  // runApp(const MyApp());
  runApp(
    ChangeNotifierProvider(
      create: (context) => ApplicationState(),
      builder: ((context, child) => const MyApp()),
    ),
  ); // Wraps the app with a provider for state management
}

// /// Root widget that configures the application theme and initial route
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Medication Tracker',
      theme: ThemeData(
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: AppColors.deepBlues,
            decoration: TextDecoration.underline,
            decorationColor: AppColors.deepBlues,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18.0,
            color: AppColors.deepBlues,
          ),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.deepBlues),
        useMaterial3: true,
      ),
      routerConfig: _router,
      //       home: const MyHomePage(title: 'Medication Tracker'),
    );
  }
}

//configure "go_router" for navigation through pre-made login flow
final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const TodaysMeds(title: 'Medications'),
      routes: [
        GoRoute(
          path: 'sign-in',
          builder: (context, state) {
            return SignInScreen(
              headerBuilder: (context, constraints, header) {
                return Container(
                  height: 200,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/medreminder.jpg'),
                    ),
                  ),
                );
              },
              actions: [
                ForgotPasswordAction(((context, email) {
                  final uri = Uri(
                    path: '/sign-in/forgot-password',
                    queryParameters: <String, String?>{'email': email},
                  );
                  context.push(uri.toString());
                })),
                AuthStateChangeAction(((context, state) {
                  final user = switch (state) {
                    SignedIn state => state.user,
                    UserCreated state => state.credential.user,
                    _ => null,
                  };
                  if (user == null) {
                    return;
                  }
                  if (state is UserCreated) {
                    user.updateDisplayName(user.email!.split('@')[0]);
                  }
                  // if (!user.emailVerified) {
                  //   user.sendEmailVerification();
                  //   const snackBar = SnackBar(
                  //       content: Text(
                  //           'Please check your email to verify your email address'));
                  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  // }
                  context.pushReplacement('/');
                })),
              ],
            );
          },
          routes: [
            GoRoute(
              path: 'forgot-password',
              builder: (context, state) {
                final arguments = state.uri.queryParameters;
                return ForgotPasswordScreen(
                  email: arguments['email'],
                  headerMaxExtent: 200,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) {
            return ProfileScreen(
              providers: const [],
              actions: [
                SignedOutAction((context) {
                  context.pushReplacement('/');
                }),
              ],
            );
          },
        ),
      ],
    ),
    GoRoute(
      path: '/screens/user_profile_screen',
      builder: (context, state) => UserProfileScreen(),
    ),
    GoRoute(
      path: '/screens/med_manage',
      builder: (context, state) => MedManage(title: 'Medications'),
    ),
    GoRoute(
      path: '/screens/todays_meds',
      builder: (context, state) => TodaysMeds(title: 'Todays Medications'),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
  ],
);
