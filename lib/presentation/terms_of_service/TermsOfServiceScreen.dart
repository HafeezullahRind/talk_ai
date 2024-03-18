import 'package:flutter/material.dart';

class TermsOfServiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Terms of Service',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'By using Talk AI, you agree to comply with these terms. If you do not agree with any part of the terms, you may not use Talk AI.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'User Conduct',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'You agree to use Talk AI responsibly and refrain from engaging in any unlawful or harmful activities.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Limitation of Liability',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'We are not liable for any damages arising from the use or inability to use Talk AI, including but not limited to direct, indirect, incidental, or consequential damages.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            // Add more sections as needed...
          ],
        ),
      ),
    );
  }
}
