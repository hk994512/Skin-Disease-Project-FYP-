# =============================================================
# FastAPI Backend — Skin Disease Prediction API
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

random.seed(42)
np.random.seed(42)
tf.keras.utils.set_random_seed(42)
tf.config.experimental.enable_op_determinism()

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

IMG_SIZE   = (224, 224)
MODEL_PATH = "../assets/models/skin_disease_model.tflite"

# ── Thresholds ────────────────────────────────────────────────
MIN_SKIN_PIXEL_RATIO = 0.08   # < 8%  → not a skin image
MIN_CONFIDENCE       = 0.55   # < 55% → weak match → rejected
MAX_ENTROPY          = 1.60   # > 1.60 → model confused → rejected

# Healthy skin gate
# skin_ratio > 90% AND y_std < 30 → reject as healthy
# Diseased images always have y_std > 30 due to lesion contrast
HEALTHY_RATIO_MIN    = 0.90   # skin must cover > 90% of image
HEALTHY_YSTD_MAX     = 30.0   # AND luma std < 30 (healthy had 37 → will PASS now)

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

DISEASE_DETAILS = {
    "akiec": {
        "full_name":           "Actinic Keratoses & Intraepithelial Carcinoma",
        "also_known_as":       "Solar Keratosis, Bowen's Disease",
        "description":         "Actinic keratoses are rough, scaly patches on the skin caused by years of sun exposure. They are considered pre-cancerous lesions.",
        "appearance":          "Rough, dry, scaly patch of skin, typically less than 1 inch in diameter. May be flat or slightly raised, pink, red, or brown in color.",
        "causes":              "Prolonged UV radiation exposure. More common in people with fair skin.",
        "symptoms": ["Rough, dry, scaly patch","Flat to slightly raised patch","Hard, wart-like surface in some cases","Color variations: pink, red, or brown","Itching or burning","New patches on sun-exposed skin"],
        "treatments": ["Cryotherapy","Topical fluorouracil (5-FU), imiquimod","Photodynamic therapy","Laser resurfacing","Chemical peeling","Surgical excision"],
        "prevention": ["SPF 30+ sunscreen daily","Protective clothing","Avoid peak sun hours","No tanning beds","Regular skin checks"],
        "when_to_see_doctor":  "See a doctor if the patch bleeds, grows rapidly, or does not heal.",
        "prognosis":           "Excellent with early treatment.",
        "affected_population": "Most common in adults over 40 with heavy sun exposure.",
    },
    "bcc": {
        "full_name":           "Basal Cell Carcinoma",
        "also_known_as":       "BCC, Rodent Ulcer",
        "description":         "The most common form of skin cancer worldwide. Originates in basal cells.",
        "appearance":          "Pearly or waxy bump, often with visible blood vessels.",
        "causes":              "Cumulative UV radiation exposure. PTCH1 gene mutations.",
        "symptoms": ["Pearly or waxy bump","Flat scar-like lesion","Bleeding or scabbing sore","Pink growth with raised edges","Visible blood vessels"],
        "treatments": ["Mohs surgery","Surgical excision","Cryotherapy","Topical imiquimod","Radiation therapy","Vismodegib for advanced BCC"],
        "prevention": ["SPF 50+ sunscreen","Protective clothing","Avoid tanning beds","Annual skin exams"],
        "when_to_see_doctor":  "Seek evaluation for any sore that does not heal.",
        "prognosis":           "Cure rates exceed 95% with early surgery.",
        "affected_population": "Most common in people over 50 with fair skin.",
    },
    "bkl": {
        "full_name":           "Benign Keratosis-like Lesions",
        "also_known_as":       "Seborrheic Keratosis, Solar Lentigo",
        "description":         "Non-cancerous skin growths common with aging. Completely harmless.",
        "appearance":          "Waxy, scaly growths with a stuck-on appearance. Light tan to black.",
        "causes":              "Associated with aging and sun exposure. Genetic predisposition.",
        "symptoms": ["Waxy or scaly growth","Stuck-on appearance","Light tan to dark brown","Round or oval shape","Occasional itching"],
        "treatments": ["No treatment needed","Cryotherapy","Electrocautery","Laser ablation","Shave excision"],
        "prevention": ["Sun protection","Moisturizing","Avoid picking"],
        "when_to_see_doctor":  "See a doctor if it bleeds or changes rapidly.",
        "prognosis":           "Excellent. No malignant potential.",
        "affected_population": "Extremely common in adults over 50.",
    },
    "df": {
        "full_name":           "Dermatofibroma",
        "also_known_as":       "Benign Fibrous Histiocytoma",
        "description":         "Common benign fibrous skin growths, most often on the legs.",
        "appearance":          "Small, firm bump. Brown, pink, or reddish. Dimples inward when pinched.",
        "causes":              "May be triggered by minor trauma like insect bites.",
        "symptoms": ["Small hard bump","Brown or reddish color","Dimples inward when pinched","Usually painless","Slow-growing"],
        "treatments": ["No treatment needed","Surgical excision","Cryotherapy","Steroid injections"],
        "prevention": ["Protect skin from minor injuries"],
        "when_to_see_doctor":  "Consult if it grows rapidly, bleeds, or changes color.",
        "prognosis":           "Excellent. Does not become cancerous.",
        "affected_population": "Most common in young to middle-aged adults.",
    },
    "mel": {
        "full_name":           "Melanoma",
        "also_known_as":       "Malignant Melanoma",
        "description":         "The most dangerous form of skin cancer. Arises from melanocytes.",
        "appearance":          "Follows ABCDE rule: Asymmetry, Border irregularity, Color variation, Diameter > 6mm, Evolution.",
        "causes":              "UV radiation. BRAF, NRAS, NF1 mutations. Fair skin and family history.",
        "symptoms": ["Asymmetrical mole","Irregular border","Multiple colors","Diameter > 6mm","Changing size/shape","Bleeding or itching"],
        "treatments": ["Wide local excision","Sentinel lymph node biopsy","Immunotherapy (pembrolizumab)","Targeted therapy (BRAF inhibitors)","Radiation therapy","Clinical trials"],
        "prevention": ["SPF 50+ sunscreen","UV-protective clothing","No tanning beds","Monthly self-exams","Annual dermatologist exam"],
        "when_to_see_doctor":  "⚠️ URGENT — See a dermatologist immediately for any changing mole.",
        "prognosis":           "Stage I: ~98% survival. Stage IV: ~25%.",
        "affected_population": "Most common in fair-skinned individuals. Peaks at ages 45–54.",
    },
    "nv": {
        "full_name":           "Melanocytic Nevi",
        "also_known_as":       "Common Mole, Nevus",
        "description":         "Benign moles formed when melanocytes grow in clusters. Almost always harmless.",
        "appearance":          "Round or oval, smooth border, uniform tan/brown/black. Usually < 6mm.",
        "causes":              "Melanocytes grow in clusters. Sun exposure and genetics.",
        "symptoms": ["Round or oval growth","Uniform brown or black color","Smooth borders","Flat or slightly raised","Stable over time"],
        "treatments": ["No treatment needed","Excision if atypical","Shave excision cosmetically","Regular dermoscopy monitoring"],
        "prevention": ["Sun protection","Avoid sunburn","ABCDE self-exams"],
        "when_to_see_doctor":  "See a doctor if a mole changes, bleeds, or itches.",
        "prognosis":           "Excellent. Very low risk of becoming melanoma.",
        "affected_population": "Universal — all ages and skin types.",
    },
    "vasc": {
        "full_name":           "Vascular Lesions",
        "also_known_as":       "Angiomas, Pyogenic Granuloma, Hemangioma",
        "description":         "Abnormalities of blood vessels. Includes cherry angiomas, pyogenic granulomas, port-wine stains.",
        "appearance":          "Bright red domes (cherry angioma), spider pattern, or red moist nodules.",
        "causes":              "Abnormal blood vessel proliferation. Associated with aging or trauma.",
        "symptoms": ["Bright red or purple discoloration","Small red domes","Spider vessel pattern","Rapidly growing red nodule","Bleeds easily"],
        "treatments": ["No treatment for asymptomatic cases","Pulsed dye laser","Electrocautery","Surgical excision","Sclerotherapy"],
        "prevention": ["Sun protection","Avoid skin trauma"],
        "when_to_see_doctor":  "See a doctor if it bleeds frequently or grows rapidly.",
        "prognosis":           "Excellent. Benign and do not become cancerous.",
        "affected_population": "Cherry angiomas common in adults over 30.",
    },
}

# ─── App State ────────────────────────────────────────────────
class AppState:
    def __init__(self):
        self.interpreter: tf.lite.Interpreter | None = None

app_state = AppState()

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

app = FastAPI(title="Skin Disease Prediction API", version="2.0.0", lifespan=lifespan)
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

# ─── Schemas ──────────────────────────────────────────────────
class DiseaseDetail(BaseModel):
    full_name: str; also_known_as: str; description: str; appearance: str
    causes: str; symptoms: List[str]; treatments: List[str]; prevention: List[str]
    when_to_see_doctor: str; prognosis: str; affected_population: str

class PredictionResult(BaseModel):
    predicted_class: str; display_name: str; confidence: float
    risk_level: str; risk_color: str; advice: str
    all_predictions: List[dict]; disease_detail: Optional[DiseaseDetail] = None

# ─── Skin metrics ─────────────────────────────────────────────
def compute_skin_metrics(img: Image.Image) -> dict:
    small = img.convert("RGB").resize((64, 64))
    arr   = np.array(small, dtype=np.float32)
    r, g, b = arr[:,:,0], arr[:,:,1], arr[:,:,2]
    y   = 0.299*r + 0.587*g + 0.114*b
    cr  = (r - y)*0.713 + 128
    cb  = (b - y)*0.564 + 128
    mask       = (cr>=120)&(cr<=180)&(cb>=70)&(cb<=140)
    skin_ratio = float(np.sum(mask)) / (64*64)
    y_std      = float(np.std(y))
    r_std, g_std, b_std = float(np.std(r)), float(np.std(g)), float(np.std(b))
    max_ch_std = float(max(r_std, g_std, b_std))
    return {"skin_ratio": skin_ratio, "y_std": y_std,
            "r_std": r_std, "g_std": g_std, "b_std": b_std,
            "max_ch_std": max_ch_std}

def is_healthy_skin(m: dict) -> bool:
    return (
        m["skin_ratio"] > HEALTHY_RATIO_MIN and
        m["y_std"]      < HEALTHY_YSTD_MAX
    )

# ─── Preprocessing ────────────────────────────────────────────
def preprocess_image(image_bytes: bytes) -> np.ndarray:
    with io.BytesIO(image_bytes) as buf:
        img = Image.open(buf).convert("RGB")
        w, h  = img.size
        side  = min(w, h)
        left  = (w - side) // 2
        top   = (h - side) // 2
        img   = img.crop((left, top, left+side, top+side))
        img   = img.resize(IMG_SIZE, Image.LANCZOS)
        arr   = np.array(img, dtype=np.float32) / 255.0
        return np.expand_dims(arr, axis=0)

def compute_entropy(probs: np.ndarray) -> float:
    p = np.clip(probs, 1e-9, 1.0)
    return float(-np.sum(p * np.log(p)))

def run_inference(tensor: np.ndarray) -> np.ndarray:
    if app_state.interpreter is None:
        raise HTTPException(status_code=503, detail="Model not loaded.")
    inp  = app_state.interpreter.get_input_details()
    out  = app_state.interpreter.get_output_details()
    app_state.interpreter.set_tensor(inp[0]["index"], tensor)
    app_state.interpreter.invoke()
    return app_state.interpreter.get_tensor(out[0]["index"])[0]

# ─── Endpoints ────────────────────────────────────────────────
@app.get("/")
def root():
    return {"message": "Skin Disease Prediction API is running 🚀"}

@app.get("/health")
def health_check():
    return {"status": "ok", "model_loaded": app_state.interpreter is not None}

@app.get("/classes")
def get_classes():
    return {"classes": CLASS_INFO}

@app.get("/disease/{code}", response_model=DiseaseDetail)
def get_disease(code: str):
    if code not in DISEASE_DETAILS:
        raise HTTPException(status_code=404, detail=f"Code '{code}' not found.")
    return DiseaseDetail(**DISEASE_DETAILS[code])

# ─── DEBUG endpoint ───────────────────────────────────────────
@app.post("/debug_image")
async def debug_image(file: UploadFile = File(...)):
    """Upload any image — returns exact metrics + model prediction.
    Use this to tune HEALTHY_YSTD_MAX and HEALTHY_CHSTD_MAX thresholds."""
    image_bytes = await file.read()
    raw_img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    m       = compute_skin_metrics(raw_img)
    tensor  = preprocess_image(image_bytes)
    probs   = run_inference(tensor)
    entropy = compute_entropy(probs)
    idx     = int(np.argmax(probs))
    return {
        "metrics": {k: round(v, 3) for k, v in m.items()},
        "thresholds": {
            "HEALTHY_RATIO_MIN": HEALTHY_RATIO_MIN,
            "HEALTHY_YSTD_MAX":  HEALTHY_YSTD_MAX,
        },
        "heuristic": "REJECTED as healthy" if is_healthy_skin(m) else "PASSED",
        "model": {
            "predicted":  CLASS_INFO[idx]["name"],
            "confidence": f"{float(probs[idx]):.2%}",
            "entropy":    round(entropy, 4),
            "all_probs":  {CLASS_INFO[i]["code"]: round(float(p), 4) for i, p in enumerate(probs)},
        },
    }

# ─── PREDICT endpoint ─────────────────────────────────────────
@app.post("/predict", response_model=PredictionResult)
async def predict(file: UploadFile = File(...)):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Only image files supported.")

    image_bytes = await file.read()
    if len(image_bytes) > 10 * 1024 * 1024:
        raise HTTPException(status_code=400, detail="Image too large. Max 10MB.")

    raw_img = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    m       = compute_skin_metrics(raw_img)

    logger.info(
        f"skin_ratio={m['skin_ratio']:.2%} y_std={m['y_std']:.1f} "
        f"max_ch_std={m['max_ch_std']:.1f}"
    )

    # Layer 1: not a skin image
    if m["skin_ratio"] < MIN_SKIN_PIXEL_RATIO:
        raise HTTPException(status_code=422, detail={
            "error":   "not_skin_image",
            "message": f"No recognizable skin detected (skin ratio: {m['skin_ratio']:.0%}). Please upload a skin photo.",
            "hint":    "Ensure skin is clearly visible.",
        })

    # Layer 2: healthy skin (no lesion)
    if is_healthy_skin(m):
        raise HTTPException(status_code=422, detail={
            "error":   "healthy_skin",
            "message": f"This appears to be healthy skin (skin coverage: {m['skin_ratio']:.0%}, texture variance: {m['y_std']:.1f}). No skin lesion detected. Please upload a close-up photo clearly showing the affected lesion.",
            "hint":    "Ensure the lesion fills most of the frame and is in sharp focus.",
        })

    # Run model
    tensor  = preprocess_image(image_bytes)
    probs   = run_inference(tensor)
    entropy = compute_entropy(probs)
    idx     = int(np.argmax(probs))
    conf    = float(probs[idx])

    logger.info(f"entropy={entropy:.4f} confidence={conf:.2%} predicted={CLASS_INFO[idx]['name']}")

    # Layer 3: entropy too high
    if entropy > MAX_ENTROPY:
        raise HTTPException(status_code=422, detail={
            "error":   "high_uncertainty",
            "message": f"Model is uncertain (entropy: {entropy:.2f}). Image may not contain a supported skin disease.",
            "hint":    "Use a clearer, close-up photo.",
        })

    # Layer 4: confidence too low
    if conf < MIN_CONFIDENCE:
        raise HTTPException(status_code=422, detail={
            "error":   "low_confidence",
            "message": f"Image does not match any of the 7 supported diseases (confidence: {conf:.0%}). May be healthy skin.",
            "hint":    "Our model covers: Actinic Keratoses, BCC, Benign Keratosis, Dermatofibroma, Melanoma, Melanocytic Nevi, Vascular Lesions.",
        })

    info = CLASS_INFO[idx]
    code = info["code"]
    all_preds = sorted(
        [{"index": i, "code": CLASS_INFO[i]["code"], "name": CLASS_INFO[i]["name"],
          "probability": round(float(p), 6)} for i, p in enumerate(probs)],
        key=lambda x: x["probability"], reverse=True
    )
    detail = DiseaseDetail(**DISEASE_DETAILS[code]) if code in DISEASE_DETAILS else None
    logger.info(f"✅ {info['name']} ({conf:.2%}) entropy={entropy:.3f}")

    return PredictionResult(
        predicted_class=code, display_name=info["name"],
        confidence=round(conf, 6), risk_level=info["risk"],
        risk_color=info["color"], advice=ADVICE[info["risk"]],
        all_predictions=all_preds, disease_detail=detail,
    )

if __name__ == "__main__":
    uvicorn.run("api:app", host="0.0.0.0", port=8000, reload=True)
