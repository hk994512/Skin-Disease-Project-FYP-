# =============================================================
# FastAPI Backend — Skin Disease Prediction API
# Serves the TFLite model via REST endpoint for Flutter app
# =============================================================

from contextlib import asynccontextmanager
from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import numpy as np
import tensorflow as tf
from PIL import Image
import io
import uvicorn
import logging
import random

# ─── Determinism ──────────────────────────────────────────────
random.seed(42)
np.random.seed(42)
tf.keras.utils.set_random_seed(42)
tf.config.experimental.enable_op_determinism()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# ─── Constants ────────────────────────────────────────────────
IMG_SIZE   = (224, 224)
MODEL_PATH = "../assets/models/skin_disease_model.tflite"

# ── Thresholds ────────────────────────────────────────────────
MIN_CONFIDENCE        = 0.65   # increased to reject healthy skin guesses
# High entropy → model is completely confused. Max for 7 classes is 1.945.
MAX_ENTROPY_THRESHOLD = 1.50

CLASS_INFO = {
    0: {"code": "akiec", "name": "Actinic Keratoses",    "risk": "High",     "color": "#FF4444"},
    1: {"code": "bcc",   "name": "Basal Cell Carcinoma", "risk": "High",     "color": "#FF4444"},
    2: {"code": "bkl",   "name": "Benign Keratosis",     "risk": "Low",      "color": "#44BB44"},
    3: {"code": "df",    "name": "Dermatofibroma",        "risk": "Low",      "color": "#44BB44"},
    4: {"code": "mel",   "name": "Melanoma",              "risk": "Critical", "color": "#AA0000"},
    5: {"code": "nv",    "name": "Melanocytic Nevi",      "risk": "Low",      "color": "#44BB44"},
    6: {"code": "vasc",  "name": "Vascular Lesions",      "risk": "Medium",   "color": "#FFAA00"},
}

ADVICE = {
    "Critical": "⚠️ Seek immediate dermatologist consultation.",
    "High":     "Please schedule a dermatologist appointment soon.",
    "Medium":   "Monitor the lesion and consult a doctor if it changes.",
    "Low":      "Likely benign. Monitor regularly and use sun protection.",
}

# ─── Detailed Disease Information ─────────────────────────────
DISEASE_DETAILS = {
    "akiec": {
        "full_name":        "Actinic Keratoses & Intraepithelial Carcinoma",
        "also_known_as":    "Solar Keratosis, Bowen's Disease",
        "description":      "Actinic keratoses are rough, scaly patches on the skin caused by years of sun exposure. They are considered pre-cancerous lesions because they can progress to squamous cell carcinoma if left untreated. They commonly appear on sun-exposed areas such as the face, scalp, ears, neck, forearms, and hands.",
        "appearance":       "Rough, dry, scaly patch of skin, typically less than 1 inch in diameter. May be flat or slightly raised, pink, red, or brown in color. The surface may be hard and wart-like.",
        "causes":           "Prolonged or repeated exposure to ultraviolet (UV) radiation from sunlight or tanning beds. More common in people with fair skin, light hair, and light eyes.",
        "symptoms": [
            "Rough, dry, scaly patch of skin",
            "Flat to slightly raised patch on the top layer of skin",
            "Hard, wart-like surface in some cases",
            "Color variations: pink, red, or brown",
            "Itching, burning, or tenderness in the affected area",
            "New patches appearing on sun-exposed skin"
        ],
        "treatment": [
            "Cryotherapy (freezing with liquid nitrogen)",
            "Topical medications: fluorouracil (5-FU), imiquimod, diclofenac",
            "Photodynamic therapy (PDT)",
            "Laser resurfacing",
            "Chemical peeling",
            "Surgical excision for thicker lesions"
        ],
        "prevention": [
            "Apply broad-spectrum SPF 30+ sunscreen daily",
            "Wear protective clothing and wide-brimmed hats",
            "Avoid peak sun hours (10am–4pm)",
            "Never use tanning beds",
            "Get regular skin checks by a dermatologist"
        ],
        "when_to_see_doctor": "See a doctor if the patch bleeds, grows rapidly, becomes very tender, or does not heal within a few weeks.",
        "prognosis":          "With early treatment, prognosis is excellent. Untreated lesions have a 5–10% chance of progressing to squamous cell carcinoma over 10 years.",
        "affected_population": "Most common in adults over 40 with a history of significant sun exposure. Higher incidence in Australia, South Africa, and other high-UV regions.",
    },

    "bcc": {
        "full_name":        "Basal Cell Carcinoma",
        "also_known_as":    "BCC, Rodent Ulcer (in advanced cases)",
        "description":      "Basal cell carcinoma is the most common form of skin cancer worldwide. It originates in the basal cells — the cells that line the deepest layer of the epidermis. While it rarely spreads to other parts of the body, it can cause significant local destruction if left untreated, invading surrounding tissue, nerves, and bone.",
        "appearance":       "Pearly or waxy bump, often with visible blood vessels. May appear as a flat, flesh-colored or brown scar-like lesion. Can also present as a bleeding or scabbing sore that heals and returns.",
        "causes":           "Cumulative UV radiation exposure is the primary cause. Genetic mutations in the PTCH1 gene (Hedgehog signaling pathway) are commonly involved. Risk increases with radiation therapy, arsenic exposure, and immunosuppression.",
        "symptoms": [
            "Pearly or waxy bump on face, ears, or neck",
            "Flat, flesh-colored or brown scar-like lesion on chest or back",
            "Bleeding or scabbing sore that heals and returns",
            "Pink growth with raised edges and a crusted center",
            "White, waxy, scar-like lesion without a clearly defined border",
            "Visible blood vessels (telangiectasia) on the surface"
        ],
        "treatment": [
            "Mohs micrographic surgery (gold standard for high-risk areas)",
            "Surgical excision with clear margins",
            "Electrodesiccation and curettage (ED&C)",
            "Cryotherapy for superficial lesions",
            "Topical imiquimod or fluorouracil for superficial BCC",
            "Radiation therapy for inoperable cases",
            "Vismodegib or sonidegib (Hedgehog pathway inhibitors) for advanced BCC"
        ],
        "prevention": [
            "Daily use of broad-spectrum SPF 50+ sunscreen",
            "Protective clothing, hats, and UV-blocking sunglasses",
            "Avoid tanning beds completely",
            "Regular annual skin examinations",
            "Self-examination monthly for new or changing lesions"
        ],
        "when_to_see_doctor": "Seek immediate evaluation for any sore that does not heal, a new shiny bump, or any lesion that bleeds without injury.",
        "prognosis":          "Excellent with early treatment. Cure rates exceed 95% with appropriate surgery. Recurrence is possible, especially in high-risk locations like the nose and ears.",
        "affected_population": "Most common in people over 50 with fair skin. Incidence is rising in younger adults due to tanning bed use and increased UV exposure.",
    },

    "bkl": {
        "full_name":        "Benign Keratosis-like Lesions",
        "also_known_as":    "Seborrheic Keratosis, Solar Lentigo, Lichen Planus-like Keratosis",
        "description":      "Benign keratosis-like lesions are a group of non-cancerous skin growths that commonly appear as people age. Seborrheic keratoses are among the most common benign skin tumors in adults. They are completely harmless and do not require treatment unless they cause discomfort or cosmetic concern.",
        "appearance":       "Waxy, scaly, slightly elevated growths. Color ranges from light tan to black. They often have a 'stuck-on' appearance, as if they could be scraped off. Surface may be smooth or warty.",
        "causes":           "Exact cause is unknown. Strongly associated with aging and sun exposure. Genetic predisposition plays a role — they tend to run in families. Not caused by viruses or bacteria.",
        "symptoms": [
            "Waxy, rough, or scaly growth on skin surface",
            "'Stuck-on' appearance — looks pasted onto the skin",
            "Color ranging from light tan to dark brown or black",
            "Round or oval shape, typically 1mm to several centimeters",
            "Itching in some cases, especially when irritated by clothing",
            "Multiple lesions often appearing simultaneously"
        ],
        "treatment": [
            "No treatment required for asymptomatic lesions",
            "Cryotherapy (liquid nitrogen) for cosmetic removal",
            "Electrocautery and curettage",
            "Laser ablation",
            "Hydrogen peroxide 40% topical solution (Eskata — FDA approved)",
            "Shave excision for irritated or symptomatic lesions"
        ],
        "prevention": [
            "Sun protection may slow development of new lesions",
            "Regular moisturizing to reduce irritation",
            "Avoid scratching or picking at lesions",
            "Annual skin checks to monitor for changes"
        ],
        "when_to_see_doctor": "See a doctor if a lesion changes rapidly, bleeds, becomes painful, or looks significantly different from your other seborrheic keratoses.",
        "prognosis":          "Excellent. These are benign lesions with no malignant potential. They may increase in number with age but pose no health risk.",
        "affected_population": "Extremely common in adults over 50. Affects men and women equally. Rare before age 30.",
    },

    "df": {
        "full_name":        "Dermatofibroma",
        "also_known_as":    "Benign Fibrous Histiocytoma, Cutaneous Fibrous Histiocytoma",
        "description":      "Dermatofibromas are common, benign skin growths that consist of fibrous tissue. They are firm nodules that most often appear on the legs, though they can occur anywhere on the body. They are completely harmless and rarely require treatment.",
        "appearance":       "Small, firm, raised bump. Usually brown, pink, or reddish in color. Characteristically dimples inward when pinched (positive 'dimple sign'). Typically 0.5–1.5 cm in diameter.",
        "causes":           "Exact cause unknown. May be triggered by minor trauma such as insect bites, thorn pricks, or folliculitis. Represents a reactive proliferation of dermal fibroblasts.",
        "symptoms": [
            "Small, hard bump under the skin surface",
            "Brown, pink, or reddish color",
            "Dimples inward when pinched (pathognomonic dimple sign)",
            "Usually painless but may be tender or itchy",
            "Slow-growing and stable over years",
            "Most commonly found on lower legs"
        ],
        "treatment": [
            "No treatment necessary for asymptomatic lesions",
            "Surgical excision if symptomatic or cosmetically bothersome",
            "Cryotherapy for superficial lesions",
            "Steroid injections to flatten the lesion",
            "Laser treatment for cosmetic improvement"
        ],
        "prevention": [
            "No specific prevention known",
            "Protect skin from minor injuries and insect bites",
            "Use insect repellent in endemic areas"
        ],
        "when_to_see_doctor": "Consult a doctor if the lesion grows rapidly, becomes painful, bleeds, or changes color significantly.",
        "prognosis":          "Excellent. Dermatofibromas are benign and do not become cancerous.",
        "affected_population": "Most common in young to middle-aged adults. More frequent in women than men. Rare in children.",
    },

    "mel": {
        "full_name":        "Melanoma",
        "also_known_as":    "Malignant Melanoma, Cutaneous Melanoma",
        "description":      "Melanoma is the most dangerous form of skin cancer, arising from the pigment-producing cells (melanocytes). Although less common than basal cell or squamous cell carcinoma, melanoma is far more likely to spread to other parts of the body if not caught early.",
        "appearance":       "Follows the ABCDE rule: Asymmetry, Border irregularity, Color variation (multiple shades of brown, black, red, white, or blue), Diameter greater than 6mm, and Evolution (changing over time).",
        "causes":           "UV radiation from sun and tanning beds is the primary cause. Genetic mutations (BRAF, NRAS, NF1) play a major role. Risk factors include fair skin, family history of melanoma, many moles, weakened immune system.",
        "symptoms": [
            "Asymmetrical mole — one half doesn't match the other",
            "Irregular, ragged, notched, or blurred border",
            "Multiple colors within the same lesion",
            "Diameter larger than 6mm",
            "Evolving — any change in size, shape, color, or new symptom",
            "Itching, bleeding, or oozing from a mole",
            "Satellite lesions appearing near the original mole",
            "Swollen lymph nodes near the lesion (advanced stage)"
        ],
        "treatment": [
            "Wide local excision (primary treatment for early-stage)",
            "Sentinel lymph node biopsy to check for spread",
            "Immunotherapy: pembrolizumab, nivolumab (PD-1 inhibitors)",
            "Targeted therapy: vemurafenib, dabrafenib (BRAF inhibitors)",
            "Combination therapy: BRAF + MEK inhibitors",
            "Radiation therapy for brain or bone metastases",
            "Chemotherapy (less common, for refractory cases)",
            "Clinical trials for advanced or metastatic melanoma"
        ],
        "prevention": [
            "Apply SPF 50+ broad-spectrum sunscreen every 2 hours outdoors",
            "Wear UV-protective clothing, hats, and sunglasses",
            "Avoid tanning beds — they increase melanoma risk by 75%",
            "Perform monthly self-skin examinations",
            "Annual full-body skin exam by a dermatologist",
            "Know your moles — photograph them to track changes"
        ],
        "when_to_see_doctor": "⚠️ URGENT — See a dermatologist immediately if any mole changes in size, shape, or color, or if a new unusual growth appears.",
        "prognosis":          "Stage I: 5-year survival ~98%. Stage II: ~65%. Stage III: ~45%. Stage IV: ~25% but improving with immunotherapy.",
        "affected_population": "Can affect anyone but most common in fair-skinned individuals. Incidence peaks between ages 45–54.",
    },

    "nv": {
        "full_name":        "Melanocytic Nevi",
        "also_known_as":    "Common Mole, Nevus, Benign Melanocytic Nevus",
        "description":      "Melanocytic nevi, commonly known as moles, are benign growths on the skin that form when pigment cells (melanocytes) grow in clusters. Most people have between 10 and 40 moles. They are almost always harmless.",
        "appearance":       "Round or oval, with a smooth, well-defined border. Uniform color — tan, brown, or black. Usually less than 6mm in diameter. May be flat or raised.",
        "causes":           "Formed when melanocytes grow in a cluster instead of spreading throughout the skin. Sun exposure can increase the number of moles. Genetic factors also play a role.",
        "symptoms": [
            "Small, round or oval growth on the skin",
            "Uniform brown, tan, or black color",
            "Smooth, well-defined borders",
            "Flat or slightly raised surface",
            "Usually less than 6mm in diameter",
            "May have hair growing from the surface",
            "Generally stable — not changing over time"
        ],
        "treatment": [
            "No treatment required for typical benign moles",
            "Surgical excision if mole shows atypical features",
            "Shave excision for cosmetic removal of raised moles",
            "Laser removal (not recommended for suspicious moles)",
            "Regular monitoring with dermoscopy by a dermatologist"
        ],
        "prevention": [
            "Sun protection to prevent new moles from forming",
            "Avoid sunburn, especially in childhood",
            "Regular self-examination using the ABCDE rule",
            "Annual dermatologist skin check for people with many moles"
        ],
        "when_to_see_doctor": "See a doctor if a mole changes in size, shape, or color, develops irregular borders, bleeds, or itches.",
        "prognosis":          "Excellent for benign nevi. The lifetime risk of any single mole becoming melanoma is very low.",
        "affected_population": "Universal — affects people of all ages, skin types, and ethnicities.",
    },

    "vasc": {
        "full_name":        "Vascular Lesions",
        "also_known_as":    "Angiomas, Pyogenic Granuloma, Hemangioma, Port-Wine Stain",
        "description":      "Vascular lesions are abnormalities of blood vessels in the skin. They encompass cherry angiomas, spider angiomas, pyogenic granulomas, and port-wine stains. Most are benign and harmless.",
        "appearance":       "Varies widely by type. Cherry angiomas appear as small, bright red domes. Spider angiomas have a central red spot with radiating vessels. Pyogenic granulomas are red, moist, rapidly growing nodules.",
        "causes":           "Caused by abnormal proliferation or dilation of blood vessels. Cherry angiomas are associated with aging. Pyogenic granulomas may follow minor trauma or hormonal changes.",
        "symptoms": [
            "Bright red, purple, or bluish discoloration on skin",
            "Small dome-shaped red bumps (cherry angiomas)",
            "Spider-like pattern of blood vessels radiating from a center",
            "Rapidly growing red nodule that bleeds easily (pyogenic granuloma)",
            "Flat pink-to-red birthmark that darkens with age (port-wine stain)",
            "Soft, compressible texture in most lesion types",
            "Occasional bleeding with minimal trauma"
        ],
        "treatment": [
            "No treatment required for asymptomatic cherry angiomas",
            "Laser therapy (pulsed dye laser) — most effective for vascular lesions",
            "Electrocautery for cherry angiomas and spider angiomas",
            "Surgical excision for pyogenic granulomas",
            "Sclerotherapy for larger vascular malformations",
            "Timolol or propranolol for infantile hemangiomas"
        ],
        "prevention": [
            "Sun protection to reduce development of new lesions",
            "Avoid skin trauma that can trigger pyogenic granulomas",
            "Regular monitoring for any rapid growth or bleeding"
        ],
        "when_to_see_doctor": "See a doctor if a vascular lesion bleeds frequently, grows rapidly, is painful, or appears suddenly.",
        "prognosis":          "Excellent for most vascular lesions. They are benign and do not become cancerous.",
        "affected_population": "Cherry angiomas are extremely common in adults over 30. Pyogenic granulomas are common in children and pregnant women.",
    },
}

# ─── App State ────────────────────────────────────────────────
class AppState:
    def __init__(self):
        self.interpreter: tf.lite.Interpreter | None = None

app_state = AppState()

# ─── Lifespan ─────────────────────────────────────────────────
@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        app_state.interpreter = tf.lite.Interpreter(model_path=MODEL_PATH)
        app_state.interpreter.allocate_tensors()
        logger.info("✅ TFLite model loaded successfully")
    except Exception as e:
        logger.error(f"❌ Failed to load model: {e}")
        raise RuntimeError(f"Model loading failed: {e}")
    yield
    app_state.interpreter = None
    logger.info("Model released on shutdown")

app = FastAPI(
    title="Skin Disease Prediction API",
    description="CNN-based dermatology classifier (HAM10000)",
    version="2.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Response Schema ──────────────────────────────────────────
class DiseaseDetail(BaseModel):
    full_name:           str
    also_known_as:       str
    description:         str
    appearance:          str
    causes:              str
    symptoms:            List[str]
    treatment:           List[str]
    prevention:          List[str]
    when_to_see_doctor:  str
    prognosis:           str
    affected_population: str

class PredictionResult(BaseModel):
    predicted_class:  str
    display_name:     str
    confidence:       float
    risk_level:       str
    risk_color:       str
    advice:           str
    all_predictions:  List[dict]
    disease_detail:   Optional[DiseaseDetail] = None

# ─── Skin Validation ──────────────────────────────────────────
def is_likely_skin_image(img: Image.Image) -> tuple[bool, str]:
    """
    Heuristic to reject plain hands and healthy skin.
    """
    img_rgb = img.convert("RGB").resize((64, 64))
    arr = np.array(img_rgb, dtype=np.float32)

    r, g, b = arr[:, :, 0], arr[:, :, 1], arr[:, :, 2]
    y = 0.299 * r + 0.587 * g + 0.114 * b
    cr = (r - y) * 0.713 + 128
    cb = (b - y) * 0.564 + 128

    # Standard YCrCb skin color thresholds
    skin_mask = (cr >= 133) & (cr <= 173) & (cb >= 77) & (cb <= 127)
    skin_ratio = float(np.sum(skin_mask)) / (64 * 64)
    
    y_std = float(np.std(y))

    # If the image is ALMOST ENTIRELY skin colored AND very flat (low variance),
    # it is almost certainly a plain hand or healthy skin.
    if skin_ratio > 0.85 and y_std < 25.0:
        return False, "Healthy skin detected. Please capture a clear photo centered on a visible skin lesion."

    return True, "ok"

def compute_entropy(probabilities: np.ndarray) -> float:
    """Shannon entropy — high value means model is very uncertain (not skin)."""
    probs = np.clip(probabilities, 1e-9, 1.0)
    return float(-np.sum(probs * np.log(probs)))

# ─── Preprocessing ────────────────────────────────────────────
def preprocess_image(image_bytes: bytes) -> tuple[np.ndarray, Image.Image]:
    with io.BytesIO(image_bytes) as buf:
        try:
            img = Image.open(buf).convert("RGB")
            resized = img.resize(IMG_SIZE, Image.LANCZOS)
            arr = np.array(resized, dtype=np.float32) / 255.0
            return np.expand_dims(arr, axis=0), img
        except Exception as e:
            raise HTTPException(status_code=400, detail=f"Image processing failed: {e}")

# ─── Inference ────────────────────────────────────────────────
def run_inference(input_tensor: np.ndarray) -> np.ndarray:
    if app_state.interpreter is None:
        raise HTTPException(status_code=503, detail="Model not loaded yet.")
    input_details  = app_state.interpreter.get_input_details()
    output_details = app_state.interpreter.get_output_details()
    app_state.interpreter.set_tensor(input_details[0]["index"], input_tensor)
    app_state.interpreter.invoke()
    return app_state.interpreter.get_tensor(output_details[0]["index"])[0]

# ─── Endpoints ────────────────────────────────────────────────

@app.get("/")
def root():
    return {"message": "Skin Disease Prediction API is running 🚀"}

@app.get("/health")
def health():
    return {"status": "ok", "model_loaded": app_state.interpreter is not None}

@app.get("/classes")
def get_classes():
    return {"classes": CLASS_INFO}

@app.get("/disease/{code}", response_model=DiseaseDetail)
def get_disease_detail(code: str):
    if code not in DISEASE_DETAILS:
        raise HTTPException(status_code=404, detail=f"Disease code '{code}' not found.")
    return DiseaseDetail(**DISEASE_DETAILS[code])

@app.get("/test_model")
def test_model():
    if app_state.interpreter is None:
        raise HTTPException(status_code=503, detail="Model not loaded.")
    tests = {
        "black_image":  np.zeros((1, 224, 224, 3), dtype=np.float32),
        "white_image":  np.ones((1, 224, 224, 3),  dtype=np.float32),
        "grey_image":   np.full((1, 224, 224, 3), 0.5, dtype=np.float32),
        "random_noise": np.random.rand(1, 224, 224, 3).astype(np.float32),
    }
    results = {}
    for name, tensor in tests.items():
        probs = run_inference(tensor)
        pred_idx = int(np.argmax(probs))
        results[name] = {
            "predicted":   CLASS_INFO[pred_idx]["name"],
            "confidence":  f"{float(probs[pred_idx]):.2%}",
            "all_probs":   {CLASS_INFO[i]["code"]: round(float(p), 4) for i, p in enumerate(probs)},
        }
    all_same = len({v["predicted"] for v in results.values()}) == 1
    return {
        "model_biased": all_same,
        "warning": "Model always predicts the same class — retrain!" if all_same else "Model looks healthy.",
        "results": results,
    }

@app.post("/predict", response_model=PredictionResult)
async def predict(file: UploadFile = File(...)):
    """
    Upload a skin lesion image. Returns full prediction with disease details.
    Returns 422 if the image does not appear to be a skin lesion.
    """
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files are supported.")

    image_bytes = await file.read()
    if len(image_bytes) > 10 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="Image too large. Max 10MB.")

    # ── Step 1: Preprocess ────────────────────────────────────
    input_tensor, original_img = preprocess_image(image_bytes)

    # ── Step 2: Skin heuristic check ─────────────────────────
    is_skin, reason = is_likely_skin_image(original_img)
    if not is_skin:
        raise HTTPException(
            status_code=422,
            detail={
                "error": "not_skin_image",
                "message": reason,
                "hint": "Ensure the lesion is clearly visible and centered."
            }
        )

    # ── Step 3: Run TFLite inference ─────────────────────────────────────
    probabilities = run_inference(input_tensor)

    # ── Step 4: Entropy check (model confusion = not skin) ────
    entropy = compute_entropy(probabilities)
    logger.info(f"Prediction entropy: {entropy:.4f}")

    predicted_idx = int(np.argmax(probabilities))
    confidence    = float(probabilities[predicted_idx])

    # ── Step 6: Build response ────────────────────────────────
    info = CLASS_INFO[predicted_idx]
    code = info["code"]

    all_preds = [
        {
            "index":       i,
            "code":        CLASS_INFO[i]["code"],
            "name":        CLASS_INFO[i]["name"],
            "probability": round(float(p), 6),
        }
        for i, p in enumerate(probabilities)
    ]
    all_preds.sort(key=lambda x: x["probability"], reverse=True)

    detail = DiseaseDetail(**DISEASE_DETAILS[code]) if code in DISEASE_DETAILS else None

    logger.info(f"✅ Prediction: {info['name']} ({confidence:.2%}) | entropy: {entropy:.3f}")

    return PredictionResult(
        predicted_class = code,
        display_name    = info["name"],
        confidence      = round(confidence, 6),
        risk_level      = info["risk"],
        risk_color      = info["color"],
        advice          = ADVICE[info["risk"]],
        all_predictions = all_preds,
        disease_detail  = detail,
    )

# ─── Run ──────────────────────────────────────────────────────
if __name__ == "__main__":
    uvicorn.run("api:app", host="0.0.0.0", port=8000, reload=True)