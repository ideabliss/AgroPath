import 'package:agropath/cartprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'consumer/consumerhome.dart';
import 'farmer/home.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {                  
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AuthenticationWrapper(),
      ),
    );
  }
}

class AuthenticationWrapper extends StatelessWidget {
  const AuthenticationWrapper({super.key});

  Future<String?> getUserRole(User user) async {
    try {
      DocumentSnapshot farmerDoc = await FirebaseFirestore.instance
          .collection('farmers')
          .doc(user.uid)
          .get();

      if (farmerDoc.exists) {
        return 'farmer';
      }

      DocumentSnapshot consumerDoc = await FirebaseFirestore.instance
          .collection('consumers')
          .doc(user.uid)
          .get();

      if (consumerDoc.exists) {
        return 'consumer';
      }

      return null;
    } catch (e) {
      debugPrint("Error fetching user role: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // User is logged in
          return FutureBuilder<String?>(
            future: getUserRole(snapshot.data!),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (roleSnapshot.hasError) {
                return const Center(child: Text("Error fetching user role"));
              } else if (roleSnapshot.hasData) {
                if (roleSnapshot.data == 'farmer') {
                  return const HomeScreen(); 
                } else if (roleSnapshot.data == 'consumer') {
                  return const ConsumerHome();
                }
              }
              return const Login();
            },
          );
        } else {
          return const Login();
        }
      },
    );
  }
}
