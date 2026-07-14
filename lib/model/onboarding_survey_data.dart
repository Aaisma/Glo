class OnboardingSurveyData {
  String? ageGroup;
  int? actualAge;

  double? weight;
  double? height;
  String heightUnit = 'cm';
  double? feet;
  double? inches;
  double? bmi;
  String? bmiStatus;
  String? bmiTip;
  double? waterGoal;

  DateTime? lastCycleDate;

  String? skinType;
  List<String> goals = [];
  List<String> acneTypes = [];

  bool usesMedication = false;
  String? medicationType;
  String? medicationTime;

  bool visitsDerma = false;
  DateTime? lastDermaVisit;

  OnboardingSurveyData();

  Map<String, dynamic> toMap() {
    return {
      'ageGroup': ageGroup,
      'actualAge': actualAge,
      'weight': weight,
      'height': height,
      'heightUnit': heightUnit,
      'feet': feet,
      'inches': inches,
      'bmi': bmi,
      'bmiStatus': bmiStatus,
      'bmiTip': bmiTip,
      'waterGoal': waterGoal,
      'lastCycleDate': lastCycleDate?.toIso8601String(),
      'skinType': skinType,
      'goals': goals,
      'acneTypes': acneTypes,
      'usesMedication': usesMedication,
      'medicationType': medicationType,
      'medicationTime': medicationTime,
      'visitsDerma': visitsDerma,
      'lastDermaVisit': lastDermaVisit?.toIso8601String(),
    };
  }

  factory OnboardingSurveyData.fromMap(Map<String, dynamic> map) {
    final data = OnboardingSurveyData();
    data.ageGroup = map['ageGroup'] as String?;
    data.actualAge = map['actualAge'] as int?;
    data.weight = (map['weight'] as num?)?.toDouble();
    data.height = (map['height'] as num?)?.toDouble();
    data.heightUnit = map['heightUnit'] as String? ?? 'cm';
    data.feet = (map['feet'] as num?)?.toDouble();
    data.inches = (map['inches'] as num?)?.toDouble();
    data.bmi = (map['bmi'] as num?)?.toDouble();
    data.bmiStatus = map['bmiStatus'] as String?;
    data.bmiTip = map['bmiTip'] as String?;
    data.waterGoal = (map['waterGoal'] as num?)?.toDouble();
    if (map['lastCycleDate'] != null) {
      data.lastCycleDate = DateTime.tryParse(map['lastCycleDate'] as String);
    }
    data.skinType = map['skinType'] as String?;
    data.goals = List<String>.from(map['goals'] ?? []);
    data.acneTypes = List<String>.from(map['acneTypes'] ?? []);
    data.usesMedication = map['usesMedication'] as bool? ?? false;
    data.medicationType = map['medicationType'] as String?;
    data.medicationTime = map['medicationTime'] as String?;
    data.visitsDerma = map['visitsDerma'] as bool? ?? false;
    if (map['lastDermaVisit'] != null) {
      data.lastDermaVisit = DateTime.tryParse(map['lastDermaVisit'] as String);
    }
    return data;
  }
}
