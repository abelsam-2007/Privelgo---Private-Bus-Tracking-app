import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/tracking/presentation/screens/home_screen.dart';
import 'features/tracking/presentation/screens/trip_planner_screen.dart';
import 'features/driver/presentation/screens/driver_screen.dart';
import 'features/admin/presentation/screens/admin_dashboard_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: PrivelgoApp(),
    ),
  );
}

class PrivelgoApp extends StatelessWidget {
  const PrivelgoApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Privelgo',
      theme: PrivelgoTheme.lightTheme,
      darkTheme: PrivelgoTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainTabNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainTabNavigator extends StatefulWidget {
  const MainTabNavigator({Key? key}) : super(key: key);

  @override
  State<MainTabNavigator> createState() => _MainTabNavigatorState();
}

class _MainTabNavigatorState extends State<MainTabNavigator> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    TripPlannerScreen(),
    DriverScreen(),
    AdminDashboardScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Explore',
          ),
          NavigationDestination(
            icon: Icon(Icons.route_outlined),
            selectedIcon: Icon(Icons.route),
            label: 'Plan Trip',
          ),
          NavigationDestination(
            icon: Icon(Icons.drive_eta_outlined),
            selectedIcon: Icon(Icons.drive_eta),
            label: 'Driver Portal',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin Panel',
          ),
        ],
      ),
    );
  }
}
