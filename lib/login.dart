import 'package:agropath/consumer/consumerhome.dart';
import 'package:agropath/consumer/forgetpassword.dart';
import 'package:agropath/farmer/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? selectedRole;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Method to handle login and role-based redirection with email verification
  Future<void> _handleLogin() async {
    final email = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a role')),
      );
      return;
    }

    try {
      // Authenticate the user
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      
      // Check if email is verified
      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please verify your email to log in.')),
        );
        return;
      }

      // Fetch the user's role from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection(selectedRole == 'farmer' ? 'farmers' : 'consumers')
          .doc(user?.uid)
          .get();

      if (userDoc.exists) {
        String role = userDoc['role'];

        // Role-based navigation and validation
        if (role == selectedRole) {
          if (role == 'farmer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()), // Navigate to FarmerHome
            );
          } else if (role == 'consumer') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ConsumerHome()), // Navigate to ConsumerHome
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Role does not match the selected role')),
          );
        }
      }
    } catch (e) {
      print("Login Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to login. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 5.0, bottom: 20.0),
                child: Image.asset(
                  'assets/logo/Logoimage.png',
                  height: 130,
                  width: 260,
                ),
              ),
              Container(
                width: 300,
                height: 340,
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFA5DAA3)),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFA5DAA3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFA5DAA3),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFA5DAA3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFA5DAA3),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Select Role',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(
        color: Color(0xFFA5DAA3),
                          
                          ),
                        ),
                        
                      ),
                      
                      items: const [
                        DropdownMenuItem<String>(
                          value: 'farmer',
                          child: Text('Farmer'),
                        ),
                        DropdownMenuItem<String>(
                          value: 'consumer',
                          child: Text('Consumer'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await _handleLogin();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA5DAA3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                      ),
                      child: const Text(
                        'Login',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgetPasswordScreen(),
                      ),
                    );
                          // Navigate to the Forgot Password screen
                          // You can add the Forgot Password functionality here
                          
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color.fromARGB(255, 57, 151, 251),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don’t have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Signup()),
                      );
                    },
                    child: const Text(
                      "Sign up",
                      style: TextStyle(
                        color: Color.fromARGB(255, 57, 151, 251),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
