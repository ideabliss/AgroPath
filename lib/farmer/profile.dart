import 'package:agropath/consumer/secruity.dart';
import 'package:agropath/consumer/termsconsumer.dart';
import 'package:agropath/farmer/editprofilefarmer.dart';
import 'package:agropath/farmer/farmeraddress.dart';
import 'package:agropath/farmer/viewproductrequest.dart';
import 'package:agropath/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> _fetchUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot farmerDoc = await _firestore.collection('farmers').doc(user.uid).get();
        if (farmerDoc.exists) {
          return farmerDoc['username'] ?? 'User';
        }
        DocumentSnapshot consumerDoc = await _firestore.collection('consumers').doc(user.uid).get();
        if (consumerDoc.exists) {
          return consumerDoc['username'] ?? 'User';
        }
      } catch (e) {
        debugPrint("Error fetching username: $e");
      }
    }
    return 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: const Color(0xFFA5DAA3),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Picture and Name
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFA5DAA3).withOpacity(0.2),
              child: Icon(Icons.person, size: 50, color: const Color.fromARGB(255, 188, 233, 187)),
            ),
            const SizedBox(height: 16),
            FutureBuilder<String>(
              future: _fetchUsername(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                }
                return Text(
                  snapshot.data ?? 'User',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
            const SizedBox(height: 30),

            // Profile Options
            Expanded(
              child: ListView(
                children: [
                  _buildProfileOption(
                    icon: Icons.edit,
                    text: 'Edit Profile',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileFarmerScreen()),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.location_city,
                    text: 'Save Address',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SaveAddressesFarmerScreen(addressId: null)),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.security,
                    text: 'Security',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.shopping_cart,
                    text: 'View Purchased Requests',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ViewPurchasedRequestScreen()),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.policy,
                    text: 'Terms & Conditions',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TermsPrivacyLicensesScreen()),
                      );
                    },
                  ),
                  _buildProfileOption(
                    icon: Icons.logout,
                    text: 'Log out',
                    onTap: () async {
                      // Show confirmation dialog before logging out
                      bool? shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Log out'),
                            content: const Text('Are you sure you want to log out?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false); // Cancel logout
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await _auth.signOut();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Login(),
                                    ),
                                  );
                                },
                                child: const Text('Log out'),
                              ),
                            ],
                          );
                        },
                      );

                      // If user presses "Log out", then proceed
                      if (shouldLogout == true) {
                        await _auth.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const Login(),
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Card(
      color: const Color(0xFFF9F9F9), // Light background for profile options
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFA5DAA3)),
        title: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: onTap,
      ),
    );
  }
}
