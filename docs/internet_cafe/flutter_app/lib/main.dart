import 'package:flutter/material.dart';
import 'ui/screens/login_screen.dart';
import 'ui/screens/register_screen.dart';
import 'ui/screens/customer_dashboard.dart';
import 'ui/screens/computer_reservation_screen.dart';
import 'ui/screens/service_request_screen.dart';
import 'ui/screens/operator_dashboard.dart';
import 'ui/screens/daily_reports_screen.dart';

void main() {
  runApp(const InternetCafeApp());
}

class InternetCafeApp extends StatelessWidget {
  const InternetCafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Internet Cafe Management',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/customer': (_) => const CustomerDashboard(),
        '/reserve': (_) => const ComputerReservationScreen(),
        '/services': (_) => const ServiceRequestScreen(),
        '/operator': (_) => const OperatorDashboard(),
        '/reports': (_) => const DailyReportsScreen(),
      },
    );
  }
}
