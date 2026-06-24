import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../utils/language_provider.dart';
import 'book_ride_screen.dart';
import 'tourism_details_screen.dart';
import 'ai_trip_planner_screen.dart';

class TouristScreen extends StatefulWidget {
  const TouristScreen({super.key});

  @override
  State<TouristScreen> createState() => _TouristScreenState();
}

class _TouristScreenState extends State<TouristScreen> {
  final List<Attraction> _featuredAttractions = [
    Attraction(
      name: 'Lake Hawassa',
      category: 'Nature',
      description: 'The heartbeat of the city, famous for its sunsets and boat rides.',
      fullDescription: 'Lake Hawassa is a beautiful endorheic basin in Ethiopia, located in the Main Ethiopian Rift south of Addis Ababa. It is a stunning body of water surrounded by lush greenery and mountains. Visitors can enjoy peaceful boat rides, watch local fishermen at work, and witness some of the most spectacular sunsets in the country. The lake is also home to a diverse range of bird species and aquatic life.',
      imageUrl: 'https://images.unsplash.com/photo-1590059516315-f559648981f2?q=80&w=1000&auto=format&fit=crop',
      gallery: [
        'https://images.unsplash.com/photo-1590059516315-f559648981f2?q=80&w=1000&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1583226305018-b8089456e792?q=80&w=1000&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1589182373726-e4f658ab50f0?q=80&w=1000&auto=format&fit=crop',
      ],
      rating: 4.8,
      visitTime: '2-3 hours',
      openingHours: '24/7 (Best during daylight)',
      tips: ['Take a boat ride to see the hippos', 'Visit during sunset for great photos', 'Carry mosquito repellent'],
      bestTime: 'Late afternoon (4 PM - 6 PM)',
      nearby: ['Fish Market', 'Amora Gedel Park', 'Haile Resort'],
      location: 'City Waterfront, Hawassa',
    ),
    Attraction(
      name: 'Amora Gedel Park',
      category: 'Park',
      description: 'A lush park home to friendly Colobus monkeys and exotic birds.',
      fullDescription: 'Amora Gedel is a beautiful waterfront park located on the shores of Lake Hawassa. It is famous for its large population of Colobus monkeys and various bird species. It is a perfect spot for families and nature lovers to relax, enjoy the lake breeze, and interact with the local wildlife in a safe and serene environment.',
      imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0d/18/88/2c/photo0jpg.jpg?w=1000&h=-1&s=1',
      gallery: [
        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0d/18/88/2c/photo0jpg.jpg?w=1000&h=-1&s=1',
        'https://images.unsplash.com/photo-1540573133985-87b6da6d54a9?q=80&w=1000&auto=format&fit=crop',
      ],
      rating: 4.6,
      visitTime: '1-2 hours',
      openingHours: '8:00 AM - 6:30 PM',
      tips: ['Do not feed the monkeys human food', 'Keep your belongings secure', 'Great for bird watching'],
      bestTime: 'Morning or late afternoon',
      nearby: ['Lake Hawassa', 'Fish Market'],
      location: 'Lakefront Road, Hawassa',
    ),
    Attraction(
      name: 'Tabor Mountain',
      category: 'Adventure',
      description: 'Hike to the top for a panoramic view of the entire city and lake.',
      fullDescription: 'Mount Tabor offers the best vantage point in Hawassa. A moderate hike to the top rewards visitors with a 360-degree view of the city, the lake, and the surrounding Rift Valley landscape. It is a popular spot for both morning exercise and evening relaxation, offering a fresh perspective on the city\'s layout and natural beauty.',
      imageUrl: 'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0f/7d/5a/8e/mount-tabor.jpg?w=1000&h=-1&s=1',
      gallery: [
        'https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0f/7d/5a/8e/mount-tabor.jpg?w=1000&h=-1&s=1',
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=1000&auto=format&fit=crop',
      ],
      rating: 4.7,
      visitTime: '2-4 hours',
      openingHours: 'Accessible at all times',
      tips: ['Wear comfortable hiking shoes', 'Bring water and snacks', 'Go early in the morning to avoid the heat'],
      bestTime: 'Sunrise (6 AM) or Sunset (5:30 PM)',
      nearby: ['Hawassa University', 'Referral Hospital'],
      location: 'East of City Center, Hawassa',
    ),
    Attraction(
      name: 'Fish Market (Gudumale)',
      category: 'Culture/Food',
      description: 'Experience the local life and taste fresh Tilapia right from the lake.',
      fullDescription: 'The Fish Market is one of Hawassa\'s most vibrant and authentic spots. Every morning, fishermen bring in their catch of Tilapia and Nile Perch. Visitors can watch the bustling activity, see the fish being prepared traditionally, and taste freshly cooked fish at the nearby stalls. It\'s a true immersion into the local Sidama lifestyle.',
      imageUrl: 'https://images.unsplash.com/photo-1534604973900-c41ab4c5e036?q=80&w=1000&auto=format&fit=crop',
      gallery: [
        'https://images.unsplash.com/photo-1534604973900-c41ab4c5e036?q=80&w=1000&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?q=80&w=1000&auto=format&fit=crop',
      ],
      rating: 4.5,
      visitTime: '1 hour',
      openingHours: '6:30 AM - 10:00 AM (Best for market activity)',
      tips: ['Go early to see the boats coming in', 'Try the "Fish Gulash"', 'Be prepared for a busy, raw environment'],
      bestTime: '7:30 AM - 9:00 AM',
      nearby: ['Amora Gedel', 'Lake Hawassa'],
      location: 'Gudumale Waterfront, Hawassa',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildHeroSection(context, lang),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAITripPlannerCard(context, lang),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, _t(lang, 'Popular Attractions', 'ተወዳጅ መስህቦች', 'Popular Attractions'), true),
                  const SizedBox(height: 16),
                  _buildAttractionsGrid(context),
                  const SizedBox(height: 32),
                  _buildSectionHeader(context, _t(lang, 'Explore Gallery', 'ጋለሪ', 'Gallery'), false),
                  const SizedBox(height: 16),
                  _buildGallerySection(),
                  const SizedBox(height: 32),
                  _buildInfoSection(context, lang),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, LanguageProvider lang) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF2E7D32),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1590059516315-f559648981f2?q=80&w=1000&auto=format&fit=crop',
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(lang, 'Discover Hawassa', 'ሀዋሳን ይጎብኙ', 'Hawaasa Doori'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _t(lang, 'Explore the beauty, culture, nature and attractions of Hawassa City.',
                      'የሀዋሳ ከተማን ውበት፣ ባህል፣ ተፈጥሮ እና መስህቦችን ያስሱ።',
                      'Hawaasa katama mido, amanyoote, kalaqonna jiro doora.'),
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _t(LanguageProvider lang, String en, String am, String sid) {
    if (lang.currentLang == 'am') return am;
    if (lang.currentLang == 'sid') return sid;
    return en;
  }

  Widget _buildAITripPlannerCard(BuildContext context, LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF1A237E), Color(0xFF3F51B5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A237E).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
              const SizedBox(width: 12),
              Text(
                _t(lang, 'AI TRIP PLANNER', 'የAI የጉዞ እቅድ', 'AI TRIP PLANNER'),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _t(lang, 'Plan your perfect stay in Hawassa using our smart AI agent.',
              'የእርስዎን ምርጥ ቆይታ በሀዋሳ በስማርት AI ረዳታችን ያቅዱ።',
              'Plan your perfect stay in Hawassa using our smart AI agent.'),
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AITripPlannerScreen())),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF1A237E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(_t(lang, 'START PLANNING', 'እቅድ ይጀምሩ', 'Start Planning')),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, bool showViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32), letterSpacing: 1.2),
        ),
        if (showViewAll)
          TextButton(
            onPressed: () {},
            child: const Text('View All', style: TextStyle(color: Colors.grey)),
          ),
      ],
    );
  }

  Widget _buildAttractionsGrid(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('tourism_sites').snapshots(),
      builder: (context, snapshot) {
        List<Widget> list = _featuredAttractions.map((attr) => _buildAttractionCard(context, attr)).toList();

        if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
          final moreSites = snapshot.data!.docs.map((doc) {
            final s = doc.data() as Map<String, dynamic>;
            return _buildAttractionCard(context, Attraction(
              name: s['name'] ?? 'Site',
              category: s['category'] ?? 'General',
              description: s['description'] ?? '',
              fullDescription: s['description'] ?? '',
              imageUrl: s['imageUrl'] ?? 'https://via.placeholder.com/400',
              gallery: [s['imageUrl'] ?? 'https://via.placeholder.com/400'],
              rating: (s['rating'] ?? 4.5).toDouble(),
              visitTime: s['visitTime'] ?? '1-2 hours',
              openingHours: s['openingHours'] ?? 'Daylight hours',
              tips: s['tips'] != null ? List<String>.from(s['tips']) : ['Enjoy your visit!'],
              bestTime: s['bestTime'] ?? 'Daytime',
              nearby: s['nearby'] != null ? List<String>.from(s['nearby']) : [],
              location: s['location'] ?? 'Hawassa',
            ));
          }).toList();
          list.addAll(moreSites);
        }

        return Column(children: list);
      },
    );
  }

  Widget _buildAttractionCard(BuildContext context, Attraction attr) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  attr.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(attr.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    attr.category,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attr.name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  attr.description,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey, size: 16),
                    const SizedBox(width: 4),
                    Text(attr.visitTime, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TourismDetailsScreen(attraction: attr))),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: const BorderSide(color: Color(0xFF2E7D32)),
                        ),
                        child: const Text('Learn More', style: TextStyle(color: Color(0xFF2E7D32))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookRideScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Book Ride'),
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

  Widget _buildGallerySection() {
    final images = [
      'https://images.unsplash.com/photo-1590059516315-f559648981f2?q=80&w=400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1583226305018-b8089456e792?q=80&w=400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?q=80&w=400&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1534604973900-c41ab4c5e036?q=80&w=400&auto=format&fit=crop',
    ];

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Container(
            width: 120,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(image: NetworkImage(images[index]), fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, LanguageProvider lang) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, _t(lang, 'Travel Information', 'የጉዞ መረጃ', 'Travel Information'), false),
        const SizedBox(height: 16),
        _buildInfoCard(Icons.calendar_month, _t(lang, 'Best Time to Visit', 'ለመጎብኘት ምርጥ ጊዜ', 'Best Time to Visit'), _t(lang, 'October to March is ideal for pleasant weather.', 'ከጥቅምት እስከ መጋቢት ያለው ጊዜ ለተሻለ የአየር ሁኔታ ተመራጭ ነው።', 'October to March is ideal for pleasant weather.')),
        _buildInfoCard(Icons.people, _t(lang, 'Local Culture', 'የአካባቢው ባህል', 'Local Culture'), _t(lang, 'The Sidama people are known for their hospitality and Fichee-Chambalaalla festival.', 'የሲዳማ ህዝብ በእንግዳ ተቀባይነቱ እና በፊቼ ጨምበላላ በዓሉ ይታወቃል።', 'The Sidama people are known for their hospitality and Fichee-Chambalaalla festival.')),
        _buildInfoCard(Icons.lightbulb, _t(lang, 'Tourism Tips', 'የቱሪዝም ምክሮች', 'Tourism Tips'), _t(lang, 'Always carry local currency (ETB) and try the local Sidama coffee.', 'ሁል ጊዜ የአካባቢውን ገንዘብ (ETB) ይያዙ እና የአካባቢውን የሲዳማ ቡና ይቅመሱ።', 'Always carry local currency (ETB) and try the local Sidama coffee.')),
        _buildInfoCard(Icons.security, _t(lang, 'Safety Tips', 'የደህንነት ምክሮች', 'Safety Tips'), _t(lang, 'Hawassa is generally very safe, but avoid walking alone in dark areas at night.', 'ሀዋሳ በአጠቃላይ በጣም አስተማማኝ ናት፣ ነገር ግን በምሽት ጨለማ በሆኑ ቦታዎች ብቻዎን ከመንቀሳቀስ ይቆጠቡ።', 'Hawassa is generally very safe, but avoid walking alone in dark areas at night.')),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
