import 'package:flutter/material.dart';
import '../models/adoptable_pet.dart';
import '../services/supabase_service.dart';
import '../widgets/adoptable_pet_card.dart';
import 'package:provider/provider.dart';

class AdoptionsPage extends StatefulWidget {
  const AdoptionsPage({Key? key}) : super(key: key);

  @override
  State<AdoptionsPage> createState() => _AdoptionsPageState();
}

class _AdoptionsPageState extends State<AdoptionsPage> {
  bool _isLoading = true;
  List<AdoptablePet> _pets = [];
  String _selectedSpecies = 'All';
  final List<String> _speciesOptions = ['All', 'Dog', 'Cat', 'Bird', 'Other'];

  @override
  void initState() {
    super.initState();
    _loadPets();
  }

  Future<void> _loadPets() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      
      List<Map<String, dynamic>> petsData;
      
      if (_selectedSpecies == 'All') {
        petsData = await supabaseService.getAllAdoptablePets();
      } else if (_selectedSpecies == 'Other') {
        petsData = await supabaseService.getAllAdoptablePets();
        petsData = petsData.where((pet) => 
          !['Dog', 'Cat', 'Bird'].contains(pet['species'])
        ).toList();
      } else {
        petsData = await supabaseService.getAdoptablePetsBySpecies(_selectedSpecies);
      }
      
      setState(() {
        _pets = petsData.map((data) => AdoptablePet.fromJson(data)).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading adoptable pets: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Adoptions'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Species filter
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter by species:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _speciesOptions.map((species) {
                      final isSelected = _selectedSpecies == species;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedSpecies = species;
                          });
                          _loadPets();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color.fromARGB(255, 40, 108, 100)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            species,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 1,
            color: Colors.grey[200],
          ),
          
          // Pets list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _pets.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.pets,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No pets found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedSpecies == 'All'
                                  ? 'There are no pets available for adoption at the moment.'
                                  : 'There are no $_selectedSpecies pets available for adoption at the moment.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedSpecies = 'All';
                                });
                                _loadPets();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 40, 108, 100),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text('Show All Pets'),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPets,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _pets.length,
                          itemBuilder: (context, index) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                return SizedBox(
                                  width: constraints.maxWidth,
                                  child: AdoptablePetCard(
                                    pet: _pets[index],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}