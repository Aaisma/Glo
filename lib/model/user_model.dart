class UserModel {
  final String id;
  final String name;
  final String username;
  final String? contact;
  final String? email;
  final String? phone;
  final String? imageUrl;
  final String? ageGroup;
  final String? skinType;
  final List<String>? goals;
  final bool surveyCompleted;
  final bool profileCompleted;
  final String role;

  // Survey fields
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
    this.username = '',
    this.contact,
    this.email,
    this.phone,
    this.imageUrl,
    this.ageGroup,
    this.skinType,
    this.goals,
    this.surveyCompleted = false,
    this.profileCompleted = false,
    this.role = 'user',
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
      'username': username,
      'contact': contact,
      'email': email,
      'phone': phone,
      'imageUrl': imageUrl,
      'ageGroup': ageGroup,
      'skinType': skinType,
      'goals': goals,
      'surveyCompleted': surveyCompleted,
      'profileCompleted': profileCompleted,
      'role': role,
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

  factory UserModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      contact: map['contact'],
      email: map['email'],
      phone: map['phone'],
      imageUrl: map['imageUrl'],
      ageGroup: map['ageGroup'] == 'N/A' ? null : map['ageGroup'],
      skinType: map['skinType'] == 'N/A' ? null : map['skinType'],
      goals: map['goals'] != null
          ? List<String>.from(map['goals']).where((e) => e != 'N/A').toList()
          : null,
      surveyCompleted: map['surveyCompleted'] as bool? ?? false,
      profileCompleted: map['profileCompleted'] as bool? ?? false,
      role: map['role'] as String? ?? 'user',
      actualAge: (map['actualAge'] is int) ? map['actualAge'] : null,
      bmi: (map['bmi'] is num) ? (map['bmi'] as num).toDouble() : null,
      waterGoal: (map['waterGoal'] is num) ? (map['waterGoal'] as num).toDouble() : null,
      lastCycleDate: (map['lastCycleDate'] != null && map['lastCycleDate'] != 'N/A')
          ? DateTime.tryParse(map['lastCycleDate'])
          : null,
      acneTypes: map['acneTypes'] != null
          ? List<String>.from(map['acneTypes']).where((e) => e != 'N/A').toList()
          : null,
      usesMedication: (map['usesMedication'] is bool) ? map['usesMedication'] : null,
      medicationType: map['medicationType'] == 'N/A' ? null : map['medicationType'],
      medicationTime: map['medicationTime'] == 'N/A' ? null : map['medicationTime'],
      visitsDerma: (map['visitsDerma'] is bool) ? map['visitsDerma'] : null,
      lastDermaVisit: (map['lastDermaVisit'] != null && map['lastDermaVisit'] != 'N/A')
          ? DateTime.tryParse(map['lastDermaVisit'])
          : null,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? username,
    String? contact,
    String? email,
    String? phone,
    String? imageUrl,
    String? ageGroup,
    String? skinType,
    List<String>? goals,
    bool? surveyCompleted,
    bool? profileCompleted,
    String? role,
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
      username: username ?? this.username,
      contact: contact ?? this.contact,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      ageGroup: ageGroup ?? this.ageGroup,
      skinType: skinType ?? this.skinType,
      goals: goals ?? this.goals,
      surveyCompleted: surveyCompleted ?? this.surveyCompleted,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      role: role ?? this.role,
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
}
