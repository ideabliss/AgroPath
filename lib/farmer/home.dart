import 'package:agropath/farmer/bottomnavf.dart';
import 'package:agropath/farmer/fertilizer.dart';
import 'package:agropath/farmer/profile.dart';
import 'package:agropath/farmer/viewlisted.dart';
import 'package:agropath/farmer/weather.dart';
import 'package:flutter/material.dart';
import 'addcrop.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _selectedTabIndex = 0;

  late final List<Widget> _screens = [
    HomeTab(
      images: const [
        'assets/logo/farmer.png',
        'assets/logo/farmer2.jpg',
        'assets/logo/farmer3.jpg',
      ],
      onAddCropTap: () {
        setState(() {
          _selectedTabIndex = 2; // Set this to the index of Addcrop
        });
      },
      onTabChange: (index) {
        setState(() {
          _selectedTabIndex = index;
        });
      },
    ),
    const FertilizerTab(),
    const Addcrop(),
    const WeatherTab(),
    const ProfileTab(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_selectedTabIndex],
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _selectedTabIndex,
        onTap: (index) {
          setState(() {
            _selectedTabIndex = index;
          });
        },
      ),
    );
  }
}

class HomeTab extends StatefulWidget {
  final List<String> images;
  final VoidCallback onAddCropTap;
  final Function(int) onTabChange;

  const HomeTab({
    super.key,
    required this.images,
    required this.onAddCropTap,
    required this.onTabChange,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView( // Wrap the Column in a SingleChildScrollView
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 35.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Padding(
                  padding: EdgeInsets.only(left: 5.0),
                  child: Text(
                    'FARMER',
                    style: TextStyle(
                      fontFamily: 'ProtestStrike',
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF008054),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFDFF1E6),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            ClipRRect(
              borderRadius: BorderRadius.circular(15.0),
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Image.asset(
                      widget.images[index],
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    width: 10.0,
                    height: 10.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == index
                          ? const Color(0xFF008054)
                          : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: widget.onAddCropTap,
              child: Container(
                height: 60,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFA5DAA3), Color(0xFF008054)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Add a Crop/Product',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            _buildOptionRow(
              context,
              imagePaths: ['assets/logo/fertilizer.png', 'assets/logo/view producr.jpg'],
              labels: ['Fertilizer', 'View Listed Crop'],
              onTap: [
                () => widget.onTabChange(1), // Fertilizer tab
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyListedCropsScreen()),
                ), // View crops
              ],
            ),
            const SizedBox(height: 15),
            _buildOptionRow(
              context,
              imagePaths: ['assets/logo/weather.png', 'assets/logo/market analysis.png'],
              labels: ['Weather', 'Market Analysis'],
              onTap: [
                () => widget.onTabChange(3), // Weather tab
                () {}, // Market Analysis (placeholder)
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(
    BuildContext context, {
    required List<String> imagePaths,
    required List<String> labels,
    required List<VoidCallback> onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(imagePaths.length, (index) {
        return GestureDetector(
          onTap: onTap[index],
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 160,
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8.0,
                  spreadRadius: 2.0,
                ),
              ],
              image: DecorationImage(
                image: AssetImage(imagePaths[index]),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Greenish overlay on the image
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.green.withOpacity(0.3), // Greenish tint
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 40,
                    width: double.infinity, // Make this container take the full width
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Equal left and right padding
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        labels[index],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
