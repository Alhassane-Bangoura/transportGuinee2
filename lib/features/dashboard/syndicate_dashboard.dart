import 'package:flutter/material.dart';

class SyndicateDashboard extends StatelessWidget {
  const SyndicateDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF0FBD0F);
    const Color backgroundColor = Color(0xFFF6F8F6);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
        children: [
          // Header
          _buildHeader(primaryColor),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  // Stats Overview
                  _buildStatsOverview(primaryColor),

                  // Daily Activity
                  _buildDailyActivity(primaryColor),

                  // Administrative Alerts
                  _buildAlerts(),

                  // Driver Management
                  _buildDriverManagement(primaryColor),

                  // Reports & Documents
                  _buildReportsSection(primaryColor),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(primaryColor),
    );
  }

  Widget _buildHeader(Color primary) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 48, bottom: 16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance, color: primary, size: 32),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Syndicat Régional Conakry',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Text('Conakry, Guinée • Mis à jour 08:30',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: primary.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.notifications, color: primary, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(Color primary) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
              child:
                  _buildStatCard('Total Chauffeurs', '1,250', '+5%', primary)),
          const SizedBox(width: 16),
          Expanded(
              child:
                  _buildStatCard('Chauffeurs Actifs', '842', '82%', primary)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, String badge, Color primary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(value,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                    color: primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(badge,
                    style: TextStyle(
                        color: primary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyActivity(Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.today, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text('Activité du jour',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildActivityCard(Icons.local_shipping,
                      'Départs Totaux', '142', Colors.blue)),
              const SizedBox(width: 16),
              Expanded(
                  child: _buildActivityCard(
                      Icons.payments, 'Revenus Est.', '4.2M FG', Colors.amber)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAlerts() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('Alertes Administratives',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFFC62828))),
              ],
            ),
            const SizedBox(height: 12),
            _buildAlertItem('Licences expirées (3)', 'Gérer'),
            const SizedBox(height: 8),
            _buildAlertItem('Faible taux d\'occupation - Ligne B', 'Voir'),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertItem(String text, String action) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(text,
            style: const TextStyle(fontSize: 12, color: Color(0xFFC62828))),
        Text(action,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
                color: Color(0xFFC62828))),
      ],
    );
  }

  Widget _buildDriverManagement(Color primary) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.group, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text('Gestion des chauffeurs',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              Text('Voir tout',
                  style: TextStyle(
                      color: primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          _buildDriverItem(
              'Mamadou Diallo',
              'ID: 224-MD01',
              'ACTIF',
              Colors.green,
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDPjrVU_GBlUA7Y9bL7YxFIpx9NyTFO2mYgBhCRgVhD9Mt4WwFMhoJOvm1KBTIPk5tT4Al10HvAeuUzCqCqlgvIoxG_0Dw-GbrXd22uLmxiMaAJR0DItHB_MX4bWDviwqWeto8a8PvfWOypcVLbjfySUZpYyfVZguv-uxKNlnPu55BNjzVRL3zCTKiwZCg7U91wFoiJlYgNFiLZCj2PJbpV-529hVwet3PDVZxcerLlaOygysKfAAxZyGY87pDT22PwmGjUeqNwuYmP'),
          const SizedBox(height: 8),
          _buildDriverItem(
              'Ibrahima Bah',
              'ID: 224-IB05',
              'SUSPENDU',
              Colors.orange,
              'https://lh3.googleusercontent.com/aida-public/AB6AXuB9PEpSDnUHvXiNxnNwenNf5IZi9Nk5FacDNS-4RrGGml3_kfNq84IbtxExGWJzFZYnBpSV9d4FVPh6Pg-LenKiW8wCsQ5dUB-cGpdfOes1uAhQe8yrEPAXyVd7wswBTBCA88ISAGPYjHnA92wBFWVXte5QwPsmuwX9yqOzoGEvjAHyCLwYQLI0-fHjIW3OuzYb0gCLZV5VEB7Iof7JzhuHXNYsJs0M5kcig-44p1N_x96QG9ocz_9prhq1gbDtHanXfpVE3i4bfS5D',
              isAlert: true),
        ],
      ),
    );
  }

  Widget _buildDriverItem(
      String name, String id, String status, Color statusColor, String imageUrl,
      {bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isAlert ? Border.all(color: Colors.orange, width: 2) : null,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                      image: NetworkImage(imageUrl), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(id,
                      style: const TextStyle(color: Colors.grey, fontSize: 10)),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20)),
                child: Text(status,
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportsSection(Color primary) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Rapports & Documents',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildReportButton(Icons.picture_as_pdf, 'Export PDF Hebdo',
                    Colors.white, primary),
                const SizedBox(width: 12),
                _buildReportButton(Icons.table_view, 'Données Excel',
                    Colors.black87, Colors.white,
                    isOutlined: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportButton(
      IconData icon, String text, Color textColor, Color bgColor,
      {bool isOutlined = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: isOutlined ? Border.all(color: Colors.black12) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor, size: 18),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  color: textColor, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBottomNav(Color primary) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border(top: BorderSide(color: Colors.black.withOpacity(0.05)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.dashboard, 'Dashboard', true, primary),
          _buildNavItem(Icons.groups, 'Membres', false, primary),
          _buildNavItem(Icons.route, 'Trajets', false, primary),
          _buildNavItem(Icons.settings, 'Paramètres', false, primary),
        ],
      ),
    );
  }

  Widget _buildNavItem(
      IconData icon, String label, bool isActive, Color primary) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: isActive ? primary : Colors.grey),
        Text(label,
            style: TextStyle(
                color: isActive ? primary : Colors.grey,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500)),
      ],
    );
  }
}
