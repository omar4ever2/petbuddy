import 'package:flutter/material.dart';

class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final DateTime birthDate;
  final double weight;
  final String gender;
  final String imageUrl;
  final String color;
  final bool isNeutered;
  final List<Map<String, dynamic>> vaccinations;
  final List<Map<String, dynamic>> medicalRecords;
  final String notes;

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.birthDate,
    required this.weight,
    required this.gender,
    required this.imageUrl,
    required this.color,
    required this.isNeutered,
    required this.vaccinations,
    required this.medicalRecords,
    this.notes = '',
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      species: json['species'] ?? '',
      breed: json['breed'] ?? '',
      birthDate: json['birth_date'] != null 
          ? DateTime.parse(json['birth_date']) 
          : DateTime.now().subtract(const Duration(days: 365)),
      weight: (json['weight'] ?? 0.0).toDouble(),
      gender: json['gender'] ?? '',
      imageUrl: json['image_url'] ?? '',
      color: json['color'] ?? '',
      isNeutered: json['is_neutered'] ?? false,
      vaccinations: json['vaccinations'] != null 
          ? List<Map<String, dynamic>>.from(json['vaccinations']) 
          : [],
      medicalRecords: json['medical_records'] != null 
          ? List<Map<String, dynamic>>.from(json['medical_records']) 
          : [],
      notes: json['notes'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'birth_date': birthDate.toIso8601String(),
      'weight': weight,
      'gender': gender,
      'image_url': imageUrl,
      'color': color,
      'is_neutered': isNeutered,
      'vaccinations': vaccinations,
      'medical_records': medicalRecords,
      'notes': notes,
    };
  }

  // Calculate age in years and months
  String get age {
    final now = DateTime.now();
    final years = now.year - birthDate.year;
    final months = now.month - birthDate.month;
    
    if (years > 0) {
      return '$years ${years == 1 ? 'year' : 'years'}';
    } else {
      return '$months ${months == 1 ? 'month' : 'months'}';
    }
  }

  // Get appropriate icon for pet species
  IconData getSpeciesIcon() {
    switch (species.toLowerCase()) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.catching_pokemon;
      case 'bird':
        return Icons.flutter_dash;
      case 'fish':
        return Icons.water;
      case 'rabbit':
        return Icons.cruelty_free;
      case 'hamster':
        return Icons.pest_control_rodent;
      default:
        return Icons.pets;
    }
  }

  // Get color for pet species
  Color getSpeciesColor() {
    switch (species.toLowerCase()) {
      case 'dog':
        return Colors.brown;
      case 'cat':
        return Colors.orange;
      case 'bird':
        return Colors.blue;
      case 'fish':
        return Colors.lightBlue;
      case 'rabbit':
        return Colors.grey;
      case 'hamster':
        return Colors.amber;
      default:
        return Colors.teal;
    }
  }
} 