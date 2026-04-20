class DiseaseInfo {
  final String name;
  final String description;
  final List<String> symptoms;
  final List<String> causes;
  final List<String> treatments;
  final List<String> prevention;

  DiseaseInfo({
    required this.name,
    required this.description,
    required this.symptoms,
    required this.causes,
    required this.treatments,
    required this.prevention,
  });

  factory DiseaseInfo.fromJson(Map<String, dynamic> json) => DiseaseInfo(
    name: json['name'] as String,
    description: json['description'] as String,
    symptoms: (json['symptoms'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    causes: (json['causes'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    treatments: (json['treatments'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    prevention: (json['prevention'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  );
   
  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'symptoms': symptoms,
    'causes': causes,
    'treatments': treatments,
    'prevention': prevention,
  };
  
}
