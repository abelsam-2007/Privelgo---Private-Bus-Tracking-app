import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({Key? key}) : super(key: key);

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  String _startStop = "Colombo Central";
  String _destStop = "Mount Lavinia";
  String _passengerType = "standard"; // standard, student, senior
  bool _isCalculated = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privelgo Trip Planner"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Planner Input Fields
              _buildInputsCard(),
              const SizedBox(height: 16),

              // 2. Main Action Button
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _isCalculated = true);
                },
                icon: const Icon(Icons.route),
                label: const Text("Plan Trip & Estimate Fares"),
              ),
              const SizedBox(height: 20),

              // 3. Recommended Itineraries Display
              if (_isCalculated) ...[
                const Text(
                  "Recommended Route Options",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PrivelgoTheme.darkBlue),
                ),
                const SizedBox(height: 10),
                _buildItineraryCard(
                  title: "⚡ Fastest / Best Route",
                  busNum: "100",
                  stops: 5,
                  duration: "40 mins",
                  walking: "380 m",
                  fare: _passengerType == 'student'
                      ? "37.50 LKR"
                      : _passengerType == 'senior'
                          ? "52.50 LKR"
                          : "75.00 LKR",
                  desc: "Take Bus 100 directly from Colombo Central. Board at 22:35, arrive at Mount Lavinia by 23:15.",
                ),
                const SizedBox(height: 12),
                _buildItineraryCard(
                  title: "🛋️ Least Crowded Option",
                  busNum: "138",
                  stops: 4,
                  duration: "45 mins",
                  walking: "600 m",
                  fare: _passengerType == 'student'
                      ? "30.00 LKR"
                      : _passengerType == 'senior'
                          ? "42.00 LKR"
                          : "60.00 LKR",
                  desc: "Take Bus 138. Currently reports Seats Available 🟢. Requires transferring at Town Hall.",
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Where are you going?",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: PrivelgoTheme.darkBlue),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              value: _startStop,
              decoration: const InputDecoration(
                labelText: "Start Location",
                prefixIcon: Icon(Icons.my_location, color: PrivelgoTheme.steelBlue),
              ),
              items: ["Colombo Central", "Liberty Junction", "Town Hall", "Borella", "Mount Lavinia"]
                  .map((stop) => DropdownMenuItem(value: stop, child: Text(stop)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _startStop = val);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _destStop,
              decoration: const InputDecoration(
                labelText: "Destination Location",
                prefixIcon: Icon(Icons.location_on, color: Colors.redAccent),
              ),
              items: ["Colombo Central", "Liberty Junction", "Town Hall", "Borella", "Mount Lavinia"]
                  .map((stop) => DropdownMenuItem(value: stop, child: Text(stop)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _destStop = val);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "Passenger Category (Discount Application)",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: PrivelgoTheme.steelBlue),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildPassengerTypeChip("Standard", "standard"),
                const SizedBox(width: 8),
                _buildPassengerTypeChip("Student (50%)", "student"),
                const SizedBox(width: 8),
                _buildPassengerTypeChip("Senior (30%)", "senior"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerTypeChip(String label, String type) {
    final isSelected = _passengerType == type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: PrivelgoTheme.darkBlue,
      textColor: isSelected ? Colors.white : Colors.black,
      onSelected: (val) {
        if (val) setState(() => _passengerType = type);
      },
    );
  }

  Widget _buildItineraryCard({
    required String title,
    required String busNum,
    required int stops,
    required String duration,
    required String walking,
    required String fare,
    required String desc,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PrivelgoTheme.steelBlue.withOpacity(0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: PrivelgoTheme.darkBlue),
                ),
                Text(
                  fare,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildItineraryStat(Icons.directions_bus, "Bus $busNum"),
                _buildItineraryStat(Icons.timer_outlined, duration),
                _buildItineraryStat(Icons.directions_walk, walking),
                _buildItineraryStat(Icons.transfer_within_a_station, "$stops stops"),
              ],
            ),
            const Divider(height: 24),
            Text(
              desc,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Step-by-step guidance started. Head to the stop!")),
                );
              },
              child: const Text("Start Navigation"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItineraryStat(IconData icon, String val) {
    return Row(
      children: [
        Icon(icon, size: 16, color: PrivelgoTheme.steelBlue),
        const SizedBox(width: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
      ],
    );
  }
}
extension on ChoiceChip {
  Color? get textColor => null;
}
// Add custom ChoiceChip color extension handler
