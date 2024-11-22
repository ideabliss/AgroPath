import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SaveAddressesFarmerScreen extends StatefulWidget {
  const SaveAddressesFarmerScreen({super.key, required addressId});

  @override
  _SaveAddressesScreenState createState() => _SaveAddressesScreenState();
}

class _SaveAddressesScreenState extends State<SaveAddressesFarmerScreen> {
  bool isEditing = false; // Track if the user is editing an existing address
  bool isLoadingLocation = false;

  final _formKey = GlobalKey<FormState>();
  final Map<String, String> newAddress = {
    'buildingName': '',
    'cityStateZip': '',
    'country': '',
    'recipientName': '',
    'contact': '',
  };

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  // Fetch the saved address from Firestore
  Future<void> _loadSavedAddress() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('farmers')
          .doc(user.uid)
          .get();

      final userData = snapshot.data();
      final Map<String, dynamic>? addressData = userData?['address'];

      if (addressData != null) {
        setState(() {
          isEditing = true;
          newAddress['recipientName'] = addressData['recipientName'] ?? '';
          newAddress['contact'] = addressData['contact'] ?? '';
          newAddress['buildingName'] = addressData['buildingName'] ?? '';
          newAddress['cityStateZip'] = addressData['cityStateZip'] ?? '';
          newAddress['country'] = addressData['country'] ?? '';
        });
      }
    }
  }

  // Save or update address in Firestore
  Future<void> saveAddress() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        try {
          final address = {
            'recipientName': newAddress['recipientName'],
            'contact': newAddress['contact'],
            'buildingName': newAddress['buildingName'],
            'cityStateZip': newAddress['cityStateZip'],
            'country': newAddress['country'],
          };

          // Update address in Firestore
          await FirebaseFirestore.instance
              .collection('farmers')
              .doc(user.uid)
              .update({
            'address': address,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Address saved/updated successfully!')),
          );
          setState(() {
            isEditing = false;
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving/updating address: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Address'),
        backgroundColor: Color(0xFFA5DAA3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isEditing
            ? buildAddressForm()
            : Center(child: Text('No address saved yet')),
      ),
      floatingActionButton: !isEditing
          ? FloatingActionButton(
              backgroundColor: Color(0xFFA5DAA3),
              onPressed: () {
                setState(() {
                  isEditing = true; // Start editing the address
                });
              },
              child: Icon(Icons.add),
            )
          : null,
    );
  }

  // Form to add or edit address
  Widget buildAddressForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            buildInputContainer(
              label: 'Recipient Name',
              initialValue: newAddress['recipientName'],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the recipient name';
                }
                return null;
              },
              onSaved: (value) {
                newAddress['recipientName'] = value!;
              },
            ),
            buildInputContainer(
              label: 'Contact',
              initialValue: newAddress['contact'],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a contact number';
                }
                return null;
              },
              onSaved: (value) {
                newAddress['contact'] = value!;
              },
            ),
            buildInputContainer(
              label: 'Building Name',
              initialValue: newAddress['buildingName'],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Building Name';
                }
                return null;
              },
              onSaved: (value) {
                newAddress['buildingName'] = value!;
              },
            ),
            buildInputContainer(
              label: 'City, State, Zip',
              initialValue: newAddress['cityStateZip'],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter City, State, Zip';
                }
                return null;
              },
              onSaved: (value) {
                newAddress['cityStateZip'] = value!;
              },
            ),
            buildInputContainer(
              label: 'Country',
              initialValue: newAddress['country'],
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Country';
                }
                return null;
              },
              onSaved: (value) {
                newAddress['country'] = value!;
              },
            ),
            Padding(
  padding: const EdgeInsets.symmetric(vertical: 16.0),
  child: ElevatedButton(
    onPressed: saveAddress,  // Trigger saveAddress action when pressed
    style: ElevatedButton.styleFrom(
       backgroundColor: Color(0xFFA5DAA3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners for a smooth look
      ),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15), // Adjusted padding for balance
      elevation: 5, // Adds a subtle 3D effect
      shadowColor: Color(0xFF4A8E3A), // Shadow color to match the button color
      textStyle: TextStyle(
        fontSize: 16, // Font size for readability
        fontWeight: FontWeight.bold, // Bold text for emphasis
      ),
    ),
    child: Text(
      isEditing ? 'Update Address' : 'Save Address', // Conditional button text based on isEditing
    ),
  ),
),

            if (isLoadingLocation) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  // Helper function for form input containers
  Widget buildInputContainer({
    required String label,
    String? initialValue,
    required String? Function(dynamic value) validator,
    required void Function(dynamic value) onSaved,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
