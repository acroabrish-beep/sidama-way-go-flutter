import 'package:flutter/material.dart';

class PharmacyScreen extends StatelessWidget {
  const PharmacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PHARMACY DELIVERY')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search medicines...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildPrescriptionUpload(),
                const SizedBox(height: 32),
                const Text('NEARBY PHARMACIES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 16),
                _buildPharmacyCard('Gudumale Pharmacy', 'Open • 0.5 km'),
                _buildPharmacyCard('Piazza Pharmacy', 'Closing soon • 1.2 km'),
                _buildPharmacyCard('Lakeside Medicals', 'Open 24/7 • 2.1 km'),
                const SizedBox(height: 32),
                const Text('TRENDING MEDICINES', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 16),
                _buildMedicineItem('Paracetamol', '50 ETB'),
                _buildMedicineItem('Vitamin C', '120 ETB'),
                _buildMedicineItem('Amoxicillin', '180 ETB'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionUpload() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF00C853), Color(0xFF009624)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          const Text('UPLOAD PRESCRIPTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          const Text('Get medicines delivered to your door', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.green),
            child: const Text('CHOOSE FILE'),
          ),
        ],
      ),
    );
  }

  Widget _buildPharmacyCard(String name, String info) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.local_pharmacy, color: Colors.white)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(info),
        trailing: const Icon(Icons.shopping_cart_outlined, size: 20),
      ),
    );
  }

  Widget _buildMedicineItem(String name, String price) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(name),
        trailing: Text(price, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
      ),
    );
  }
}
