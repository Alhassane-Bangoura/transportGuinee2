import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SyndicateTripsPage extends StatelessWidget {
  const SyndicateTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF16A249);
    const Color backgroundColor = Color(0xFFF6F8F7);
    const Color textSlate900 = Color(0xFF0F172A);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(primaryColor, textSlate900),
            _buildTabs(primaryColor),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildTripCard(
                    'Conakry → Mamou',
                    'Amadou Diallo',
                    '09:00',
                    '12/15',
                    'Prévu',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDXN4s8pKLx_WwBGZ0p2jXOEQEQxgcxTAUgLM-rZJga1OzbOTCKSqFMi9IRbLfRlB-DlHg9UbrW1XUzBnknvsTUUAPDqx7K63ONHXNE0VRiY40mud3raodEW6VN0vjcKFb6vCJzn2zaFS8zBSy_YBNivDgF333HPRzs4xE_ewkGV4kJSQOaX4O1K6gcPjyiH3pztsCdIbA2g7Q1Os6is-De3Khf6sOvKzSlVGHEytGk9oAnc6fkuilesP7ojJe0gae8S1CPOAjSVlJ4',
                    primaryColor,
                    primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildTripCard(
                    'Conakry → Labé',
                    'Moussa Camara',
                    '07:30',
                    '18/18',
                    'En cours',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBgv9guf5Jr4cGZNHxO81mOKwoRxRMDRqNc2_Z9KLP-bEVxOvomj1FN7rYXCZeaWLwCil41E-eyXzarSCZjtH0cXLYlvHZXT3PVgFNLFHQxQLsDwNHuukpgKL5bCGoFP1lgziH44ahA_Ax_nPXFvV1i9QHzsiAUtJUR_BFgQei0O4F_seGKZQjLHAwmwk8qr-pmxKLgNzNQK3298ORCuRerKBwbKKkysD7np6ufDkCAVwOWEKzb0nOL0XvsWHnCvSjlYvRTJzmSpzkr',
                    Colors.blue,
                    primaryColor,
                  ),
                  const SizedBox(height: 16),
                  _buildTripCard(
                    'Conakry → Kindia',
                    'Ibrahima Sow',
                    '11:15',
                    '05/09',
                    'Prévu',
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuDEAIRCWDSzXL_uxGb_RjI1TItYPcNJ2NN6Ky3L4tbLF4ZBJQp2mTL4zJXgkYP4tXE58b9cJ2sQZY6OloL4EG6kKfjpdFpEEzZuteniQgw5qP7DOfVdtnSjNDw1iwm0r9_oMH1efqfHn4ovMbiE3hA-lZ-uzToSuUGoiC2FilGpA9P2XfDdYP0V-kKNSvF7LjMJO8HtDhVteVpCuoiSN_2r7DZpCSMflmnxfrkh9J0I2eEpXX97brocEAJiA2ccXqmKz0wkMnmPSiKc',
                    primaryColor,
                    primaryColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color primary, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.menu),
            style: IconButton.styleFrom(
              backgroundColor: primary.withValues(alpha: 0.1),
              foregroundColor: primary,
            ),
          ),
          Text(
            'Trajets du syndicat',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_outlined),
            style: IconButton.styleFrom(
              backgroundColor: primary.withValues(alpha: 0.1),
              foregroundColor: primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildTabItem('Aujourd\'hui', true, primary),
          _buildTabItem('Prochains', false, primary),
          _buildTabItem('Historique', false, primary),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, bool isActive, Color primary) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? primary : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? primary : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(String route, String driver, String time, String passengers,
      String status, String img, Color statusColor, Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              img,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.person, size: 14, color: primary),
                            const SizedBox(width: 4),
                            Text(
                              'Chauffeur: $driver',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF64748B),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.plusJakartaSans(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.symmetric(
                      horizontal: BorderSide(
                        color: primary.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(Icons.schedule, time, primary),
                      _buildMetric(Icons.group, '$passengers Passagers', primary),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Voir détails'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {},
                        icon: const Icon(Icons.group),
                        color: primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value, Color primary) {
    return Row(
      children: [
        Icon(icon, color: primary, size: 18),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}
