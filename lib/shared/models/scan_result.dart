
class ScanResult {
  final String imagePath;
  final String diseaseName;
  final double confidence;
  final String description;
  final List<String> treatments;
  final List<String> symptoms;
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Extended disease detail fields
  final String riskLevel;
  final String riskColor;
  final String advice;
  final String appearance;
  final String causes;
  final List<String> prevention;
  final String whenToSeeDoctor;
  final String prognosis;
  final String affectedPopulation;
  final String alsoKnownAs;
  final List<Map<String, dynamic>> allPredictions;

  ScanResult({
    required this.imagePath,
    required this.diseaseName,
    required this.confidence,
    required this.description,
    required this.treatments,
    required this.symptoms,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.riskLevel = 'Low',
    this.riskColor = '#44BB44',
    this.advice = 'Monitor regularly.',
    this.appearance = '',
    this.causes = '',
    this.prevention = const [],
    this.whenToSeeDoctor = '',
    this.prognosis = '',
    this.affectedPopulation = '',
    this.alsoKnownAs = '',
    this.allPredictions = const [],
  });

  String get confidencePercent => '${(confidence * 100).toStringAsFixed(1)}%';

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'diseaseName': diseaseName,
        'confidence': confidence,
        'description': description,
        'treatments': treatments,
        'symptoms': symptoms,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'riskLevel': riskLevel,
        'riskColor': riskColor,
        'advice': advice,
        'appearance': appearance,
        'causes': causes,
        'prevention': prevention,
        'whenToSeeDoctor': whenToSeeDoctor,
        'prognosis': prognosis,
        'affectedPopulation': affectedPopulation,
        'alsoKnownAs': alsoKnownAs,
        'allPredictions': allPredictions,
      };

  factory ScanResult.fromJson(Map<String, dynamic> e, [String? overrideImagePath]) => ScanResult(
        id: e['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        imagePath: overrideImagePath ?? e['imagePath'] ?? '',
        diseaseName: e['diseaseName'] ?? '',
        confidence: (e['confidence'] as num?)?.toDouble() ?? 0.0,
        description: e['description'] ?? '',
        treatments: (e['treatments'] as List<dynamic>?)?.map((t) => t.toString()).toList() ?? [],
        symptoms: (e['symptoms'] as List<dynamic>?)?.map((s) => s.toString()).toList() ?? [],
        createdAt: DateTime.tryParse(e['createdAt'] ?? '') ?? DateTime.now(),
        updatedAt: DateTime.tryParse(e['updatedAt'] ?? '') ?? DateTime.now(),
        riskLevel: e['riskLevel'] ?? 'Low',
        riskColor: e['riskColor'] ?? '#44BB44',
        advice: e['advice'] ?? '',
        appearance: e['appearance'] ?? '',
        causes: e['causes'] ?? '',
        prevention: (e['prevention'] as List<dynamic>?)?.map((s) => s.toString()).toList() ?? [],
        whenToSeeDoctor: e['whenToSeeDoctor'] ?? '',
        prognosis: e['prognosis'] ?? '',
        affectedPopulation: e['affectedPopulation'] ?? '',
        alsoKnownAs: e['alsoKnownAs'] ?? '',
        allPredictions: (e['allPredictions'] as List<dynamic>?)
                ?.map((p) => Map<String, dynamic>.from(p as Map))
                .toList() ??
            [],
      );

  ScanResult copyWith({
    String? id,
    String? imagePath,
    String? diseaseName,
    double? confidence,
    String? description,
    List<String>? treatments,
    List<String>? symptoms,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? riskLevel,
    String? riskColor,
    String? advice,
    String? appearance,
    String? causes,
    List<String>? prevention,
    String? whenToSeeDoctor,
    String? prognosis,
    String? affectedPopulation,
    String? alsoKnownAs,
    List<Map<String, dynamic>>? allPredictions,
  }) =>
      ScanResult(
        id: id ?? this.id,
        imagePath: imagePath ?? this.imagePath,
        diseaseName: diseaseName ?? this.diseaseName,
        confidence: confidence ?? this.confidence,
        description: description ?? this.description,
        treatments: treatments ?? this.treatments,
        symptoms: symptoms ?? this.symptoms,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        riskLevel: riskLevel ?? this.riskLevel,
        riskColor: riskColor ?? this.riskColor,
        advice: advice ?? this.advice,
        appearance: appearance ?? this.appearance,
        causes: causes ?? this.causes,
        prevention: prevention ?? this.prevention,
        whenToSeeDoctor: whenToSeeDoctor ?? this.whenToSeeDoctor,
        prognosis: prognosis ?? this.prognosis,
        affectedPopulation: affectedPopulation ?? this.affectedPopulation,
        alsoKnownAs: alsoKnownAs ?? this.alsoKnownAs,
        allPredictions: allPredictions ?? this.allPredictions,
      );
}
