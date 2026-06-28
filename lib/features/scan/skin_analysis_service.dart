import 'package:clearskin_ai/core/config.dart';

// ─── Custom exception ──────────────────────────────────────────
/// Thrown when the backend API has explicitly determined that the
/// uploaded image is NOT a skin image (HTTP 422 / low skin-pixel-ratio).
///
/// This is a *deliberate* classification, not a transient failure —
/// it must propagate straight to the UI and must NOT trigger the
/// TFLite or mock fallback paths (which would otherwise happily
/// produce a fake disease prediction for a non-skin photo).
class NotSkinImageException implements Exception {
  final String message;
  NotSkinImageException([
    this.message =
        'This image does not seem to be a skin image. Please use another photo.',
  ]);

  @override
  String toString() => message;
}

// ─── Class metadata ───────────────────────────────────────────
const _classInfo = [
  {
    'code': 'akiec',
    'name': 'Actinic Keratoses',
    'risk': 'High',
    'color': '#FF4444',
  },
  {
    'code': 'bcc',
    'name': 'Basal Cell Carcinoma',
    'risk': 'High',
    'color': '#FF4444',
  },
  {
    'code': 'bkl',
    'name': 'Benign Keratosis',
    'risk': 'Low',
    'color': '#44BB44',
  },
  {'code': 'df', 'name': 'Dermatofibroma', 'risk': 'Low', 'color': '#44BB44'},
  {'code': 'mel', 'name': 'Melanoma', 'risk': 'Critical', 'color': '#AA0000'},
  {'code': 'nv', 'name': 'Melanocytic Nevi', 'risk': 'Low', 'color': '#44BB44'},
  {
    'code': 'vasc',
    'name': 'Vascular Lesions',
    'risk': 'Medium',
    'color': '#FFAA00',
  },
];

const _advice = {
  'Critical': '⚠️ Seek immediate dermatologist consultation.',
  'High': 'Please schedule a dermatologist appointment soon.',
  'Medium': 'Monitor the lesion and consult a doctor if it changes.',
  'Low': 'Likely benign. Monitor regularly.',
};

const _diseaseDetails = {
  'akiec': {
    'description':
        'Actinic keratoses are rough, scaly patches on the skin caused by years of sun exposure. They are considered pre-cancerous lesions because they can progress to squamous cell carcinoma if left untreated.',
    'appearance':
        'Rough, dry, scaly patch of skin, typically less than 1 inch in diameter. May be flat or slightly raised, pink, red, or brown in color.',
    'causes':
        'Prolonged or repeated exposure to ultraviolet (UV) radiation from sunlight or tanning beds. More common in people with fair skin, light hair, and light eyes.',
    'alsoKnownAs': 'Solar Keratosis, Bowen\'s Disease',
    'symptoms': [
      'Rough, dry, scaly patch of skin',
      'Flat to slightly raised patch on the top layer of skin',
      'Hard, wart-like surface in some cases',
      'Color variations: pink, red, or brown',
      'Itching, burning, or tenderness in the affected area',
      'New patches appearing on sun-exposed skin',
    ],
    'treatments': [
      'Cryotherapy (freezing with liquid nitrogen)',
      'Topical medications: fluorouracil (5-FU), imiquimod, diclofenac',
      'Photodynamic therapy (PDT)',
      'Laser resurfacing',
      'Chemical peeling',
      'Surgical excision for thicker lesions',
    ],
    'prevention': [
      'Apply broad-spectrum SPF 30+ sunscreen daily',
      'Wear protective clothing and wide-brimmed hats',
      'Avoid peak sun hours (10am–4pm)',
      'Never use tanning beds',
      'Get regular skin checks by a dermatologist',
    ],
    'whenToSeeDoctor':
        'See a doctor if the patch bleeds, grows rapidly, becomes very tender, or does not heal within a few weeks.',
    'prognosis':
        'With early treatment, prognosis is excellent. Untreated lesions have a 5–10% chance of progressing to squamous cell carcinoma over 10 years.',
    'affectedPopulation':
        'Most common in adults over 40 with a history of significant sun exposure.',
  },
  'bcc': {
    'description':
        'Basal cell carcinoma is the most common form of skin cancer worldwide. It originates in the basal cells and can cause significant local destruction if left untreated.',
    'appearance':
        'Pearly or waxy bump, often with visible blood vessels. May appear as a flat, flesh-colored or brown scar-like lesion.',
    'causes':
        'Cumulative UV radiation exposure is the primary cause. Genetic mutations in the PTCH1 gene are commonly involved.',
    'alsoKnownAs': 'BCC, Rodent Ulcer',
    'symptoms': [
      'Pearly or waxy bump on face, ears, or neck',
      'Flat, flesh-colored or brown scar-like lesion',
      'Bleeding or scabbing sore that heals and returns',
      'Pink growth with raised edges and a crusted center',
      'Visible blood vessels on the surface',
    ],
    'treatments': [
      'Mohs micrographic surgery',
      'Surgical excision with clear margins',
      'Electrodesiccation and curettage',
      'Cryotherapy for superficial lesions',
      'Topical imiquimod or fluorouracil',
      'Radiation therapy for inoperable cases',
    ],
    'prevention': [
      'Daily use of broad-spectrum SPF 50+ sunscreen',
      'Protective clothing, hats, and UV-blocking sunglasses',
      'Avoid tanning beds completely',
      'Regular annual skin examinations',
    ],
    'whenToSeeDoctor':
        'Seek immediate evaluation for any sore that does not heal, a new shiny bump, or any lesion that bleeds without injury.',
    'prognosis':
        'Excellent with early treatment. Cure rates exceed 95% with appropriate surgery.',
    'affectedPopulation': 'Most common in people over 50 with fair skin.',
  },
  'bkl': {
    'description':
        'Benign keratosis-like lesions are a group of non-cancerous skin growths that commonly appear as people age. They are completely harmless.',
    'appearance':
        'Waxy, scaly, slightly elevated growths. Color ranges from light tan to black with a stuck-on appearance.',
    'causes':
        'Exact cause is unknown. Strongly associated with aging and sun exposure. Genetic predisposition plays a role.',
    'alsoKnownAs': 'Seborrheic Keratosis, Solar Lentigo',
    'symptoms': [
      'Waxy, rough, or scaly growth on skin surface',
      'Stuck-on appearance',
      'Color ranging from light tan to dark brown or black',
      'Round or oval shape',
      'Itching in some cases',
    ],
    'treatments': [
      'No treatment required for asymptomatic lesions',
      'Cryotherapy for cosmetic removal',
      'Electrocautery and curettage',
      'Laser ablation',
      'Shave excision for irritated lesions',
    ],
    'prevention': [
      'Sun protection may slow development',
      'Regular moisturizing to reduce irritation',
      'Avoid scratching or picking at lesions',
    ],
    'whenToSeeDoctor':
        'See a doctor if a lesion changes rapidly, bleeds, becomes painful, or looks significantly different.',
    'prognosis':
        'Excellent. These are benign lesions with no malignant potential.',
    'affectedPopulation':
        'Extremely common in adults over 50. Affects men and women equally.',
  },
  'df': {
    'description':
        'Dermatofibromas are common, benign skin growths that consist of fibrous tissue. They are firm nodules most often appearing on the legs.',
    'appearance':
        'Small, firm, raised bump. Usually brown, pink, or reddish. Characteristically dimples inward when pinched.',
    'causes':
        'Exact cause unknown. May be triggered by minor trauma such as insect bites or thorn pricks.',
    'alsoKnownAs': 'Benign Fibrous Histiocytoma',
    'symptoms': [
      'Small, hard bump under the skin surface',
      'Brown, pink, or reddish color',
      'Dimples inward when pinched',
      'Usually painless but may be tender',
      'Slow-growing and stable over years',
    ],
    'treatments': [
      'No treatment necessary for asymptomatic lesions',
      'Surgical excision if symptomatic',
      'Cryotherapy for superficial lesions',
      'Steroid injections to flatten the lesion',
    ],
    'prevention': [
      'No specific prevention known',
      'Protect skin from minor injuries and insect bites',
    ],
    'whenToSeeDoctor':
        'Consult a doctor if the lesion grows rapidly, becomes painful, bleeds, or changes color.',
    'prognosis':
        'Excellent. Dermatofibromas are benign and do not become cancerous.',
    'affectedPopulation':
        'Most common in young to middle-aged adults. More frequent in women than men.',
  },
  'mel': {
    'description':
        'Melanoma is the most dangerous form of skin cancer, arising from melanocytes. It is far more likely to spread to other parts of the body if not caught early.',
    'appearance':
        'Follows the ABCDE rule: Asymmetry, Border irregularity, Color variation, Diameter greater than 6mm, and Evolution.',
    'causes':
        'UV radiation from sun and tanning beds is the primary cause. Genetic mutations (BRAF, NRAS, NF1) play a major role.',
    'alsoKnownAs': 'Malignant Melanoma, Cutaneous Melanoma',
    'symptoms': [
      'Asymmetrical mole',
      'Irregular, ragged, notched, or blurred border',
      'Multiple colors within the same lesion',
      'Diameter larger than 6mm',
      'Evolving size, shape, or color',
      'Itching, bleeding, or oozing from a mole',
    ],
    'treatments': [
      'Wide local excision',
      'Sentinel lymph node biopsy',
      'Immunotherapy: pembrolizumab, nivolumab',
      'Targeted therapy: vemurafenib, dabrafenib',
      'Radiation therapy for metastases',
      'Clinical trials for advanced melanoma',
    ],
    'prevention': [
      'Apply SPF 50+ sunscreen every 2 hours outdoors',
      'Wear UV-protective clothing',
      'Avoid tanning beds',
      'Perform monthly self-skin examinations',
      'Annual full-body skin exam by a dermatologist',
    ],
    'whenToSeeDoctor':
        '⚠️ URGENT — See a dermatologist immediately if any mole changes in size, shape, or color.',
    'prognosis':
        'Stage I: ~98% survival. Stage II: ~65%. Stage III: ~45%. Stage IV: ~25% but improving with immunotherapy.',
    'affectedPopulation':
        'Can affect anyone but most common in fair-skinned individuals. Peaks between ages 45–54.',
  },
  'nv': {
    'description':
        'Melanocytic nevi, commonly known as moles, are benign growths on the skin that form when pigment cells grow in clusters. Most are harmless.',
    'appearance':
        'Round or oval, with a smooth, well-defined border. Uniform color — tan, brown, or black. Usually less than 6mm.',
    'causes':
        'Formed when melanocytes grow in a cluster. Sun exposure can increase the number of moles. Genetic factors also play a role.',
    'alsoKnownAs': 'Common Mole, Nevus',
    'symptoms': [
      'Small, round or oval growth on the skin',
      'Uniform brown, tan, or black color',
      'Smooth, well-defined borders',
      'Flat or slightly raised surface',
      'Generally stable — not changing over time',
    ],
    'treatments': [
      'No treatment required for typical benign moles',
      'Surgical excision if atypical features',
      'Shave excision for cosmetic removal',
      'Regular monitoring with dermoscopy',
    ],
    'prevention': [
      'Sun protection to prevent new moles',
      'Avoid sunburn especially in childhood',
      'Regular self-examination using the ABCDE rule',
    ],
    'whenToSeeDoctor':
        'See a doctor if a mole changes in size, shape, or color, bleeds, or itches.',
    'prognosis':
        'Excellent for benign nevi. The lifetime risk of any single mole becoming melanoma is very low.',
    'affectedPopulation':
        'Universal — affects people of all ages, skin types, and ethnicities.',
  },
  'vasc': {
    'description':
        'Vascular lesions are abnormalities of blood vessels in the skin including cherry angiomas, spider angiomas, pyogenic granulomas, and port-wine stains.',
    'appearance':
        'Varies by type. Cherry angiomas are small bright red domes. Spider angiomas have radiating vessels. Pyogenic granulomas are red moist nodules.',
    'causes':
        'Caused by abnormal proliferation or dilation of blood vessels. Cherry angiomas are associated with aging.',
    'alsoKnownAs': 'Angiomas, Pyogenic Granuloma, Hemangioma',
    'symptoms': [
      'Bright red, purple, or bluish discoloration',
      'Small dome-shaped red bumps',
      'Spider-like pattern of blood vessels',
      'Rapidly growing red nodule that bleeds easily',
      'Soft, compressible texture',
    ],
    'treatments': [
      'No treatment for asymptomatic cherry angiomas',
      'Laser therapy (pulsed dye laser)',
      'Electrocautery',
      'Surgical excision for pyogenic granulomas',
      'Intense pulsed light (IPL)',
    ],
    'prevention': [
      'Sun protection to reduce development',
      'Avoid skin trauma',
      'Regular monitoring for rapid growth or bleeding',
    ],
    'whenToSeeDoctor':
        'See a doctor if a vascular lesion bleeds frequently, grows rapidly, is painful, or appears suddenly.',
    'prognosis':
        'Excellent for most vascular lesions. They are benign and do not become cancerous.',
    'affectedPopulation':
        'Cherry angiomas are extremely common in adults over 30.',
  },
};

// ─── Source enum ──────────────────────────────────────────────
enum AnalysisSource { api, tflite, mock }

class SkinAnalysisService {
  SkinAnalysisService._internal();
  static final instance = SkinAnalysisService._internal();

  static const String _scanHistoryKey = 'scan_history';
  static const String _modelAsset = 'assets/models/skin_disease_model.tflite';
  static const int _inputSize = 224;
  static const String _apiBaseUrl = 'http://10.8.30.244:8000';

  final _uuid = const Uuid();
  Interpreter? _interpreter;

  // ─── Snackbar ─────────────────────────────────────────────────
  void _showSourceSnackbar(BuildContext context, AnalysisSource source) {
    if (!context.mounted) return;

    final (message, color, icon) = switch (source) {
      AnalysisSource.api => (
        '🌐 Result from Fast API',
        const Color(0xFF2196F3),
        Icons.cloud_done_rounded,
      ),
      AnalysisSource.tflite => (
        '📱 Result from On-Device Model (API unavailable)',
        const Color(0xFFFF9800),
        Icons.memory_rounded,
      ),
      AnalysisSource.mock => (
        '⚠️ Demo Result — API & model both unavailable',
        const Color(0xFFF44336),
        Icons.warning_amber_rounded,
      ),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Main entry point ─────────────────────────────────────────
  // ✅ context is optional so old call sites without context still compile
  Future<ScanResult> analyzeSkinImage(
    File imageFile, {
    BuildContext? context,
  }) async {
    final savedImagePath = await _saveImageToLocalStorage(imageFile);

    // 1️⃣ Try API
    try {
      final result = await _analyzeViaApi(imageFile, savedImagePath);
      await saveScanResult(result);
      debugPrint('✅ Result from Fast API');
      if (context != null && context.mounted) {
        _showSourceSnackbar(context, AnalysisSource.api);
      }
      return result;
    } on NotSkinImageException {
      // ✅ FIX: The API explicitly said "this isn't skin" (422, low skin
      // pixel ratio). This is a deliberate classification, not a failure —
      // rethrow immediately so the UI shows "not a skin image" instead of
      // silently falling through to TFLite/mock, which would otherwise
      // happily invent a disease for a non-skin photo.
      rethrow;
    } catch (e) {
      debugPrint('❌ API FAILED: $e');
    }

    // 2️⃣ Fallback to local TFLite (only reached on genuine API
    // failure — network error, timeout, server error, etc. — never
    // reached for a confirmed "not a skin image" classification)
    try {
      final result = await _analyzeViaLocal(imageFile, savedImagePath);
      await saveScanResult(result);
      debugPrint('✅ Result from local TFLite');
      if (context != null && context.mounted) {
        _showSourceSnackbar(context, AnalysisSource.tflite);
      }
      return result;
    } catch (e) {
      debugPrint('❌ LOCAL MODEL FAILED: $e');
    }

    // 3️⃣ Mock
    debugPrint('⚠️ Using mock result');
    final mock = _createMockResult(savedImagePath);
    await saveScanResult(mock);
    if (context != null && context.mounted) {
      _showSourceSnackbar(context, AnalysisSource.mock);
    }
    return mock;
  }

  // ─── API Analysis ─────────────────────────────────────────────
  Future<ScanResult> _analyzeViaApi(
    File imageFile,
    String savedImagePath,
  ) async {
    // ✅ Read original bytes — zero processing, zero re-encoding
    final originalBytes = await imageFile.readAsBytes();

    // ✅ Detect real format from magic bytes
    // JPEG starts with FF D8 FF
    // PNG starts with 89 50 4E 47
    final isPng =
        originalBytes.length > 3 &&
        originalBytes[0] == 0x89 &&
        originalBytes[1] == 0x50 &&
        originalBytes[2] == 0x4E &&
        originalBytes[3] == 0x47;

    final mimeSubtype = isPng ? 'png' : 'jpeg';
    final filename = isPng ? 'skin_image.png' : 'skin_image.jpg';

    debugPrint('📡 Detected format: $mimeSubtype');
    debugPrint('📡 Original bytes: ${originalBytes.length}');

    final request = MultipartRequest('POST', Uri.parse('$_apiBaseUrl/predict'));

    // ✅ Send exact original bytes
    request.files.add(
      MultipartFile.fromBytes(
        'file',
        originalBytes,
        filename: filename,
        contentType: MediaType('image', mimeSubtype),
      ),
    );

    request.headers['Accept'] = 'application/json';
    request.headers['Connection'] = 'keep-alive';

    debugPrint('📡 Sending to: $_apiBaseUrl/predict');

    final streamed = await request.send().timeout(
      const Duration(seconds: 60),
      onTimeout: () => throw Exception('Request timed out after 60s'),
    );

    final response = await Response.fromStream(streamed);

    debugPrint('📡 Status: ${response.statusCode}');
    debugPrint('📡 Body: ${response.body}');

    // ✅ FIX: 422 means the backend explicitly determined this is NOT a
    // skin image (e.g. "Skin pixel ratio: 0.00%"). This is a deliberate,
    // meaningful classification — not a transient/server error — so we
    // throw a dedicated NotSkinImageException instead of a generic
    // Exception. analyzeSkinImage() rethrows this immediately instead of
    // falling back to TFLite/mock, so the UI can show a clean
    // "this doesn't look like a skin image" message.
    if (response.statusCode == 422) {
      String reason =
          'This image does not seem to be a skin image. Please use another photo.';
      try {
        final body = json.decode(response.body) as Map<String, dynamic>;
        // FastAPI validation errors are commonly nested under "detail".
        final detail = body['detail'];
        if (detail is String && detail.isNotEmpty) {
          reason = detail;
        } else if (detail is Map && detail['message'] != null) {
          reason = detail['message'].toString();
        } else if (body['message'] != null) {
          reason = body['message'].toString();
        }
      } catch (_) {
        // Body wasn't parseable JSON — fall back to the default reason.
      }
      debugPrint('🚫 API classified image as NOT skin (422): $reason');
      throw NotSkinImageException(reason);
    }

    if (response.statusCode != 200 || response.body.isEmpty) {
      throw Exception('API ${response.statusCode}: ${response.body}');
    }

    final data = json.decode(response.body) as Map<String, dynamic>;

    final predictedClass = data['predicted_class'] as String? ?? '';
    final displayName = data['display_name'] as String? ?? '';
    final confidence = (data['confidence'] as num?)?.toDouble() ?? 0.0;
    final riskLevel = data['risk_level'] as String? ?? 'Low';
    final riskColor = data['risk_color'] as String? ?? '#44BB44';
    final advice = data['advice'] as String? ?? '';

    final dd = (data['disease_detail'] as Map<String, dynamic>?) ?? {};
    final alsoKnownAs = dd['also_known_as'] as String? ?? '';
    final description = dd['description'] as String? ?? '';
    final appearance = dd['appearance'] as String? ?? '';
    final causes = dd['causes'] as String? ?? '';
    final whenToSeeDoctor = dd['when_to_see_doctor'] as String? ?? '';
    final prognosis = dd['prognosis'] as String? ?? '';
    final affectedPopulation = dd['affected_population'] as String? ?? '';
    final symptoms = List<String>.from((dd['symptoms'] as List?) ?? []);
    final treatments = List<String>.from((dd['treatment'] as List?) ?? []);
    final prevention = List<String>.from((dd['prevention'] as List?) ?? []);

    final rawPreds = data['all_predictions'] as List? ?? [];
    final allPreds = rawPreds
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    final now = DateTime.now();
    return ScanResult(
      id: _uuid.v4(),
      imagePath: savedImagePath,
      diseaseName: displayName.isNotEmpty ? displayName : predictedClass,
      confidence: confidence,
      description: description,
      symptoms: symptoms,
      treatments: treatments,
      riskLevel: riskLevel,
      riskColor: riskColor,
      advice: advice,
      appearance: appearance,
      causes: causes,
      prevention: prevention,
      whenToSeeDoctor: whenToSeeDoctor,
      prognosis: prognosis,
      affectedPopulation: affectedPopulation,
      alsoKnownAs: alsoKnownAs,
      allPredictions: allPreds,
      createdAt: now,
      updatedAt: now,
    );
  }

  // ─── Local TFLite fallback ────────────────────────────────────
  Future<void> _initInterpreter() async {
    _interpreter ??= await Interpreter.fromAsset(_modelAsset);
  }

  Future<ScanResult> _analyzeViaLocal(
    File imageFile,
    String savedImagePath,
  ) async {
    await _initInterpreter();

    final bytes = await imageFile.readAsBytes();
    final decoded = decodeImage(bytes)!;
    final resized = copyResize(decoded, width: _inputSize, height: _inputSize);

    final inputBuffer = Float32List(_inputSize * _inputSize * 3);
    int idx = 0;
    for (int y = 0; y < _inputSize; y++) {
      for (int x = 0; x < _inputSize; x++) {
        final pixel = resized.getPixel(x, y);
        inputBuffer[idx++] = pixel.r / 255.0;
        inputBuffer[idx++] = pixel.g / 255.0;
        inputBuffer[idx++] = pixel.b / 255.0;
      }
    }

    final input = inputBuffer.reshape([1, _inputSize, _inputSize, 3]);
    final outputBuffer = Float32List(7);
    final output = outputBuffer.reshape([1, 7]);
    _interpreter!.run(input, output);

    int topIdx = 0;
    for (int i = 1; i < outputBuffer.length; i++) {
      if (outputBuffer[i] > outputBuffer[topIdx]) topIdx = i;
    }

    final info = _classInfo[topIdx];
    final code = info['code']!;
    final detail = _diseaseDetails[code]!;
    final now = DateTime.now();

    final allPreds =
        List.generate(
          _classInfo.length,
          (i) => <String, dynamic>{
            'index': i,
            'code': _classInfo[i]['code']!,
            'name': _classInfo[i]['name']!,
            'probability': outputBuffer[i],
          },
        )..sort(
          (a, b) => (b['probability'] as double).compareTo(
            a['probability'] as double,
          ),
        );

    return ScanResult(
      id: _uuid.v4(),
      imagePath: savedImagePath,
      diseaseName: info['name']!,
      confidence: outputBuffer[topIdx],
      description: detail['description'] as String,
      symptoms: List<String>.from(detail['symptoms'] as List),
      treatments: List<String>.from(detail['treatments'] as List),
      riskLevel: info['risk']!,
      riskColor: info['color']!,
      advice: _advice[info['risk']]!,
      appearance: detail['appearance'] as String,
      causes: detail['causes'] as String,
      prevention: List<String>.from(detail['prevention'] as List),
      whenToSeeDoctor: detail['whenToSeeDoctor'] as String,
      prognosis: detail['prognosis'] as String,
      affectedPopulation: detail['affectedPopulation'] as String,
      alsoKnownAs: detail['alsoKnownAs'] as String,
      allPredictions: allPreds,
      createdAt: now,
      updatedAt: now,
    );
  }

  // ─── Mock fallback ────────────────────────────────────────────
  ScanResult _createMockResult(String savedImagePath) {
    final now = DateTime.now();
    return ScanResult(
      id: _uuid.v4(),
      imagePath: savedImagePath,
      diseaseName: 'Melanocytic Nevi',
      confidence: 0.82,
      description: _diseaseDetails['nv']!['description'] as String,
      symptoms: List<String>.from(_diseaseDetails['nv']!['symptoms'] as List),
      treatments: List<String>.from(
        _diseaseDetails['nv']!['treatments'] as List,
      ),
      riskLevel: 'Low',
      riskColor: '#44BB44',
      advice: _advice['Low']!,
      appearance: _diseaseDetails['nv']!['appearance'] as String,
      causes: _diseaseDetails['nv']!['causes'] as String,
      prevention: List<String>.from(
        _diseaseDetails['nv']!['prevention'] as List,
      ),
      whenToSeeDoctor: _diseaseDetails['nv']!['whenToSeeDoctor'] as String,
      prognosis: _diseaseDetails['nv']!['prognosis'] as String,
      affectedPopulation:
          _diseaseDetails['nv']!['affectedPopulation'] as String,
      alsoKnownAs: _diseaseDetails['nv']!['alsoKnownAs'] as String,
      allPredictions: const [],
      createdAt: now,
      updatedAt: now,
    );
  }

  // ─── Storage methods ──────────────────────────────────────────
  Future<String> _saveImageToLocalStorage(File imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final scanImagesDir = Directory('${directory.path}/scan_images');
    if (!await scanImagesDir.exists()) {
      await scanImagesDir.create(recursive: true);
    }
    final fileName = '${_uuid.v4()}.jpg';
    final savedImage = await imageFile.copy('${scanImagesDir.path}/$fileName');
    return savedImage.path;
  }

  Future<void> saveScanResult(ScanResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_scanHistoryKey);
    List<Map<String, dynamic>> history = [];
    if (historyJson != null) {
      try {
        final decoded = json.decode(historyJson) as List;
        history = decoded.map((e) => e as Map<String, dynamic>).toList();
      } catch (_) {
        history = [];
      }
    }
    history.insert(0, result.toJson());
    await prefs.setString(_scanHistoryKey, json.encode(history));
  }

  Future<List<ScanResult>> getScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_scanHistoryKey);
    if (historyJson == null) return [];
    try {
      final decoded = json.decode(historyJson) as List;
      return decoded
          .map((e) {
            try {
              return ScanResult.fromJson(e as Map<String, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<ScanResult>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteScanResult(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_scanHistoryKey);
    if (historyJson == null) return;
    try {
      final decoded = json.decode(historyJson) as List;
      final history = decoded
          .map((e) => ScanResult.fromJson(e as Map<String, dynamic>))
          .toList();
      final toDelete = history.firstWhere((s) => s.id == id);
      final imageFile = File(toDelete.imagePath);
      if (await imageFile.exists()) await imageFile.delete();
      history.removeWhere((s) => s.id == id);
      await prefs.setString(
        _scanHistoryKey,
        json.encode(history.map((e) => e.toJson()).toList()),
      );
    } catch (_) {}
  }

  Future<ScanResult?> getScanById(String id) async {
    final history = await getScanHistory();
    try {
      return history.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}
