import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/phone_input_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/profile_setup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/discover_screen.dart';
import '../screens/home/chats_list_screen.dart';
import '../screens/home/profile_screen.dart';
import '../screens/home/host_ride_screen.dart';
import '../screens/home/ride_details_screen.dart';
import '../screens/home/my_rides_screen.dart';
import '../screens/home/ride_history_screen.dart';
import '../screens/home/chat_screen.dart';
import '../screens/home/notifications_screen.dart';
import '../screens/home/settings_screen.dart';
import '../screens/home/edit_profile_screen.dart';
import '../screens/home/rating_screen.dart';
import '../screens/home/active_ride_screen.dart';
import '../screens/home/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isOnboardingComplete = !authState.isNewUser;
      final isSplash = state.matchedLocation == '/';
      final isAuthRoute =
          state.matchedLocation.startsWith('/phone-input') ||
          state.matchedLocation.startsWith('/otp-verification') ||
          state.matchedLocation.startsWith('/profile-setup');

      // If loading, don't redirect
      if (authState.isLoading && isSplash) return null;

      // If not authenticated and not on auth route, go to phone input
      if (!isAuthenticated && !isAuthRoute && !isSplash) {
        return '/phone-input';
      }

      // If authenticated but not onboarded, go to profile setup
      if (isAuthenticated && !isOnboardingComplete && !isSplash) {
        if (state.matchedLocation != '/profile-setup') {
          return '/profile-setup';
        }
      }

      // If authenticated and onboarded, don't allow auth routes
      if (isAuthenticated && isOnboardingComplete && isAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash route
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),

      // Auth routes
      GoRoute(
        path: '/phone-input',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PhoneInputScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            OtpVerificationScreen(phone: state.extra as String),
      ),
      GoRoute(
        path: '/profile-setup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileSetupScreen(),
      ),

      // Main app shell with bottom nav
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // Home tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Discover tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoverScreen(),
              ),
            ],
          ),
          // Chats tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chats',
                builder: (context, state) => const ChatsListScreen(),
              ),
            ],
          ),
          // Profile tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Detail routes (outside shell, full screen)
      GoRoute(
        path: '/host-ride',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HostRideScreen(),
      ),
      GoRoute(
        path: '/ride-details/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            RideDetailsScreen(pingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/my-rides',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const MyRidesScreen(),
      ),
      GoRoute(
        path: '/ride-history',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RideHistoryScreen(),
      ),
      GoRoute(
        path: '/chat/:matchId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            ChatScreen(matchId: state.pathParameters['matchId']!),
      ),
      GoRoute(
        path: '/notifications',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/edit-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/rating/:matchId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            RatingScreen(matchId: state.pathParameters['matchId']!),
      ),
      GoRoute(
        path: '/active-ride/:matchId',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            ActiveRideScreen(matchId: state.pathParameters['matchId']!),
      ),
    ],
  );
});

// Splash screen kept in router file for organization
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await ref.read(authProvider.notifier).checkAuthStatus();
    // GoRouter redirect will handle navigation
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.directions_car_filled,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'LetzGo',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 32),
            CircularProgressIndicator(color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }
}
