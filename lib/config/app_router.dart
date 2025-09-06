import 'package:flutter/material.dart';
import 'package:rental_webapp/features/admin/admin_dashboard_page.dart';
import 'package:rental_webapp/features/admin/manage_shops_page.dart';
import 'package:rental_webapp/features/admin/payments_page.dart';
import 'package:rental_webapp/features/admin/profile_page.dart';
import 'package:rental_webapp/features/admin/rental_requests_page.dart';
import 'package:rental_webapp/features/admin/tenants_page.dart';
import 'package:rental_webapp/features/auth/forgot_password.dart';
import 'package:rental_webapp/features/auth/login_page.dart';
import 'package:rental_webapp/features/auth/signup_page.dart';
import 'package:rental_webapp/features/auth/splash_page.dart';
import 'package:rental_webapp/features/user/my_rentals_page.dart';
import 'package:rental_webapp/features/user/notifications_page.dart';
import 'package:rental_webapp/features/user/profile_page.dart';
import 'package:rental_webapp/features/user/user_home_page.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String userHome = '/user-home';
  static const String adminDashboard = '/admin-dashboard';
  static const String manageShops = '/manage-shops';
  static const String rentalRequests = '/rental-requests';
  static const String adminPayments = '/admin-payments';
  static const String rentalPage = '/my-rentals';
  static const String tenants = '/tenants';
  static const String userProfile = '/user-profile';
  static const String adminProfile = '/admin-profile';
  static const String notifications = '/notifications';
  static const String forgotPassword = '/forgot-password';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashPage());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case signup:
        return MaterialPageRoute(builder: (_) => const SignupPage());
      case userHome:
        return MaterialPageRoute(builder: (_) => UserHomePage());
      case adminDashboard:
        return MaterialPageRoute(builder: (_) => const AdminDashboardPage());
      case manageShops:
        return MaterialPageRoute(builder: (_) => const ManageShopPage());
      case rentalRequests:
        return MaterialPageRoute(builder: (_) => const RentalRequestsPage());
      case adminPayments:
        return MaterialPageRoute(builder: (_) => const AdminPaymentPage());
      case rentalPage:
        return MaterialPageRoute(builder: (_) => const MyRentalPage());
      case tenants:
         return MaterialPageRoute(builder: (_) => const TenantPage());
         case userProfile:
        return MaterialPageRoute(builder: (_) => const UserProfilePage());
        case adminProfile:
        return MaterialPageRoute(builder: (_) => const AdminProfilePage());
        case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsPage());
        case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Convenience navigation methods
  static void goToLogin(BuildContext context) =>
      Navigator.pushReplacementNamed(context, login);

  static void goToSignup(BuildContext context) =>
      Navigator.pushReplacementNamed(context, signup);

  static void goToUserHome(BuildContext context) =>
      Navigator.pushReplacementNamed(context, userHome);

  static void goToAdminDashboard(BuildContext context) =>
      Navigator.pushReplacementNamed(context, adminDashboard);

  static void goToManageShops(BuildContext context) =>
      Navigator.pushNamed(context, manageShops);

  static void goToRentalRequests(BuildContext context) =>
      Navigator.pushNamed(context, rentalRequests);

  static void goToAdminPayments(BuildContext context) =>
      Navigator.pushNamed(context, adminPayments);

  static void goToMyRentals(BuildContext context) =>
      Navigator.pushNamed(context, rentalPage);

  static void goToTenants(BuildContext context) =>
      Navigator.pushNamed(context, tenants);

  static void goToUserProfile(BuildContext context) =>
      Navigator.pushNamed(context, userProfile);

  static void goToAdminProfile(BuildContext context) =>
      Navigator.pushNamed(context, adminProfile);

  static void goToNotifications(BuildContext context) =>
      Navigator.pushNamed(context, notifications);

  static void goToForgotPassword(BuildContext context) =>
      Navigator.pushNamed(context, forgotPassword);
}