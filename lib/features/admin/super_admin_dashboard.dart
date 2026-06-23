import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../models/admin_models.dart';
import '../../utils/language_provider.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});

  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(lang.t('super_admin_title')),
        backgroundColor: const Color(0xFF1B263B),
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology, color: Colors.cyanAccent),
            onPressed: () => _showAICommandCenter(context),
            tooltip: 'AI Command Center',
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      drawer: _buildAdminDrawer(context, lang),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlobalStats(context, lang),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: _buildRevenueChart(context, lang)),
                const SizedBox(width: 16),
                Expanded(child: _buildServicePerformance(context, lang)),
              ],
            ),
            const SizedBox(height: 20),
            _buildPredictiveInsights(context, lang),
            const SizedBox(height: 20),
            _buildServiceGrid(context, lang),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDrawer(BuildContext context, LanguageProvider lang) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF1B263B)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(backgroundColor: Colors.white, child: Icon(Icons.admin_panel_settings)),
                SizedBox(height: 10),
                Text('Hawassa City Admin', style: TextStyle(color: Colors.white, fontSize: 18)),
                Text('Super Admin Level', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          ListTile(leading: const Icon(Icons.dashboard), title: const Text('Global Overview'), onTap: () {}),
          ListTile(leading: const Icon(Icons.map), title: const Text('City Map Control'), onTap: () {}),
          ListTile(leading: const Icon(Icons.people), title: const Text('User Management'), onTap: () {}),
          ListTile(leading: const Icon(Icons.attach_money), title: const Text('Revenue Control'), onTap: () {}),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('SUBSIDIARY SERVICES', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
          ListTile(leading: const Icon(Icons.bus_alert), title: const Text('Terminals'), onTap: () {}),
          ListTile(leading: const Icon(Icons.local_hospital), title: const Text('Healthcare'), onTap: () {}),
          ListTile(leading: const Icon(Icons.emergency), title: const Text('Emergency Response'), onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildGlobalStats(BuildContext context, LanguageProvider lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _statCard('Total Revenue', '4.2M ETB', Icons.trending_up, Colors.green),
        _statCard('Active Users', '85.4K', Icons.people, Colors.blue),
        _statCard('Active Vehicles', '1,240', Icons.directions_car, Colors.orange),
        _statCard('SOS Alerts', '12', Icons.warning, Colors.red),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.22,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildRevenueChart(BuildContext context, LanguageProvider lang) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('City Revenue Trend', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: [const FlSpot(0, 3), const FlSpot(2, 5), const FlSpot(4, 4), const FlSpot(6, 8)],
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 4,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicePerformance(BuildContext context, LanguageProvider lang) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Service Utilization', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: PieChart(
              PieChartData(
                sections: [
                  PieChartSectionData(value: 40, color: Colors.blue, title: 'Transport'),
                  PieChartSectionData(value: 30, color: Colors.green, title: 'Tourism'),
                  PieChartSectionData(value: 15, color: Colors.red, title: 'Health'),
                  PieChartSectionData(value: 15, color: Colors.orange, title: 'Other'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictiveInsights(BuildContext context, LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0D1B2A), Color(0xFF1B263B)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt, color: Colors.cyanAccent, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('AI Predictive Insight', style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                Text(
                  'Demand for intercity travel to Addis Ababa is predicted to increase by 24% this weekend due to the Sidama Cultural Festival. Recommend deploying 15 extra buses to New Terminal.',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context, LanguageProvider lang) {
    final services = [
      {'name': 'Old Terminal', 'icon': Icons.history},
      {'name': 'New Terminal', 'icon': Icons.new_releases},
      {'name': 'Taxi Services', 'icon': Icons.local_taxi},
      {'name': 'Tourism', 'icon': Icons.map},
      {'name': 'Hospitals', 'icon': Icons.local_hospital},
      {'name': 'Pharmacies', 'icon': Icons.local_pharmacy},
      {'name': 'Eco-Shine', 'icon': Icons.eco},
      {'name': 'Food Delivery', 'icon': Icons.restaurant},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.5,
      ),
      itemCount: services.length,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            leading: Icon(services[index]['icon'] as IconData, color: const Color(0xFF1B263B)),
            title: Text(services[index]['name'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onTap: () {},
          ),
        );
      },
    );
  }

  void _showAICommandCenter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: const BoxDecoration(
          color: Color(0xFF0D1B2A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('AI Central Command', style: TextStyle(color: Colors.cyanAccent, fontSize: 24, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const Divider(color: Colors.cyanAccent),
            Expanded(
              child: ListView(
                children: [
                  _buildAIInsightTile('Transport Optimization', 'Redistribute bajaj traffic from Piazza to Tabor area to reduce congestion by 15%.'),
                  _buildAIInsightTile('Revenue Forecasting', 'Predicting 12% revenue growth next month based on current user onboarding trends.'),
                  _buildAIInsightTile('Emergency Response', 'Optimized ambulance standby locations based on accident heatmap analysis.'),
                  _buildAIInsightTile('Service Quality', 'AI analysis of feedback indicates a need for better lighting at Old Terminal.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInsightTile(String title, String insight) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(insight, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ],
      ),
    );
  }
}
