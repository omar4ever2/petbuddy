class VaccineAppointment {
  final String id;
  final String userId;
  final String petName;
  final String petType;
  final DateTime appointmentDate;
  final String vaccineType;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String? notes;
  final DateTime createdAt;

  VaccineAppointment({
    required this.id,
    required this.userId,
    required this.petName,
    required this.petType,
    required this.appointmentDate,
    required this.vaccineType,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory VaccineAppointment.fromJson(Map<String, dynamic> json) {
    return VaccineAppointment(
      id: json['id'],
      userId: json['user_id'],
      petName: json['pet_name'],
      petType: json['pet_type'],
      appointmentDate: DateTime.parse(json['appointment_date']),
      vaccineType: json['vaccine_type'],
      status: json['status'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pet_name': petName,
      'pet_type': petType,
      'appointment_date': appointmentDate.toIso8601String(),
      'vaccine_type': vaccineType,
      'status': status,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 