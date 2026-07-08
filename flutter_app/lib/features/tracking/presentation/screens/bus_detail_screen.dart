import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class BusDetailScreen extends StatefulWidget {
  final int busId;
  const BusDetailScreen({Key? key, required this.busId}) : super(key: key);

  @override
  State<BusDetailScreen> createState() => _BusDetailScreenState();
}

class _BusDetailScreenState extends State<BusDetailScreen> {
  double _myRating = 5;
  final TextEditingController _reviewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bus Information & Live Status"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Bus Basic Specs and Live Indicator
              _buildLiveStatusCard(),
              const SizedBox(height: 20),

              // 2. Bus Features (AC, WiFi, etc)
              _buildAmenitiesCard(),
              const SizedBox(height: 20),

              // 3. User Review / Rating submission Form
              _buildReviewForm(),
              const SizedBox(height: 24),

              // 4. Feed of existing Passenger Reviews
              _buildReviewsHeader(),
              const SizedBox(height: 10),
              _buildMockReviewCard(
                "Sanduni Fernando",
                "Extremely clean bus with very fast WiFi. The AC is perfect for Colombo heat!",
                5.0,
              ),
              const SizedBox(height: 10),
              _buildMockReviewCard(
                "M. R. Mohamed",
                "Punctual bus, but it got quite crowded during office closing hours. Clean and safe driving.",
                4.0,
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiveStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "WP-ND-8432",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: PrivelgoTheme.darkBlue),
                    ),
                    Text(
                      "Privelgo Express Blue • Route 138",
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "On Time",
                        style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                )
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusStat(Icons.event_seat_rounded, "Seats Available", "🟢 Occupancy", Colors.green),
                _buildStatusStat(Icons.people_alt, "14 / 42", "Passengers", PrivelgoTheme.darkBlue),
                _buildStatusStat(Icons.speed, "35 km/h", "Current Speed", PrivelgoTheme.steelBlue),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showSosDialog,
              icon: const Icon(Icons.warning, color: Colors.white),
              label: const Text("Report Driver / SOS"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[800],
                minimumSize: const Size(double.infinity, 44),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusStat(IconData icon, String val, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
      ],
    );
  }

  Widget _buildAmenitiesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Bus Facilities", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: PrivelgoTheme.darkBlue)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildAmenityBadge(Icons.ac_unit, "A/C Enabled", true),
                _buildAmenityBadge(Icons.wifi, "Free WiFi", true),
                _buildAmenityBadge(Icons.accessible, "Accessible", true),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAmenityBadge(IconData icon, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: active ? PrivelgoTheme.steelBlue.withOpacity(0.08) : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? PrivelgoTheme.steelBlue.withOpacity(0.3) : Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: active ? PrivelgoTheme.darkBlue : Colors.grey),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 11, color: active ? PrivelgoTheme.darkBlue : Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildReviewForm() {
    return Card(
      color: PrivelgoTheme.steelBlue.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PrivelgoTheme.steelBlue.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Write a Review", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: PrivelgoTheme.darkBlue)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text("Your Rating: ", style: TextStyle(fontSize: 13)),
                const SizedBox(width: 8),
                DropdownButton<double>(
                  value: _myRating,
                  items: [5.0, 4.0, 3.0, 2.0, 1.0].map((r) => DropdownMenuItem(value: r, child: Text("⭐ $r"))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _myRating = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _reviewController,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: "Share your trip experience (cleanliness, comfort, safety)...",
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Thank you! Review submitted. You earned 15 reward points!")),
                );
                _reviewController.clear();
              },
              child: const Text("Post Review"),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Passenger Reviews", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: PrivelgoTheme.darkBlue)),
        TextButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.sort_rounded, size: 16),
          label: const Text("Sort"),
        )
      ],
    );
  }

  Widget _buildMockReviewCard(String author, String review, double rating) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(author, style: const TextStyle(fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 2),
                    Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(review, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  void _showSosDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Report Issue / SOS", style: TextStyle(color: Colors.red)),
        content: const Text(
          "This will flag the current bus driver (Sunil Perera) and notify the operator immediately. Are you sure you want to proceed?",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Emergency SOS signal transmitted successfully.")),
              );
            },
            child: const Text("Send SOS"),
          )
        ],
      ),
    );
  }
}
