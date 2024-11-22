import 'package:flutter/material.dart';

class TermsPrivacyLicensesScreen extends StatelessWidget {
  const TermsPrivacyLicensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms & Policies'),
                 backgroundColor: const Color.fromARGB(255, 188, 233, 187),

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Terms & Conditions Section
              const Text(
                'Terms & Conditions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'By using Agropath, you agree to comply with and be bound by the following Terms and Conditions. These terms apply to all users of the application, including consumers, farmers, and other stakeholders. Agropath reserves the right to modify or update these terms at any time. You agree to use the application only for lawful purposes and to avoid engaging in any illegal activities that may violate the terms of service. Agropath is not responsible for any damages, loss, or other liabilities that may arise from the use or inability to use the platform. We may suspend or terminate your access to the platform if we believe you are in breach of these terms. By using the application, you agree to the collection, use, and processing of your personal data in accordance with our Privacy Policy.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.justify,
              ),

              const SizedBox(height: 32),

              // Privacy Policy Section
              const Text(
                'Privacy Policy',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Agropath is committed to protecting your privacy. We collect personal information such as your name, email address, and location to enhance your experience. Your data is used solely for the purpose of improving service delivery and providing personalized content. We do not share your personal information with third parties, except as required by law. We implement industry-standard security measures to protect your information. You have the right to access, modify, or request deletion of your personal data at any time. By using the app, you consent to the collection and use of your personal data as outlined in this Privacy Policy.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.justify,
              ),

              const SizedBox(height: 32),

              // Licenses Section
              const Text(
                'Licenses',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Agropath respects the intellectual property rights of others and expects users to do the same. All content available on the platform, including text, images, logos, and graphics, is protected by copyright and other intellectual property laws. You are granted a limited, non-exclusive, and non-transferable license to use the platform for personal and non-commercial purposes. Any unauthorized use, reproduction, or distribution of the content is prohibited. By using the app, you agree to comply with the applicable laws and respect the rights of third-party content owners.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
