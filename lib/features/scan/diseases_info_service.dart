import 'package:clearskin_ai/core/config.dart';

class DiseaseInfoService {
  DiseaseInfoService._();
  static final instance = DiseaseInfoService._();
  static const String _diseaseKey = 'disease_database';

  final Map<String, DiseaseInfo> _diseaseDatabase = {
    'Acne Vulgaris': DiseaseInfo(
      name: 'Acne Vulgaris',
      description:
          'A common inflammatory skin condition affecting the pilosebaceous units, characterized by comedones, papules, pustules, and sometimes nodules or cysts.',
      symptoms: [
        'Blackheads and whiteheads',
        'Inflamed red bumps',
        'Pus-filled lesions',
        'Painful cysts under the skin',
        'Oily skin',
      ],
      causes: [
        'Excess sebum production',
        'Bacterial colonization (P. acnes)',
        'Hormonal changes',
        'Clogged hair follicles',
        'Genetics',
      ],
      treatments: [
        'Benzoyl peroxide topical gel',
        'Salicylic acid cleanser',
        'Retinoid creams (tretinoin)',
        'Oral antibiotics for severe cases',
        'Hormonal therapy for women',
      ],
      prevention: [
        'Gentle cleansing twice daily',
        'Avoid touching face',
        'Use non-comedogenic products',
        'Remove makeup before bed',
        'Manage stress levels',
      ],
    ),
    'Eczema (Atopic Dermatitis)': DiseaseInfo(
      name: 'Eczema (Atopic Dermatitis)',
      description:
          'A chronic inflammatory skin condition causing dry, itchy, and inflamed patches of skin. Often appears in childhood but can persist into adulthood.',
      symptoms: [
        'Dry, scaly skin',
        'Intense itching',
        'Red or brownish patches',
        'Small raised bumps',
        'Thickened cracked skin',
      ],
      causes: [
        'Immune system dysfunction',
        'Genetic predisposition',
        'Environmental triggers',
        'Skin barrier defects',
        'Allergens and irritants',
      ],
      treatments: [
        'Moisturizers and emollients',
        'Topical corticosteroids',
        'Calcineurin inhibitors',
        'Antihistamines for itching',
        'Phototherapy for severe cases',
      ],
      prevention: [
        'Apply moisturizer regularly',
        'Avoid harsh soaps',
        'Use lukewarm water for bathing',
        'Wear soft breathable fabrics',
        'Identify and avoid triggers',
      ],
    ),
    'Psoriasis': DiseaseInfo(
      name: 'Psoriasis',
      description:
          'An autoimmune condition causing rapid buildup of skin cells, forming thick, silvery scales and itchy, dry, red patches that can be painful.',
      symptoms: [
        'Red patches with silvery scales',
        'Dry cracked skin that may bleed',
        'Itching or burning sensation',
        'Thickened or ridged nails',
        'Swollen stiff joints',
      ],
      causes: [
        'Autoimmune disorder',
        'Genetic factors',
        'Stress triggers',
        'Infections',
        'Certain medications',
      ],
      treatments: [
        'Topical corticosteroids',
        'Vitamin D analogues',
        'Retinoids',
        'Biologic medications',
        'UV light therapy',
      ],
      prevention: [
        'Manage stress effectively',
        'Avoid smoking and alcohol',
        'Moisturize skin regularly',
        'Avoid injury to skin',
        'Maintain healthy weight',
      ],
    ),
    'Rosacea': DiseaseInfo(
      name: 'Rosacea',
      description:
          'A chronic inflammatory skin condition primarily affecting the face, causing redness, visible blood vessels, and sometimes acne-like bumps.',
      symptoms: [
        'Facial redness and flushing',
        'Visible blood vessels',
        'Swollen red bumps',
        'Eye irritation',
        'Thickened skin on nose',
      ],
      causes: [
        'Abnormal immune response',
        'Blood vessel abnormalities',
        'Demodex mites',
        'H. pylori bacteria',
        'Genetic predisposition',
      ],
      treatments: [
        'Metronidazole gel',
        'Azelaic acid cream',
        'Oral antibiotics',
        'Laser therapy',
        'Brimonidine for redness',
      ],
      prevention: [
        'Avoid hot beverages',
        'Use sunscreen daily',
        'Identify trigger foods',
        'Gentle skin care',
        'Avoid extreme temperatures',
      ],
    ),
    'Melanoma': DiseaseInfo(
      name: 'Melanoma',
      description:
          'A serious form of skin cancer that develops in melanocytes. Early detection is crucial for successful treatment.',
      symptoms: [
        'Asymmetric mole shape',
        'Irregular borders',
        'Multiple colors in one mole',
        'Diameter larger than 6mm',
        'Evolving size or appearance',
      ],
      causes: [
        'UV radiation exposure',
        'Excessive sunburns',
        'Family history',
        'Fair skin',
        'Multiple moles',
      ],
      treatments: [
        'Surgical excision',
        'Immunotherapy',
        'Targeted therapy',
        'Radiation therapy',
        'Chemotherapy for advanced cases',
      ],
      prevention: [
        'Use broad-spectrum sunscreen',
        'Avoid tanning beds',
        'Wear protective clothing',
        'Seek shade during peak hours',
        'Regular skin examinations',
      ],
    ),
    'Contact Dermatitis': DiseaseInfo(
      name: 'Contact Dermatitis',
      description:
          'An inflammatory skin reaction caused by direct contact with allergens or irritants, resulting in red, itchy rashes.',
      symptoms: [
        'Red itchy rash',
        'Dry cracked skin',
        'Burning sensation',
        'Blisters with oozing',
        'Swelling',
      ],
      causes: [
        'Allergens (nickel, latex)',
        'Irritants (soaps, chemicals)',
        'Cosmetics',
        'Plants (poison ivy)',
        'Fragrances',
      ],
      treatments: [
        'Avoid the trigger substance',
        'Topical corticosteroids',
        'Oral antihistamines',
        'Cool compresses',
        'Moisturizing creams',
      ],
      prevention: [
        'Identify and avoid allergens',
        'Wear protective gloves',
        'Use fragrance-free products',
        'Patch test new products',
        'Rinse skin after exposure',
      ],
    ),
    'Fungal Infection (Tinea)': DiseaseInfo(
      name: 'Fungal Infection (Tinea)',
      description:
          'Contagious fungal infections affecting different body areas, causing ring-shaped rashes, itching, and scaling.',
      symptoms: [
        'Ring-shaped red rash',
        'Itchy scaly patches',
        'Cracked skin',
        'Discolored nails',
        'Hair loss in affected areas',
      ],
      causes: [
        'Dermatophyte fungi',
        'Warm moist environments',
        'Direct contact',
        'Shared towels or clothing',
        'Weakened immune system',
      ],
      treatments: [
        'Antifungal creams',
        'Oral antifungal medications',
        'Antifungal shampoo',
        'Keep area dry and clean',
        'Treat for full course',
      ],
      prevention: [
        'Keep skin dry',
        'Avoid sharing personal items',
        'Wear breathable fabrics',
        'Use antifungal powder',
        'Wash workout gear regularly',
      ],
    ),
    'Vitiligo': DiseaseInfo(
      name: 'Vitiligo',
      description:
          'An autoimmune condition where skin loses pigment-producing cells, resulting in white patches on various body parts.',
      symptoms: [
        'White patches on skin',
        'Premature graying of hair',
        'Loss of color in mouth',
        'Change in eye color',
        'Symmetrical patterns',
      ],
      causes: [
        'Autoimmune destruction',
        'Genetic factors',
        'Stress triggers',
        'Sunburn',
        'Chemical exposure',
      ],
      treatments: [
        'Topical corticosteroids',
        'Calcineurin inhibitors',
        'Phototherapy (PUVA)',
        'Skin grafting',
        'Micropigmentation',
      ],
      prevention: [
        'Protect from sun exposure',
        'Manage stress',
        'Avoid skin trauma',
        'Use sunscreen on patches',
        'Support immune health',
      ],
    ),
  };

  Future<DiseaseInfo?> getDiseaseInfo(String diseaseName) async {
    await _initializeDatabase();
    return _diseaseDatabase[diseaseName];
  }

  Future<List<DiseaseInfo>> getAllDiseases() async {
    await _initializeDatabase();
    return _diseaseDatabase.values.toList();
  }

  Future<void> _initializeDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_diseaseKey);

    if (storedData == null) {
      final jsonData = _diseaseDatabase.map(
        (key, value) => MapEntry(key, value.toJson()),
      );
      await prefs.setString(_diseaseKey, json.encode(jsonData));
    } else {
      try {
        final Map<String, dynamic> decoded = json.decode(storedData);
        _diseaseDatabase.clear();
        decoded.forEach((key, value) {
          _diseaseDatabase[key] = DiseaseInfo.fromJson(value);
        });
      } catch (e) {
        final jsonData = _diseaseDatabase.map(
          (key, value) => MapEntry(key, value.toJson()),
        );
        await prefs.setString(_diseaseKey, json.encode(jsonData));
      }
    }
  }
}
