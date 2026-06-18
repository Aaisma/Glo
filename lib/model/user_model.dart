class UserModel {
  final String id;
  final String name;
<<<<<<< HEAD
  final String? email;
  final String? phone;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.imageUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      name: data['name'] ?? '',
      email: data['email'],
      phone: data['phone'],
      imageUrl: data['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
    };
  }
=======
  final String? contact;
  final String email;
  final String? ageGroup;
  final String? skinType;
  final List<String>? goals;
  final bool surveyCompleted;

  // New Survey Fields
  final int? actualAge;
  final double? bmi;
  final double? waterGoal;
  final DateTime? lastCycleDate;
  final List<String>? acneTypes;
  final bool? usesMedication;
  final String? medicationType; // Oral, Topical, Both
  final String? medicationTime; // AM, PM, Both
  final bool? visitsDerma;
  final DateTime? lastDermaVisit;

  const UserModel({
    required this.id,
    required this.name,
    this.contact,
    required this.email,
    this.ageGroup,
    this.skinType,
    this.goals,
    this.surveyCompleted = false,
    this.actualAge,
    this.bmi,
    this.waterGoal,
    this.lastCycleDate,
    this.acneTypes,
    this.usesMedication,
    this.medicationType,
    this.medicationTime,
    this.visitsDerma,
    this.lastDermaVisit,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contact': contact,
      'email': email,
      'ageGroup': ageGroup,
      'skinType': skinType,
      'goals': goals,
      'surveyCompleted': surveyCompleted,
      'actualAge': actualAge,
      'bmi': bmi,
      'waterGoal': waterGoal,
      'lastCycleDate': lastCycleDate?.toIso8601String(),
      'acneTypes': acneTypes,
      'usesMedication': usesMedication,
      'medicationType': medicationType,
      'medicationTime': medicationTime,
      'visitsDerma': visitsDerma,
      'lastDermaVisit': lastDermaVisit?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      name: map['name'] as String,
      contact: map['contact'] as String?,
      email: map['email'] as String,
      ageGroup: map['ageGroup'] == 'N/A' ? null : map['ageGroup'] as String?,
      skinType: map['skinType'] == 'N/A' ? null : map['skinType'] as String?,
      goals: map['goals'] != null
          ? List<String>.from(map['goals']).where((e) => e != 'N/A').toList()
          : null,
      surveyCompleted: map['surveyCompleted'] as bool? ?? false,
      actualAge: (map['actualAge'] is int) ? map['actualAge'] as int : null,
      bmi: (map['bmi'] is num) ? (map['bmi'] as num).toDouble() : null,
      waterGoal: (map['waterGoal'] is num) ? (map['waterGoal'] as num).toDouble() : null,
      lastCycleDate: (map['lastCycleDate'] != null && map['lastCycleDate'] != 'N/A')
          ? DateTime.tryParse(map['lastCycleDate'] as String)
          : null,
      acneTypes: map['acneTypes'] != null
          ? List<String>.from(map['acneTypes']).where((e) => e != 'N/A').toList()
          : null,
      usesMedication: (map['usesMedication'] is bool) ? map['usesMedication'] as bool : null,
      medicationType: map['medicationType'] == 'N/A' ? null : map['medicationType'] as String?,
      medicationTime: map['medicationTime'] == 'N/A' ? null : map['medicationTime'] as String?,
      visitsDerma: (map['visitsDerma'] is bool) ? map['visitsDerma'] as bool : null,
      lastDermaVisit: (map['lastDermaVisit'] != null && map['lastDermaVisit'] != 'N/A')
          ? DateTime.tryParse(map['lastDermaVisit'] as String)
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? contact,
    String? email,
    String? ageGroup,
    String? skinType,
    List<String>? goals,
    bool? surveyCompleted,
    int? actualAge,
    double? bmi,
    double? waterGoal,
    DateTime? lastCycleDate,
    List<String>? acneTypes,
    bool? usesMedication,
    String? medicationType,
    String? medicationTime,
    bool? visitsDerma,
    DateTime? lastDermaVisit,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      ageGroup: ageGroup ?? this.ageGroup,
      skinType: skinType ?? this.skinType,
      goals: goals ?? this.goals,
      surveyCompleted: surveyCompleted ?? this.surveyCompleted,
      actualAge: actualAge ?? this.actualAge,
      bmi: bmi ?? this.bmi,
      waterGoal: waterGoal ?? this.waterGoal,
      lastCycleDate: lastCycleDate ?? this.lastCycleDate,
      acneTypes: acneTypes ?? this.acneTypes,
      usesMedication: usesMedication ?? this.usesMedication,
      medicationType: medicationType ?? this.medicationType,
      medicationTime: medicationTime ?? this.medicationTime,
      visitsDerma: visitsDerma ?? this.visitsDerma,
      lastDermaVisit: lastDermaVisit ?? this.lastDermaVisit,
    );
  }
>>>>>>> pranisha_branch
}
