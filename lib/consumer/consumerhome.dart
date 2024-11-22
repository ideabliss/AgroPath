import 'package:agropath/consumer/fertilizer.dart';
import 'package:agropath/consumer/fruits.dart';
import 'package:agropath/consumer/view.dart';
import 'package:agropath/consumer/viewproduct.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:agropath/consumer/cart.dart';
import 'package:agropath/consumer/profile.dart';
import 'package:agropath/consumer/consumerbottom.dart';
import 'package:agropath/cartprovider.dart';
import 'package:provider/provider.dart'; 

class ConsumerHome extends StatefulWidget {
  const ConsumerHome({super.key});

  @override
  _ConsumerHomeState createState() => _ConsumerHomeState();
}

class _ConsumerHomeState extends State<ConsumerHome> {
  int _currentTabIndex = 0;

  final List<Widget> _screens = [
    ConsumerHomeContent(
      images: [
        'assets/logo/farmer.png',
        'assets/logo/farmer2.jpg',
        'assets/logo/farmer3.jpg',
      ],
      addToCart: (crop) {
        print('Added to cart: ${crop['productName']}');
      },
    ),
    const FertilizerScreen(),
     CartScreen(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

   @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CartProvider(),  // Provide the CartProvider to the widget tree
      child: Scaffold(
        backgroundColor: Colors.white,
        body: IndexedStack(
          index: _currentTabIndex,
          children: _screens,
        ),
        bottomNavigationBar: ConsumerBottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: _onTabTapped,
        ),
      ),
    );
  }
}
class ConsumerHomeContent extends StatefulWidget {
  final List<String> images;
  final Function(Map<String, dynamic>) addToCart;

  const ConsumerHomeContent({
    super.key,
    required this.images,
    required this.addToCart,
  });

  @override
  _ConsumerHomeContentState createState() => _ConsumerHomeContentState();
}
class _ConsumerHomeContentState extends State<ConsumerHomeContent> {
  final PageController _pageController = PageController();
  int _currentImageIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
@override
Widget build(BuildContext context) {
  final List<Map<String, String>> categories = [
    {'image': 'assets/logo/fruits.png', 'name': 'Fruits'},
    {'image': 'assets/logo/vegetable.png', 'name': 'Vegetables'},
    {'image': 'assets/logo/grains.jpg', 'name': 'Grains'},
    {'image': 'assets/logo/flowers.png', 'name': 'Flowers'},
    {'image': 'assets/logo/fertilizers.jpg', 'name': 'Fertilizers'},
    {'image': 'assets/logo/others.png', 'name': 'Other'},
  ];

  return Column(
    children: [
      // Search bar
            const SizedBox(height: 20),

      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              hintText: 'Search',
              contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
              border: InputBorder.none,
            ),
            onChanged: (query) {
              setState(() {
                _searchQuery = query;
              });
            },
          ),
        ),
      ),
      const SizedBox(height: 10),

      // Carousel Slider
      ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: SizedBox(
          height: 175,
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
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Image.asset(
                  widget.images[index],
                  fit: BoxFit.cover,
                ),
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
              width: 8.0,
              height: 8.0,
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
      const SizedBox(height: 8.0),

      // Categories Section
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              'Categories',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // Categories Scroll
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CategoryScreen(categoryName: category['name']!),
                  ),
                );
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                height: 35,
                width: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Image.asset(
                          category['image']!,
                          height: 27,
                          width: 27,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          category['name']!,
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),

      const SizedBox(height: 5),

      // Products Section with Flexible
      Flexible(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('crops')
                .where('productName', isGreaterThanOrEqualTo: _searchQuery)
                .where('productName', isLessThanOrEqualTo: '$_searchQuery\uf8ff')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text('Something went wrong'));
              }

              final crops = snapshot.data!.docs;
return GridView.builder(
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 16.0,
    mainAxisSpacing: 16.0,
    childAspectRatio: 0.7,
  ),
  itemCount: crops.length,
  itemBuilder: (context, index) {
    final data = crops[index].data() as Map<String, dynamic>;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailScreen(productId: crops[index].id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: Image.network(
                data['images'][0],
                height: 120.0,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            // Product Name
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                data['productName'],
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Product Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                '₹${data['price']}',
                style: const TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.green,
                ),
              ),
            ),

            // Product Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Text(
                data['description'],
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Product Category
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                'Category: ${data['category']}',
                style: const TextStyle(
                  fontSize: 12.0,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  },
);

            },
          ),
        ),
      ),
    ],
  );
}
}