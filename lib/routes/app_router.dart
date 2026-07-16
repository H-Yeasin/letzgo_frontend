import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/onboarding_provider.dart';
import '../screens/auth/phone_input_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/onboarding/intro_screen.dart';
import '../screens/onboarding/permissions_screen.dart';
import '../screens/onboarding/profile_setup_screen.dart';
import '../screens/onboarding/welcome_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/home/discover_screen.dart';
import '../screens/home/chats_list_screen.dart';
import '../screens/home/profile_screen.dart';
import '../screens/host_ride/host_ride_wizard_screen.dart';
import '../screens/home/ride_details_screen.dart';
import '../screens/home/nearby_rides_screen.dart';
import '../screens/home/my_rides_screen.dart';
import '../screens/home/ride_history_screen.dart';
import '../screens/home/chat_screen.dart';
import '../screens/home/notifications_screen.dart';
import '../screens/home/settings_screen.dart';
import '../screens/home/edit_profile_screen.dart';
import '../screens/home/rating_screen.dart';
import '../screens/home/active_ride_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/main_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(authProvider, (previous, next) => notifyListeners());
    _ref.listen<OnboardingPrefs>(onboardingPrefsProvider, (previous, next) => notifyListeners());
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final prefs = ref.read(onboardingPrefsProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isOnboardingComplete =
          !authState.isNewUser && (authState.user?.isOnboardingComplete ?? false);
      final hasSeenIntro = prefs.hasSeenIntro;
      final hasSeenPermissions = prefs.hasSeenPermissions;
      final loc = state.matchedLocation;
      final isSplash = loc == '/';
      final isIntro = loc == '/intro';
      final isWelcome = loc == '/welcome';
      final isPermissions = loc == '/permissions';
      final isAuthRoute =
          loc.startsWith('/phone-input') ||
          loc.startsWith('/otp-verification') ||
          loc.startsWith('/profile-setup');

      // 1) Hold on splash until prefs + auth are hydrated.
      //    Funnel any pre-init location (web refresh / deep link) through splash.
      if (!authState.isInitialized) return isSplash ? null : '/';

      // 2) Splash picks the entry point once hydrated.
      if (isSplash) {
        if (!isAuthenticated) return hasSeenIntro ? '/phone-input' : '/intro';
        if (!isOnboardingComplete) return '/profile-setup';
        return '/home';
      }

      // 3) Intro is only for unauthenticated users.
      if (isIntro) {
        if (isAuthenticated) return isOnboardingComplete ? '/home' : '/profile-setup';
        return null;
      }

      // 4) Unauthenticated users only on auth routes (intro handled above).
      if (!isAuthenticated && !isAuthRoute) {
        return hasSeenIntro ? '/phone-input' : '/intro';
      }

      // 5) Authenticated but not onboarded -> pinned to profile setup.
      if (isAuthenticated && !isOnboardingComplete) {
        if (loc != '/profile-setup') {
          return '/profile-setup';
        }
      }

      // 5.5) Onboarded but hasn't seen the permissions screen yet — let
      //      /welcome still play once (it's the onboarding finale), but any
      //      other destination (including the explicit context.go('/home')
      //      calls in welcome_screen.dart and otp_verification_screen.dart)
      //      gets bounced to /permissions first.
      if (isAuthenticated &&
          isOnboardingComplete &&
          !hasSeenPermissions &&
          !isWelcome &&
          !isPermissions) {
        return '/permissions';
      }

      // 6) Onboarded users never see auth routes. /welcome is not an
      //    auth route so the finale stays reachable.
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

      // Onboarding routes
      GoRoute(
        path: '/intro',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const IntroScreen(),
      ),
      GoRoute(
        path: '/welcome',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/permissions',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PermissionsScreen(),
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
        builder: (context, state) => const HostRideWizardScreen(),
      ),
      GoRoute(
        path: '/ride-details/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            RideDetailsScreen(pingId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/nearby-rides',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final radius =
              double.tryParse(state.uri.queryParameters['radius'] ?? '') ??
                  2000.0;
          final gender = state.uri.queryParameters['gender'];
          return NearbyRidesScreen(radiusMeters: radius, gender: gender);
        },
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
        builder: (context, state) {
          final isRequest = state.uri.queryParameters['isRequest'] == 'true';
          return ChatScreen(
            matchId: state.pathParameters['matchId']!,
            isRequest: isRequest,
          );
        },
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
