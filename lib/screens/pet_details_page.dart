import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/pet.dart';
import '../services/supabase_service.dart';
import '../providers/theme_provider.dart';
import 'edit_pet_page.dart';

class PetDetailsPage extends StatefulWidget {
  final String petId;

  const PetDetailsPage({
    Key? key,
    required this.petId,
  }) : super(key: key);

  @override
  State<PetDetailsPage> createState() => _PetDetailsPageState();
}

class _PetDetailsPageState extends State<PetDetailsPage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Pet? _pet;
  String? _errorMessage;
  late TabController _tabController;
  final Color themeColor = const Color.fromARGB(255, 40, 108, 100);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadPetDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPetDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      final petsData = await supabaseService.getUserPets();
      
      final petData = petsData.firstWhere(
        (pet) => pet['id'] == widget.petId,
        orElse: () => throw Exception('Pet not found'),
      );
      
      setState(() {
        _pet = Pet.fromJson(petData);
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading pet details: $e');
      setState(() {
        _errorMessage = 'Failed to load pet details: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePet() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Pet'),
        content: Text('Are you sure you want to delete ${_pet?.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      try {
        final supabaseService = Provider.of<SupabaseService>(context, listen: false);
        await supabaseService.deletePet(widget.petId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${_pet?.name} deleted successfully')),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error deleting pet: $e');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete pet: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Scaffold(
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: themeColor))
          : _errorMessage != null
              ? _buildErrorView()
              : _pet == null
                  ? Center(child: Text('Pet not found'))
                  : _buildPetDetails(isDarkMode),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPetDetails,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetDetails(bool isDarkMode) {
    return CustomScrollView(
      slivers: [
        // App bar with pet image
        SliverAppBar(
          expandedHeight: 250,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _pet!.imageUrl.isNotEmpty
                ? Image.network(
                    _pet!.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                        child: Icon(
                          _pet!.getSpeciesIcon(),
                          size: 80,
                          color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                        ),
                      );
                    },
                  )
                : Container(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                    child: Icon(
                      _pet!.getSpeciesIcon(),
                      size: 80,
                      color: isDarkMode ? Colors.grey[600] : Colors.grey[400],
                    ),
                  ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPetPage(petId: widget.petId),
                  ),
                ).then((_) => _loadPetDetails());
              },
              tooltip: 'Edit Pet',
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deletePet,
              tooltip: 'Delete Pet',
            ),
          ],
        ),
        
        // Pet information
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Pet name and basic info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _pet!.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_pet!.breed} · ${_pet!.age} old',
                            style: TextStyle(
                              fontSize: 16,
                              color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _pet!.getSpeciesIcon(),
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _pet!.species,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Pet characteristics
                _buildInfoRow(
                  title: 'Birth Date',
                  value: DateFormat('MMMM dd, yyyy').format(_pet!.birthDate),
                  icon: Icons.calendar_today,
                  isDarkMode: isDarkMode,
                ),
                const Divider(),
                _buildInfoRow(
                  title: 'Gender',
                  value: _pet!.gender,
                  icon: _pet!.gender == 'Male' ? Icons.male : Icons.female,
                  isDarkMode: isDarkMode,
                ),
                const Divider(),
                _buildInfoRow(
                  title: 'Weight',
                  value: '${_pet!.weight} kg',
                  icon: Icons.monitor_weight_outlined,
                  isDarkMode: isDarkMode,
                ),
                const Divider(),
                _buildInfoRow(
                  title: 'Color',
                  value: _pet!.color,
                  icon: Icons.color_lens_outlined,
                  isDarkMode: isDarkMode,
                ),
                const Divider(),
                _buildInfoRow(
                  title: 'Neutered/Spayed',
                  value: _pet!.isNeutered ? 'Yes' : 'No',
                  icon: Icons.medical_services_outlined,
                  isDarkMode: isDarkMode,
                ),
                if (_pet!.notes.isNotEmpty) ...[
                  const Divider(),
                  _buildInfoRow(
                    title: 'Notes',
                    value: _pet!.notes,
                    icon: Icons.note_outlined,
                    isDarkMode: isDarkMode,
                  ),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        
        // Tab bar
        SliverPersistentHeader(
          delegate: _SliverAppBarDelegate(
            TabBar(
              controller: _tabController,
              labelColor: themeColor,
              unselectedLabelColor: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              indicatorColor: themeColor,
              tabs: const [
                Tab(text: 'Vaccinations'),
                Tab(text: 'Medical Records'),
                Tab(text: 'Photos'),
              ],
            ),
          ),
          pinned: true,
        ),
        
        // Tab content
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildVaccinationsTab(isDarkMode),
              _buildMedicalRecordsTab(isDarkMode),
              _buildPhotosTab(isDarkMode),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String title,
    required String value,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: themeColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationsTab(bool isDarkMode) {
    if (_pet!.vaccinations.isEmpty) {
      return _buildEmptyTabContent(
        icon: Icons.vaccines_outlined,
        message: 'No vaccinations recorded',
        buttonText: 'Add Vaccination',
        onPressed: () {
          // TODO: Implement add vaccination functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add vaccination feature coming soon')),
          );
        },
        isDarkMode: isDarkMode,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pet!.vaccinations.length,
      itemBuilder: (context, index) {
        final vaccination = _pet!.vaccinations[index];
        final date = DateTime.parse(vaccination['date']);
        final nextDue = DateTime.parse(vaccination['next_due']);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.vaccines_outlined,
                        color: themeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        vaccination['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildVaccinationInfoRow(
                  title: 'Date',
                  value: DateFormat('MMM dd, yyyy').format(date),
                  icon: Icons.calendar_today,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 8),
                _buildVaccinationInfoRow(
                  title: 'Next Due',
                  value: DateFormat('MMM dd, yyyy').format(nextDue),
                  icon: Icons.event_repeat,
                  isDarkMode: isDarkMode,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVaccinationInfoRow({
    required String title,
    required String value,
    required IconData icon,
    required bool isDarkMode,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        const SizedBox(width: 8),
        Text(
          '$title: ',
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMedicalRecordsTab(bool isDarkMode) {
    if (_pet!.medicalRecords.isEmpty) {
      return _buildEmptyTabContent(
        icon: Icons.medical_services_outlined,
        message: 'No medical records',
        buttonText: 'Add Medical Record',
        onPressed: () {
          // TODO: Implement add medical record functionality
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add medical record feature coming soon')),
          );
        },
        isDarkMode: isDarkMode,
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pet!.medicalRecords.length,
      itemBuilder: (context, index) {
        final record = _pet!.medicalRecords[index];
        final date = DateTime.parse(record['date']);
        
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.medical_services_outlined,
                        color: themeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            record['type'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('MMMM dd, yyyy').format(date),
                            style: TextStyle(
                              fontSize: 14,
                              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (record['notes'] != null && record['notes'].isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Notes:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    record['notes'],
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotosTab(bool isDarkMode) {
    // For now, just show a placeholder
    return _buildEmptyTabContent(
      icon: Icons.photo_library_outlined,
      message: 'No photos added yet',
      buttonText: 'Add Photos',
      onPressed: () {
        // TODO: Implement add photos functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add photos feature coming soon')),
        );
      },
      isDarkMode: isDarkMode,
    );
  }

  Widget _buildEmptyTabContent({
    required IconData icon,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
    required bool isDarkMode,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: themeColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 60,
                color: themeColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Container(
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
} 