import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Privelgo Admin Center"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Stats Dashboard Grid
              _buildStatsGrid(),
              const SizedBox(height: 20),

              // 2. Active Complaints Section
              const Text(
                "Active Passenger Complaints",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PrivelgoTheme.darkBlue),
              ),
              const SizedBox(height: 10),
              _buildComplaintCard(
                category: "Unsafe Driving",
                bus: "WP-NB-5544 (Route 100)",
                reporter: "Jane D.",
                desc: "Driver is overtaking aggressively on Galle Road.",
                status: "Pending Investigation",
                color: Colors.red[800]!,
              ),
              const SizedBox(height: 10),
              _buildComplaintCard(
                category: "Late Bus / Delay",
                bus: "WP-NC-9912 (Route 176)",
                reporter: "K. Fernando",
                desc: "Bus arrived 15 minutes after scheduled time stage.",
                status: "Resolved - Driver Warned",
                color: Colors.green[800]!,
              ),
              const SizedBox(height: 20),

              // 3. Review Approvals Pane
              const Text(
                "Pending Reviews Approval",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: PrivelgoTheme.darkBlue),
              ),
              const SizedBox(height: 10),
              _buildReviewApprovalCard(
                user: "Mohamed R.",
                bus: "WP-ND-8432",
                rating: 4.5,
                comment: "Good seats and prompt response from helper, but AC was too cold.",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatTile("Active Buses", "18", Icons.directions_bus, Colors.green),
        _buildStatTile("Pending Reports", "3", Icons.warning, Colors.redAccent),
        _buildStatTile("Avg Occupancy", "62%", Icons.people_alt, PrivelgoTheme.steelBlue),
        _buildStatTile("Revenue Today", "48.2k LKR", Icons.monetization_on, Colors.purple),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Icon(icon, color: color, size: 20),
              ],
            ),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: PrivelgoTheme.darkBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintCard({
    required String category,
    required String bus,
    required String reporter,
    required String desc,
    required String status,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(category, style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text("Bus: $bus • Reporter: $reporter", style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(desc, style: const TextStyle(fontSize: 12, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewApprovalCard({
    required String user,
    required String bus,
    required double rating,
    required String comment,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$user on Bus $bus", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('"$comment"', style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.black87)),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text("Reject", style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: Colors.green[800],
                  ),
                  child: const Text("Approve"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
