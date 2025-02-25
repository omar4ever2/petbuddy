class AdoptablePet {
  final String id;
  final String name;
  final String species;
  final String? breed;
  final int? ageYears;
  final int? ageMonths;
  final String? gender;
  final String? size;
  final String? description;
  final String? imageUrl;
  final bool isVaccinated;
  final bool isNeutered;
  final bool isHouseTrained;
  final bool isFeatured;
  final double? adoptionFee;
  final String? contactEmail;
  final String? contactPhone;
  final String? location;

  AdoptablePet({
    required this.id,
    required this.name,
    required this.species,
    this.breed,
    this.ageYears,
    this.ageMonths,
    this.gender,
    this.size,
    this.description,
    this.imageUrl,
    this.isVaccinated = false,
    this.isNeutered = false,
    this.isHouseTrained = false,
    this.isFeatured = false,
    this.adoptionFee,
    this.contactEmail,
    this.contactPhone,
    this.location,
  });

  factory AdoptablePet.fromJson(Map<String, dynamic> json) {
    return AdoptablePet(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'],
      ageYears: json['age_years'],
      ageMonths: json['age_months'],
      gender: json['gender'],
      size: json['size'],
      description: json['description'],
      imageUrl: json['image_url'],
      isVaccinated: json['is_vaccinated'] ?? false,
      isNeutered: json['is_neutered'] ?? false,
      isHouseTrained: json['is_house_trained'] ?? false,
      isFeatured: json['is_featured'] ?? false,
      adoptionFee: json['adoption_fee'] != null ? (json['adoption_fee'] as num).toDouble() : null,
      contactEmail: json['contact_email'],
      contactPhone: json['contact_phone'],
      location: json['location'],
    );
  }

  String get ageText {
    if (ageYears == null && ageMonths == null) return 'Unknown age';
    
    final years = ageYears != null && ageYears! > 0 
        ? '${ageYears} ${ageYears == 1 ? 'year' : 'years'}' 
        : '';
    
    final months = ageMonths != null && ageMonths! > 0 
        ? '${ageMonths} ${ageMonths == 1 ? 'month' : 'months'}' 
        : '';
    
    if (years.isNotEmpty && months.isNotEmpty) {
      return '$years, $months';
    } else if (years.isNotEmpty) {
      return years;
    } else {
      return months;
    }
  }
} 