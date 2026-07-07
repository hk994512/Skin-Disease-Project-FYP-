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
  static const String _apiBaseUrl = 'http://10.8.162.241:8000';

  // Three-layer validation:
  //   1st Layer: RGB skin heuristic (skin pixel ratio < 10% → rejected)
  //   2nd Layer: Shannon entropy check (entropy > 1.80 → model confused → rejected)
  //   3rd Layer: Confidence threshold (< 40% → rejected)
  static const double _minConfidence = 0.40;
  static const double _maxEntropyThreshold = 1.80;
  static const double _skinRatioThreshold =
      0.10; // < 10% skin pixels → not a skin image

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

  // ─── Preprocessing and Validation Pipeline ─────────────────────
  Future<File> _preprocessImage(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final decoded = img_lib.decodeImage(bytes);
    if (decoded == null) throw Exception('Failed to decode image');

    final int minDim = decoded.width < decoded.height
        ? decoded.width
        : decoded.height;
    final int cropX = (decoded.width - minDim) ~/ 2;
    final int cropY = (decoded.height - minDim) ~/ 2;
    final cropped = img_lib.copyCrop(
      decoded,
      x: cropX,
      y: cropY,
      width: minDim,
      height: minDim,
    );
    final resized = img_lib.copyResize(
      cropped,
      width: _inputSize,
      height: _inputSize,
    );

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/preprocessed_${_uuid.v4()}.jpg');
    await tempFile.writeAsBytes(img_lib.encodeJpg(resized, quality: 90));
    return tempFile;
  }

  // ─── Main entry point ─────────────────────────────────────────
  Future<ScanResult> analyzeSkinImage(
    File imageFile, {
    BuildContext? context,
  }) async {
    // 1️⃣ Validate on original image FIRST (before any preprocessing)
    final rawBytes = await imageFile.readAsBytes();
    final rawDecoded = img_lib.decodeImage(rawBytes);
    if (rawDecoded == null) throw Exception('Failed to decode image');
    _validateSkinImageLocal(rawDecoded);

    // 2️⃣ Now preprocess for model (crop + resize to 224x224)
    final preprocessedFile = await _preprocessImage(imageFile);
    final savedImagePath = await _saveImageToLocalStorage(preprocessedFile);

    // 3️⃣ Try API — send ORIGINAL image so server metrics are on full photo
    try {
      final result = await _analyzeViaApi(imageFile, savedImagePath);
      await saveScanResult(result);
      debugPrint('✅ Result from Fast API');
      if (context != null && context.mounted) {
        _showSourceSnackbar(context, AnalysisSource.api);
      }
      return result;
    } on NotSkinImageException {
      rethrow;
    } catch (e) {
      debugPrint('❌ API FAILED: $e');
    }

    // 4️⃣ Fallback to local TFLite (uses preprocessed 224x224 file)
    try {
      final result = await _analyzeViaLocal(preprocessedFile, savedImagePath);
      await saveScanResult(result);
      debugPrint('✅ Result from local TFLite');
      if (context != null && context.mounted) {
        _showSourceSnackbar(context, AnalysisSource.tflite);
      }
      return result;
    } on NotSkinImageException {
      rethrow;
    } catch (e) {
      debugPrint('❌ LOCAL MODEL FAILED: $e');
    }

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
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Request timed out after 30s'),
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
    final treatments = List<String>.from((dd['treatments'] as List?) ?? []);
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

    // Skin validation already done in _preprocessAndValidateImage on original image.
    // decoded here is already the 224x224 preprocessed file — skip re-validation.

    // ── Step 1: Build input tensor from 224x224 image ────────
    final int w = decoded.width;
    final int h = decoded.height;
    final inputBuffer = Float32List(w * h * 3);
    int idx = 0;
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        final pixel = decoded.getPixel(x, y);
        inputBuffer[idx++] = pixel.r / 255.0;
        inputBuffer[idx++] = pixel.g / 255.0;
        inputBuffer[idx++] = pixel.b / 255.0;
      }
    }

    // ── Step 2: Run inference ─────────────────────────────────
    final input = inputBuffer.reshape([1, _inputSize, _inputSize, 3]);
    final outputBuffer = Float32List(7);
    final output = outputBuffer.reshape([1, 7]);
    _interpreter!.run(input, output);

    // ── Step 3: Entropy check ─────────────────────────────────
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

    // ── Step 4: Top class ─────────────────────────────────────
    int topIdx = 0;
    for (int i = 1; i < outputBuffer.length; i++) {
      if (outputBuffer[i] > outputBuffer[topIdx]) topIdx = i;
    }
    final confidence = outputBuffer[topIdx];

    // ── Step 5: Confidence check ──────────────────────────────
    debugPrint(
      '📱 Local confidence: ${(confidence * 100).toStringAsFixed(1)}%',
    );
    if (confidence < _minConfidence) {
      throw NotSkinImageException(
        'This image does not strongly match any of our 7 supported skin diseases '
        '(confidence: ${(confidence * 100).toStringAsFixed(0)}% < 50%). '
        'It may be healthy skin or an unsupported condition.',
      );
    }

    // ── Step 6: Build result ──────────────────────────────────
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

  // ─── Skin metrics helper ─────────────────────────────────
  /// Returns (skinRatio, yStd, yStdBorder) from a 64x64 thumbnail of [img].
  (double, double, double) _computeSkinMetrics(img_lib.Image img) {
    final small = img_lib.copyResize(img, width: 64, height: 64);
    int skinCount = 0;
    const total = 64 * 64;
    double sumY = 0.0;
    final yVals = List.filled(total, 0.0);
    int i = 0;

    double sumBorderY = 0.0;
    int borderCount = 0;

    for (int y = 0; y < 64; y++) {
      for (int x = 0; x < 64; x++) {
        final p = small.getPixel(x, y);
        final r = p.r.toDouble();
        final g = p.g.toDouble();
        final b = p.b.toDouble();
        final yv = 0.299 * r + 0.587 * g + 0.114 * b;
        final cr = (r - yv) * 0.713 + 128;
        final cb = (b - yv) * 0.564 + 128;
        yVals[i++] = yv;
        sumY += yv;
        if (cr >= 125 && cr <= 175 && cb >= 75 && cb <= 135) skinCount++;

        // Border is the outer 8 pixels of the 64x64 grid
        if (y < 8 || y >= 56 || x < 8 || x >= 56) {
          sumBorderY += yv;
          borderCount++;
        }
      }
    }

    final meanY = sumY / total;
    double sumSq = 0.0;
    for (final yv in yVals) {
      final d = yv - meanY;
      sumSq += d * d;
    }

    final meanBorderY = sumBorderY / borderCount;
    double sumSqBorder = 0.0;
    i = 0;
    for (int y = 0; y < 64; y++) {
      for (int x = 0; x < 64; x++) {
        final yv = yVals[i++];
        if (y < 8 || y >= 56 || x < 8 || x >= 56) {
          final d = yv - meanBorderY;
          sumSqBorder += d * d;
        }
      }
    }

    return (
      skinCount / total,
      math.sqrt(sumSq / total),
      math.sqrt(sumSqBorder / borderCount),
    );
  }

  // ─── Local skin validator ─────────────────────────────────────
  void _validateSkinImageLocal(img_lib.Image img) {
    final (skinRatio, _, __) = _computeSkinMetrics(img);

    debugPrint(
      '\ud83d\udcf1 Skin ratio: ${(skinRatio * 100).toStringAsFixed(1)}%',
    );

    // Only reject if no skin pixels at all — not a skin image
    // All other checks (healthy skin, texture) are handled by the API
    if (skinRatio < _skinRatioThreshold) {
      throw NotSkinImageException(
        'This image does not seem to contain recognizable skin '
        '(skin pixel ratio: ${(skinRatio * 100).toStringAsFixed(0)}% < 10%). '
        'Please upload a clear photo of the affected skin area.',
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
