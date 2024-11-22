import 'package:agropath/consumer/editprofile.dart';
import 'package:agropath/consumer/savedaddress.dart';
import 'package:agropath/consumer/secruity.dart';
import 'package:agropath/consumer/termsconsumer.dart';
import 'package:agropath/consumer/trackorder.dart';
import 'package:agropath/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? username;
  bool isLoading = true; // Track loading state
  final Color themeColor = const Color(0xFFA5DAA3);

  @override
  void initState() {
    super.initState();
    fetchUsername();
  }

  // Function to fetch username from Firestore
  Future<void> fetchUsername() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        var userData = await FirebaseFirestore.instance.collection('consumers').doc(user.uid).get();

        if (userData.exists) {
          setState(() {
            username = userData['username']; // Assuming 'username' field exists
            isLoading = false;
          });
        } else {
          setState(() {
            username = 'No username found'; // Data doesn't exist for this user
            isLoading = false;
          });
        }
      } catch (e) {
        setState(() {
          username = 'Error loading username: $e'; // Error fetching data
          isLoading = false;
        });
      }
    } else {
      setState(() {
        username = 'No user found';
        isLoading = false;
      });
    }
  }

  // Function to handle logout
  Future<void> confirmLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()), // Direct navigation to LoginScreen
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: themeColor,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: themeColor.withOpacity(0.2),
                    child: Icon(Icons.person, size: 50, color: themeColor),
                  ),
                  const SizedBox(height: 10),
                  isLoading
                      ? const CircularProgressIndicator()
                      : Text(
                          username ?? 'No Username',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Profile Options
            _buildSectionTitle("Account Settings"),
            const SizedBox(height: 10),
            ProfileOption(
              icon: Icons.edit,
              text: 'Edit Profile',
              onTap: () {
                // Navigate to EditProfileScreen without routes
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                );
              },
            ),
            ProfileOption(
              icon: Icons.location_on,
              text: 'Saved Addresses',
              onTap: () {
                // Navigate to SavedAddressesScreen directly
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SaveAddressesScreen(addressId: null,)),
                );
              },
            ),
            ProfileOption(
              icon: Icons.security,
              text: 'Security',
              onTap: () {
                // Navigate to ChangePasswordScreen directly
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),

            const SizedBox(height: 20),

            _buildSectionTitle("Other Options"),
            const SizedBox(height: 10),
            ProfileOption(
              icon: Icons.policy,
              text: 'Terms, Policies, and Licenses',
              onTap: () {
                // Navigate to Terms and Policies
                 Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsPrivacyLicensesScreen()),
                );
              },
            ),

            
            ProfileOption(
              icon: Icons.shopping_bag,
              text: 'View Orders',
              onTap: () {
                // Navigate to View Orders
                // Navigate to ChangePasswordScreen directly
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TrackOrderScreen()),
                );
              },
            ),
            ProfileOption(
              icon: Icons.logout,
              text: 'Logout',
              onTap: confirmLogout, // Call the logout confirmation function
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build section title
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black, // Black color for section titles
        ),
      ),
    );
  }
}

// ProfileOption widget for reusable profile menu items
class ProfileOption extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const ProfileOption({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white, // White card background
      elevation: 4, // Shadow for the card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF868889)),
        title: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black, // Black color for text
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black),
        onTap: onTap,
      ),
    );
  }
}
