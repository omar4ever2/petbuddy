import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import '../screens/login_page.dart';
import '../screens/edit_profile_page.dart';
import '../screens/orders_page.dart';
import '../screens/settings_page.dart';
import '../screens/help_center_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;
  Map<String, dynamic>? _profileData;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      
      if (supabaseService.isAuthenticated) {
        final profileData = await supabaseService.getUserProfile();
        setState(() {
          _profileData = profileData;
        });
      }
    } catch (e) {
      print('Error loading profile data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load profile: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabaseService = Provider.of<SupabaseService>(context);
    final isLoggedIn = supabaseService.isAuthenticated;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !isLoggedIn
              ? _buildLoginPrompt()
              : _buildProfileContent(),
    );
  }

  Widget _buildLoginPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.account_circle_outlined,
            size: 80,
            color: Color(0xFF5C6BC0),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sign in to access your profile',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'View orders, manage addresses, and more',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5C6BC0),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent() {
    final username = _profileData?['username'] ?? 'Pet Lover';
    final email = _profileData?['email'] ?? 'user@example.com';
    final avatarUrl = _profileData?['avatar_url'];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile header
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF5C6BC0).withOpacity(0.1),
                    backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl == null || avatarUrl.isEmpty
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFF5C6BC0),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const EditProfilePage()),
                            ).then((_) => _loadProfileData());
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF5C6BC0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(color: Color(0xFF5C6BC0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Account section
          _buildSectionTitle('Account'),
          _buildMenuItems([
            ProfileMenuItem(
              icon: Icons.shopping_bag_outlined,
              title: 'My Orders',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const OrdersPage()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
              onTap: () {
                // Show a temporary message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notifications feature coming soon!')),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.location_on_outlined,
              title: 'Address Book',
              onTap: () {
                // Show a temporary message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Address Book feature coming soon!')),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.credit_card_outlined,
              title: 'Payment Methods',
              onTap: () {
                // Show a temporary message
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Payment Methods feature coming soon!')),
                );
              },
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Preferences section
          _buildSectionTitle('Preferences'),
          _buildMenuItems([
            ProfileMenuItem(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.help_outline,
              title: 'Help Center',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HelpCenterPage()),
                );
              },
            ),
            ProfileMenuItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {
                _showPrivacyPolicy();
              },
            ),
          ]),
          
          const SizedBox(height: 24),
          
          // Sign out button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Sign Out'),
            ),
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  Widget _buildMenuItems(List<ProfileMenuItem> items) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Icon(
              item.icon,
              color: const Color(0xFF5C6BC0),
            ),
            title: Text(item.title),
            trailing: item.trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: item.onTap,
          );
        },
      ),
    );
  }

  Future<void> _updateProfileSetting(String key, dynamic value) async {
    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      await supabaseService.updateUserProfile({key: value});
      
      setState(() {
        if (_profileData != null) {
          _profileData![key] = value;
        } else {
          _profileData = {key: value};
        }
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Settings updated')),
      );
    } catch (e) {
      print('Error updating profile setting: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update setting: $e')),
      );
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'This Privacy Policy describes how your personal information is collected, used, and shared when you use our Pet Buddy app.\n\n'
            'PERSONAL INFORMATION WE COLLECT\n\n'
            'When you use our app, we collect information that you provide to us such as your name, email address, and profile information.\n\n'
            'HOW WE USE YOUR PERSONAL INFORMATION\n\n'
            'We use the information we collect to provide, maintain, and improve our services, including to process transactions, send you related information, and provide customer support.\n\n'
            'SHARING YOUR PERSONAL INFORMATION\n\n'
            'We share your Personal Information with service providers to help us provide our services.\n\n'
            'CHANGES\n\n'
            'We may update this privacy policy from time to time to reflect changes to our practices or for other operational, legal, or regulatory reasons.\n\n'
            'CONTACT US\n\n'
            'For more information about our privacy practices, if you have questions, or if you would like to make a complaint, please contact us by email at privacy@petbuddy.com.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      await supabaseService.signOut();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully')),
      );
      
      // Navigate back to home page
      Navigator.pop(context);
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign out: $e')),
      );
    }
  }
}

class ProfileMenuItem {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  ProfileMenuItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
  });
} 