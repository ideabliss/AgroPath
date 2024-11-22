import 'package:flutter/material.dart';

class FertilizerTab extends StatefulWidget {
  const FertilizerTab({super.key});

  @override
  State<FertilizerTab> createState() => _FertilizerTabState();
}

class _FertilizerTabState extends State<FertilizerTab> {
  final List<String> fertilizerNames = [
    'Nitrogen Fertilizer',
    'Organic Fertilizer',
    'Potassium Fertilizer',
    'Phosphorus Fertilizer'
  ];

  final List<String> imagePaths = [
    'assets/logo/nitrogen.png',
    'assets/logo/organic.png',
    'assets/logo/pottasium.png',
    'assets/logo/Phosphorus.png',
  ];

  final List<String> fertilizerDescriptions = [
    ''' Nitrogen makes up more than 78 percent of Earth’s atmosphere and is therefore considered to be a non-renewable natural resource. Without an alternative, we have no choice but to use its finite resources for agriculture.
    
    Nitrogen fertilizers are one of the most common fertilizers used nowadays. Fertilizer acts as food for plants, and nitrogen-based compounds are usually the cheapest and most common. Nitrogen fertilizers vary depending on the crops, but they generally range from 26% to 32%. Some types of nitrogen compounds include urea and ammonium nitrate. This fertilizer is primarily used for non-legume crops such as corn, as legume plants can extract nitrogen from the air.''',
    '''Organic fertilizers are derived from natural sources, contributing to sustainable agriculture. These fertilizers come from organic matter, including plant, animal, or mineral sources, and enrich soil by providing essential nutrients without depleting non-renewable resources.

    Organic fertilizers include materials like manure, compost, bone meal, and fish emulsion, which enhance soil structure and promote beneficial microbial activity. These fertilizers release nutrients slowly, supporting long-term soil health.''',
    'Potassium fertilizers improve crop resistance to disease, enhance drought tolerance, and support healthy growth.',
    'Phosphorus fertilizers are critical for root development and flowering in plants, aiding energy transfer and boosting overall plant health.',
  ];

  void _navigateToDetail(String fertilizerName, String imagePath, String description) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FertilizerDetailScreen(
          fertilizerName: fertilizerName,
          imagePath: imagePath,
          description: description,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255), // Light background color
      appBar: AppBar(
        backgroundColor: Color(0xFFA5DAA3), // New theme color
        title: Text(
          'Fertilizers',
          style: TextStyle(
            fontFamily: 'ProtestStrike',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E5B3D),
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: List.generate(fertilizerNames.length, (index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal:10 ),
                child: GestureDetector(
                  onTap: () => _navigateToDetail(
                    fertilizerNames[index],
                    imagePaths[index],
                    fertilizerDescriptions[index],
                  ),
                  child: Card(
                    elevation: 6,
                    shadowColor: Colors.black.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      height: 150,
                      width: 400,
                      decoration: BoxDecoration(
                        color: Color(0xFF6BBF72),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.asset(
                                imagePaths[index],
                                height: 120,
                                width: 160,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                fertilizerNames[index],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class FertilizerDetailScreen extends StatelessWidget {
  final String fertilizerName;
  final String imagePath;
  final String description;

  const FertilizerDetailScreen({
    super.key,
    required this.fertilizerName,
    required this.imagePath,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF0F8F1),
      appBar: AppBar(
        backgroundColor: Color(0xFFA5DAA3), // Theme color
        title: Text(fertilizerName),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  imagePath,
                  height: 250,
                  width: 250,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              fertilizerName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E5B3D),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
