import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({Key? key}) : super(key: key);

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  bool _isTripActive = false;
  bool _isSharingGps = false;
  int _passengerCount = 14;
  int _delayMins = 0;
  String _crowdedness = "seats_available";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privelgo Driver Console"),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () {},
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Driver Profile Summary
              _buildDriverProfileCard(),
              const SizedBox(height: 16),

              // 2. Active Trip Actions
              _buildTripStatusCard(),
              const SizedBox(height: 16),

              // 3. Passenger Counter & Crowd Level
              if (_isTripActive) ...[
                _buildPassengerCounterCard(),
                const SizedBox(height: 16),
                _buildDelayReporterCard(),
              ],

              const SizedBox(height: 24),
              // Emergency Panic Button
              ElevatedButton.icon(
                onPressed: _triggerEmergencyPanic,
                icon: const Icon(Icons.emergency, color: Colors.white),
                label: const Text("PANIC / EMERGENCY SOS"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[900],
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverProfileCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: PrivelgoTheme.steelBlue,
              child: Icon(Icons.person, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Sunil Perera", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PrivelgoTheme.darkBlue)),
                  Text("Operator: Express Transit Co. • Lic # WP-182390", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripStatusCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isTripActive ? Colors.green.withOpacity(0.4) : PrivelgoTheme.steelBlue.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isTripActive ? "Active Trip: Route 138" : "Trip is Inactive",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: PrivelgoTheme.darkBlue),
                    ),
                    Text(
                      _isTripActive ? "Bus: WP-ND-8432 • Kottawa - Pettah" : "Sign in and start route to transmit GPS",
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                Switch(
                  value: _isSharingGps,
                  onChanged: _isTripActive
                      ? (val) {
                          setState(() => _isSharingGps = val);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(val ? "GPS Tracking Broadcast is ON 🟢" : "GPS Broadcast PAUSED ⏸️")),
                          );
                        }
                      : null,
                )
              ],
            ),
            const Divider(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isTripActive = !_isTripActive;
                  if (!_isTripActive) {
                    _isSharingGps = false;
                  } else {
                    _isSharingGps = true;
                  }
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isTripActive ? Colors.orange[800] : PrivelgoTheme.darkBlue,
                minimumSize: const Size(double.infinity, 44),
              ),
              child: Text(_isTripActive ? "End Trip & Log Off" : "Start Trip"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassengerCounterCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Passenger Occupancy & Counting", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: PrivelgoTheme.darkBlue)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Passengers: $_passengerCount", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Capacity Limit: 42 (Level: ${_crowdedness.replaceAll('_', ' ')})", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 28, color: PrivelgoTheme.steelBlue),
                      onPressed: () {
                        if (_passengerCount > 0) {
                          setState(() {
                            _passengerCount--;
                            _updateCrowdLevel();
                          });
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 28, color: PrivelgoTheme.darkBlue),
                      onPressed: () {
                        if (_passengerCount < 42) {
                          setState(() {
                            _passengerCount++;
                            _updateCrowdLevel();
                          });
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDelayReporterCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Report Delays & Incidents", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: PrivelgoTheme.darkBlue)),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              value: _delayMins,
              decoration: const InputDecoration(labelText: "Delay Status"),
              items: const [
                DropdownMenuItem(value: 0, child: Text("On Time 🟢")),
                DropdownMenuItem(value: 2, child: Text("2 Min Delay 🟡")),
                DropdownMenuItem(value: 5, child: Text("5 Min Delay 🟡")),
                DropdownMenuItem(value: 10, child: Text("Heavy Traffic Delay (10 Min) 🔴")),
                DropdownMenuItem(value: 20, child: Text("Breakdown / Extreme Delay 🔴")),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _delayMins = val);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _updateCrowdLevel() {
    if (_passengerCount < 18) {
      _crowdedness = "seats_available";
    } else if (_passengerCount < 36) {
      _crowdedness = "moderately_crowded";
    } else {
      _crowdedness = "full";
    }
  }

  void _triggerEmergencyPanic() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm SOS Broadcast", style: TextStyle(color: Colors.red)),
        content: const Text(
          "This will trigger police/medical dispatcher services, send coordinates, and alerts to all registered operators. Activate?",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Emergency SOS signal sent to dispatcher.")),
              );
            },
            child: const Text("Send SOS Now"),
          )
        ],
      ),
    );
  }
}
