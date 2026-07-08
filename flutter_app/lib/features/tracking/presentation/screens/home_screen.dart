import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map Simulation Container
          Container(
            width: double.infinity,
            height: double.infinity,
            color: PrivelgoTheme.backgroundWhite,
            child: Stack(
              children: [
                // Simulated map roads & buses
                Center(
                  child: Icon(
                    Icons.map_rounded,
                    size: 150,
                    color: PrivelgoTheme.steelBlue.withOpacity(0.3),
                  ),
                ),
                // Live Bus Marker Mock 1
                Positioned(
                  top: 250,
                  left: 120,
                  child: _buildLiveBusMarker("138", PrivelgoTheme.darkBlue),
                ),
                // Live Bus Marker Mock 2
                Positioned(
                  top: 380,
                  right: 90,
                  child: _buildLiveBusMarker("100", Colors.green),
                ),
              ],
            ),
          ),

          // 2. Safe Area UI Overlay
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Greeting
                _buildHeaderCard(),
                const Spacer(),
                // Bottom Overlay Card
                _buildBottomOverlay(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveBusMarker(String routeNum, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.directions_bus, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            routeNum,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: PrivelgoTheme.darkBlue.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: PrivelgoTheme.darkBlue,
            radius: 24,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Hello, Alex Dev",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: PrivelgoTheme.darkBlue,
                  ),
                ),
                const Text(
                  "Where are you heading today?",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: PrivelgoTheme.steelBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: const [
                Icon(Icons.stars, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  "240 pts",
                  style: TextStyle(color: PrivelgoTheme.darkBlue, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOverlay() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle indicator
          Center(
            child: Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Custom search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search bus, route, stop, or destination...",
              prefixIcon: const Icon(Icons.search, color: PrivelgoTheme.steelBlue),
              suffixIcon: IconButton(
                icon: const Icon(Icons.tune_rounded, color: PrivelgoTheme.darkBlue),
                onPressed: () {},
              ),
              filled: true,
              fillColor: PrivelgoTheme.backgroundWhite.withOpacity(0.6),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Shortcut buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildShortcutButton(Icons.home, "Home", "WTC Colombo"),
              _buildShortcutButton(Icons.work, "Work", "Liberty Plz"),
              _buildShortcutButton(Icons.school, "Campus", "UOC Faculty"),
            ],
          ),
          const SizedBox(height: 20),

          // Service Alert banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50]!.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber[800], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Bus 102 delayed 5 mins due to road closure at Kollupitiya.",
                    style: TextStyle(color: Colors.amber[900], fontSize: 12),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildShortcutButton(IconData icon, String title, String subtitle) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: PrivelgoTheme.backgroundWhite.withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PrivelgoTheme.lightBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: PrivelgoTheme.darkBlue),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 10), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
