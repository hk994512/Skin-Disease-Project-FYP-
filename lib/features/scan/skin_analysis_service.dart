import 'package:clearskin_ai/core/config.dart';
import 'dart:math' as math;
import 'package:image/image.dart' as img_lib;

// ─── Custom exception ──────────────────────────────────────────
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
enum AnalysisSource { api, tflite }

class SkinAnalysisService {
  SkinAnalysisService._internal();
  static final instance = SkinAnalysisService._internal();

  static const String _scanHistoryKey = 'scan_history';
  static const String _modelAsset = 'assets/models/skin_disease_model.tflite';
  static const int _inputSize = 224;
  static const String _apiBaseUrl = 'http://10.8.154.250:8000';

  // FIX BUG 5 & 6: these were declared but never actually enforced — now they are
  static const double _minConfidence = 0.55;
  static const double _maxEntropyThreshold = 1.50;

  // FIX BUG 8: tightened to match api.py tuning
  static const double _skinRatioThreshold = 0.80;
  static const double _skinFlatnessStd = 35.0;

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
        // FIX BUG 7: was `const .all(16)` — syntax error
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ─── Main entry point ─────────────────────────────────────────
  Future<ScanResult> analyzeSkinImage(
    File imageFile, {
    BuildContext? context,
  }) async {
    final savedImagePath = await _saveImageToLocalStorage(imageFile);

    // 1️⃣ Try API first
    try {
      final result = await _analyzeViaApi(imageFile, savedImagePath);
      await saveScanResult(result);
      debugPrint('✅ Result from Fast API');
      if (context != null && context.mounted) {
        _showSourceSnackbar(context, AnalysisSource.api);
      }
      return result;
    } on NotSkinImageException {
      // Deliberate rejection — do NOT fall back to TFLite
      rethrow;
    } catch (e) {
      debugPrint('❌ API FAILED: $e');

      // Check connectivity to show accurate message
      bool isDeviceOffline = false;
      try {
        final socket = await Socket.connect(
          '8.8.8.8',
          53,
          timeout: const Duration(seconds: 2),
        );
        socket.destroy();
      } catch (_) {
        isDeviceOffline = true;
      }

      if (context != null && context.mounted) {
        final String errorMessage = isDeviceOffline
            ? 'Not connected to wifi or mobile data. Using on-device model.'
            : 'API server is unreachable. Using on-device model.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isDeviceOffline
                      ? Icons.wifi_off_rounded
                      : Icons.cloud_off_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE65100),
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }

    // 2️⃣ Fallback to local TFLite
    try {
      final result = await _analyzeViaLocal(imageFile, savedImagePath);
      await saveScanResult(result);
      debugPrint('✅ Result from local TFLite');
      if (context != null && context.mounted) {
        _showSourceSnackbar(context, AnalysisSource.tflite);
      }
      return result;
    } on NotSkinImageException {
      // Deliberate rejection — do NOT swallow
      rethrow;
    } catch (e) {
      debugPrint('❌ LOCAL MODEL FAILED: $e');
    }

    // 3️⃣ Both failed — no fake diagnosis
    debugPrint('❌ Both API and local model failed — no prediction possible');
    throw Exception(
      'Analysis failed. Could not connect to the server and the on-device model '
      'encountered an error. Please check your internet connection and try again.',
    );
  }

  // ─── API Analysis ─────────────────────────────────────────────
  Future<ScanResult> _analyzeViaApi(
    File imageFile,
    String savedImagePath,
  ) async {
    final originalBytes = await imageFile.readAsBytes();

    // Detect real format from magic bytes
    String mimeSubtype = 'jpeg';
    String filename = 'skin_image.jpg';

    final pathExt = imageFile.path.split('.').last.toLowerCase();

    if (originalBytes.length > 3 &&
        originalBytes[0] == 0x89 &&
        originalBytes[1] == 0x50 &&
        originalBytes[2] == 0x4E &&
        originalBytes[3] == 0x47) {
      mimeSubtype = 'png';
      filename = 'skin_image.png';
    } else if (originalBytes.length > 11 &&
        originalBytes[0] == 0x52 &&
        originalBytes[1] == 0x49 &&
        originalBytes[2] == 0x46 &&
        originalBytes[3] == 0x46 &&
        originalBytes[8] == 0x57 &&
        originalBytes[9] == 0x45 &&
        originalBytes[10] == 0x42 &&
        originalBytes[11] == 0x50) {
      mimeSubtype = 'webp';
      filename = 'skin_image.webp';
    } else if (originalBytes.length > 2 &&
        originalBytes[0] == 0x47 &&
        originalBytes[1] == 0x49 &&
        originalBytes[2] == 0x46) {
      mimeSubtype = 'gif';
      filename = 'skin_image.gif';
    } else if (originalBytes.length > 1 &&
        originalBytes[0] == 0x42 &&
        originalBytes[1] == 0x4D) {
      mimeSubtype = 'bmp';
      filename = 'skin_image.bmp';
    } else if (pathExt == 'heic' || pathExt == 'heif') {
      mimeSubtype = pathExt;
      filename = 'skin_image.$pathExt';
    } else if (['png', 'webp', 'gif', 'bmp', 'jpg', 'jpeg'].contains(pathExt)) {
      mimeSubtype = pathExt == 'jpg' ? 'jpeg' : pathExt;
      filename = 'skin_image.$pathExt';
    }

    debugPrint('📡 Detected format: $mimeSubtype');
    debugPrint('📡 Original bytes: ${originalBytes.length}');

    final request = MultipartRequest('POST', Uri.parse('$_apiBaseUrl/predict'));
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
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('Request timed out after 10s'),
    );

    final response = await Response.fromStream(streamed);

    debugPrint('📡 Status: ${response.statusCode}');
    debugPrint('📡 Body: ${response.body}');

    // 422 = API deliberately rejected the image (not skin / low confidence / high entropy)
    if (response.statusCode == 422) {
      String reason =
          'This image does not seem to be a skin image. Please use another photo.';
      try {
        final body = json.decode(response.body) as Map<String, dynamic>;
        final detail = body['detail'];
        if (detail is String && detail.isNotEmpty) {
          reason = detail;
        } else if (detail is Map && detail['message'] != null) {
          reason = detail['message'].toString();
        } else if (body['message'] != null) {
          reason = body['message'].toString();
        }
      } catch (_) {}
      debugPrint('🚫 API rejected image (422): $reason');
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
    final decoded = img_lib.decodeImage(bytes);
    if (decoded == null) throw Exception('Failed to decode image');

    // ── Step 1: Skin heuristic check ──────────────────────────
    _validateSkinImageLocal(decoded);

    // ── Step 2: Resize & normalize ────────────────────────────
    final resized = img_lib.copyResize(
      decoded,
      width: _inputSize,
      height: _inputSize,
    );

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

    // ── Step 3: Run inference ─────────────────────────────────
    final input = inputBuffer.reshape([1, _inputSize, _inputSize, 3]);
    final outputBuffer = Float32List(7);
    final output = outputBuffer.reshape([1, 7]);
    _interpreter!.run(input, output);

    // ── Step 4: Entropy check — FIX BUG 5: was computed but never enforced
    final probsList = outputBuffer.toList();
    final entropy = _computeEntropyLocal(probsList);
    debugPrint('📱 Local entropy: ${entropy.toStringAsFixed(4)}');

    if (entropy > _maxEntropyThreshold) {
      throw NotSkinImageException(
        'The model could not identify a recognisable skin lesion '
        '(uncertainty: ${entropy.toStringAsFixed(2)}). '
        'Please use a clearer, close-up photo of the affected skin area.',
      );
    }

    // ── Step 5: Top class ─────────────────────────────────────
    int topIdx = 0;
    for (int i = 1; i < outputBuffer.length; i++) {
      if (outputBuffer[i] > outputBuffer[topIdx]) topIdx = i;
    }
    final confidence = outputBuffer[topIdx];

    // ── Step 6: Confidence check — FIX BUG 6: was never checked
    debugPrint(
      '📱 Local confidence: ${(confidence * 100).toStringAsFixed(1)}%',
    );

    if (confidence < _minConfidence) {
      throw NotSkinImageException(
        'Confidence too low (${(confidence * 100).toStringAsFixed(0)}%) '
        'to make a reliable prediction. Please use a clearer, well-lit, '
        'close-up photo of the skin lesion.',
      );
    }

    // ── Step 7: Build result ──────────────────────────────────
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
      confidence: confidence,
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

  // ─── Local skin validator ─────────────────────────────────────
  void _validateSkinImageLocal(img_lib.Image img) {
    final smallImg = img_lib.copyResize(img, width: 64, height: 64);
    int skinCount = 0;
    const totalPixels = 64 * 64;

    final yValues = List.generate(64, (_) => List.filled(64, 0.0));
    double sumY = 0.0;

    for (int y = 0; y < 64; y++) {
      for (int x = 0; x < 64; x++) {
        final pixel = smallImg.getPixel(x, y);
        final r = pixel.r.toDouble();
        final g = pixel.g.toDouble();
        final b = pixel.b.toDouble();

        final yVal = 0.299 * r + 0.587 * g + 0.114 * b;
        final cr = (r - yVal) * 0.713 + 128;
        final cb = (b - yVal) * 0.564 + 128;

        yValues[y][x] = yVal;
        sumY += yVal;

        // FIX BUG 8: widened Cr/Cb ranges to cover darker skin tones
        // OLD: cr >= 133 && cr <= 173 && cb >= 77 && cb <= 127
        // NEW: cr >= 125 && cr <= 175 && cb >= 75 && cb <= 135
        if (cr >= 125 && cr <= 175 && cb >= 75 && cb <= 135) {
          skinCount++;
        }
      }
    }

    final skinRatio = skinCount / totalPixels;
    final meanY = sumY / totalPixels;

    double sumSq = 0.0;
    for (int y = 0; y < 64; y++) {
      for (int x = 0; x < 64; x++) {
        final diff = yValues[y][x] - meanY;
        sumSq += diff * diff;
      }
    }
    final yStd = math.sqrt(sumSq / totalPixels);

    debugPrint(
      '📱 Skin ratio: ${(skinRatio * 100).toStringAsFixed(1)}% | Y std: ${yStd.toStringAsFixed(1)}',
    );

    // FIX BUG 8: loosened thresholds to match api.py
    // OLD: skinRatio > 0.85 && yStd < 25.0
    // NEW: skinRatio > 0.80 && yStd < 35.0
    if (skinRatio > _skinRatioThreshold && yStd < _skinFlatnessStd) {
      throw NotSkinImageException(
        'Healthy skin detected (skin area: ${(skinRatio * 100).toStringAsFixed(0)}%, '
        'texture variance: ${yStd.toStringAsFixed(1)}). '
        'Please capture a clear photo centered on a visible skin lesion.',
      );
    }
  }

  // ─── Entropy helper ───────────────────────────────────────────
  double _computeEntropyLocal(List<double> probabilities) {
    double entropy = 0.0;
    for (final p in probabilities) {
      final clamped = p.clamp(1e-9, 1.0);
      entropy -= clamped * math.log(clamped);
    }
    return entropy;
  }

  // ─── Storage ──────────────────────────────────────────────────
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
