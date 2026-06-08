import 'package:flutter/material.dart';

class PharmacyScreen extends StatelessWidget {
  const PharmacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Delivery'),
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.teal[800],
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search medicines...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTopAction(Icons.upload_file, 'Prescription'),
                    _buildTopAction(Icons.history, 'Orders'),
                    _buildTopAction(Icons.local_shipping, 'Tracking'),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                SizedBox(
                  height: 100,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCategory('First Aid', Icons.medical_services),
                      _buildCategory('Pain Relief', Icons.healing),
                      _buildCategory('Wellness', Icons.spa),
                      _buildCategory('Baby Care', Icons.child_care),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                const Text('Popular Medicines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                _buildMedicineItem('Paracetamol 500mg', 'Pain & Fever', '15.00 ETB'),
                _buildMedicineItem('Vitamin C 1000mg', 'Immunity', '120.00 ETB'),
                _buildMedicineItem('Amoxicillin 500mg', 'Antibiotic', '180.00 ETB'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAction(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(backgroundColor: Colors.white24, child: Icon(icon, color: Colors.white)),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildCategory(String name, IconData icon) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.teal[800]),
          const SizedBox(height: 5),
          Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildMedicineItem(String name, String desc, String price) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
        trailing: Text(price, style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
        onTap: () {},
      ),
    );
  }
}
