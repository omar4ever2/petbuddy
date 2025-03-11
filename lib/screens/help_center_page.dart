import 'package:flutter/material.dart';

class HelpCenterPage extends StatelessWidget {
  const HelpCenterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help Center'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSearchBar(),
          const SizedBox(height: 24),
          _buildSectionTitle('Frequently Asked Questions'),
          _buildFaqItem(
            'How do I place an order?',
            'To place an order, browse our products, add items to your cart, and proceed to checkout. Follow the steps to enter your shipping and payment information.',
          ),
          _buildFaqItem(
            'What payment methods do you accept?',
            'We accept credit/debit cards (Visa, Mastercard, American Express), PayPal, and Apple Pay.',
          ),
          _buildFaqItem(
            'How do I track my order?',
            'You can track your order in the "My Orders" section of your profile. Click on the specific order to see its current status and tracking information.',
          ),
          _buildFaqItem(
            'What is your return policy?',
            'We offer a 30-day return policy for most items. Products must be unused and in their original packaging. Some items like food and treats cannot be returned once opened.',
          ),
          _buildFaqItem(
            'How do I adopt a pet?',
            'Browse our adoption section, find a pet you\'re interested in, and click "Adopt". You\'ll need to fill out an application form and our team will contact you for the next steps.',
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Contact Us'),
          _buildContactMethod(
            Icons.email_outlined,
            'Email Us',
            'support@petbuddy.com',
          ),
          _buildContactMethod(
            Icons.phone_outlined,
            'Call Us',
            '+1 (800) 123-4567',
          ),
          _buildContactMethod(
            Icons.chat_outlined,
            'Live Chat',
            'Available 9 AM - 6 PM EST',
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search for help',
        prefixIcon: const Icon(Icons.search),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[200],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethod(IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color.fromARGB(255, 40, 108, 100)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Handle contact method tap
        },
      ),
    );
  }
} 