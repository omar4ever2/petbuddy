import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_service.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false;

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      await supabaseService.signOut();
      
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supabaseService = Provider.of<SupabaseService>(context);
    final user = supabaseService.currentUser;
    final email = user?.email ?? 'No email available';
    final username = user?.userMetadata?['username'] as String? ?? 'Pet Lover';

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Profile picture
              CircleAvatar(
                radius: 60,
                backgroundColor: const Color(0xFF5C6BC0).withOpacity(0.2),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Color(0xFF5C6BC0),
                ),
              ),
              const SizedBox(height: 16),
              // Username
              Text(
                username,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // Email
              Text(
                email,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32),
              // Profile sections
              _buildProfileSection(
                title: 'Account Information',
                items: [
                  ProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profile',
                    onTap: () {
                      // Navigate to edit profile screen
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Change Password',
                    onTap: () {
                      // Navigate to change password screen
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      // Navigate to notifications settings
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProfileSection(
                title: 'Shopping',
                items: [
                  ProfileMenuItem(
                    icon: Icons.shopping_bag_outlined,
                    title: 'My Orders',
                    onTap: () {
                      // Navigate to orders screen
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.favorite_border,
                    title: 'My Favorites',
                    onTap: () {
                      // Navigate to favorites screen
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.location_on_outlined,
                    title: 'Shipping Addresses',
                    onTap: () {
                      // Navigate to addresses screen
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProfileSection(
                title: 'App Settings',
                items: [
                  ProfileMenuItem(
                    icon: Icons.language,
                    title: 'Language',
                    onTap: () {
                      // Navigate to language settings
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    onTap: () {
                      // Toggle dark mode
                    },
                    trailing: Switch(
                      value: false, // Get from theme provider
                      onChanged: (value) {
                        // Update theme
                      },
                      activeColor: const Color(0xFF5C6BC0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProfileSection(
                title: 'Support',
                items: [
                  ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Help Center',
                    onTap: () {
                      // Navigate to help center
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.info_outline,
                    title: 'About Us',
                    onTap: () {
                      // Navigate to about screen
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Logout button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text(
                              'Logout',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
              // App version
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection({
    required String title,
    required List<ProfileMenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5C6BC0),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) => items[index],
          ),
        ),
      ],
    );
  }
}

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF5C6BC0)),
      title: Text(title),
      trailing: trailing ?? const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
} 