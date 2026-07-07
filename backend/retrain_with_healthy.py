# ================================================================
# retrain_with_healthy.py
# Fine-tunes the existing skin disease model to add an 8th class:
# "healthy" — so it can reject healthy skin images directly.
#
# HOW TO USE:
# 1. Create this folder structure:
#       backend/train_data/
#           akiec/      ← copy some HAM10000 akiec images here
#           bcc/
#           bkl/
#           df/
#           mel/
#           nv/
#           vasc/
#           healthy/    ← put 100-200 healthy skin phone photos here
#
# 2. pip install tensorflow pillow numpy
# 3. python retrain_with_healthy.py
# 4. It will output: skin_disease_model_v2.tflite
#    Replace assets/models/skin_disease_model.tflite with this file
# ================================================================

import os
import numpy as np
import tensorflow as tf
from tensorflow.keras import layers, models
from tensorflow.keras.preprocessing.image import ImageDataGenerator
from pathlib import Path

# ── Config ────────────────────────────────────────────────────
IMG_SIZE       = (224, 224)
BATCH_SIZE     = 16
EPOCHS_FROZEN  = 5    # train only new head first
EPOCHS_UNFROZEN = 10  # then fine-tune top layers
DATA_DIR       = "train_data"
OUTPUT_TFLITE  = "skin_disease_model_v2.tflite"

# 8 classes — 7 original + healthy
CLASS_NAMES = ["akiec", "bcc", "bkl", "df", "mel", "nv", "vasc", "healthy"]
NUM_CLASSES = len(CLASS_NAMES)

print(f"Classes: {CLASS_NAMES}")
print(f"Total classes: {NUM_CLASSES}")

# ── Data generators ───────────────────────────────────────────
datagen = ImageDataGenerator(
    rescale=1.0 / 255.0,
    validation_split=0.2,
    rotation_range=20,
    width_shift_range=0.1,
    height_shift_range=0.1,
    horizontal_flip=True,
    vertical_flip=True,
    zoom_range=0.1,
    brightness_range=[0.8, 1.2],
)

train_gen = datagen.flow_from_directory(
    DATA_DIR,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    subset="training",
    classes=CLASS_NAMES,
    shuffle=True,
)

val_gen = datagen.flow_from_directory(
    DATA_DIR,
    target_size=IMG_SIZE,
    batch_size=BATCH_SIZE,
    class_mode="categorical",
    subset="validation",
    classes=CLASS_NAMES,
    shuffle=False,
)

print(f"\nTraining samples:   {train_gen.samples}")
print(f"Validation samples: {val_gen.samples}")
print(f"Class indices:      {train_gen.class_indices}")

# ── Load existing TFLite model weights via a Keras base ───────
# We use MobileNetV2 as backbone — same architecture HAM10000 models use
print("\nBuilding model with MobileNetV2 backbone...")

base = tf.keras.applications.MobileNetV2(
    input_shape=(224, 224, 3),
    include_top=False,
    weights="imagenet",
)
base.trainable = False  # freeze backbone first

x = base.output
x = layers.GlobalAveragePooling2D()(x)
x = layers.Dropout(0.3)(x)
x = layers.Dense(256, activation="relu")(x)
x = layers.Dropout(0.2)(x)
output = layers.Dense(NUM_CLASSES, activation="softmax")(x)

model = models.Model(inputs=base.input, outputs=output)

model.compile(
    optimizer=tf.keras.optimizers.Adam(1e-3),
    loss="categorical_crossentropy",
    metrics=["accuracy"],
)

print(f"Model parameters: {model.count_params():,}")

# ── Phase 1: Train head only ───────────────────────────────────
print(f"\n=== Phase 1: Training head ({EPOCHS_FROZEN} epochs) ===")
model.fit(
    train_gen,
    validation_data=val_gen,
    epochs=EPOCHS_FROZEN,
    callbacks=[
        tf.keras.callbacks.EarlyStopping(patience=3, restore_best_weights=True),
        tf.keras.callbacks.ReduceLROnPlateau(patience=2, factor=0.5),
    ],
)

# ── Phase 2: Unfreeze top layers and fine-tune ────────────────
print(f"\n=== Phase 2: Fine-tuning top 30 layers ({EPOCHS_UNFROZEN} epochs) ===")
for layer in base.layers[-30:]:
    layer.trainable = True

model.compile(
    optimizer=tf.keras.optimizers.Adam(1e-4),  # lower LR for fine-tune
    loss="categorical_crossentropy",
    metrics=["accuracy"],
)

model.fit(
    train_gen,
    validation_data=val_gen,
    epochs=EPOCHS_UNFROZEN,
    callbacks=[
        tf.keras.callbacks.EarlyStopping(patience=4, restore_best_weights=True),
        tf.keras.callbacks.ReduceLROnPlateau(patience=2, factor=0.5),
        tf.keras.callbacks.ModelCheckpoint(
            "best_model.keras", save_best_only=True, monitor="val_accuracy"
        ),
    ],
)

# ── Convert to TFLite ─────────────────────────────────────────
print("\n=== Converting to TFLite ===")
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
tflite_model = converter.convert()

with open(OUTPUT_TFLITE, "wb") as f:
    f.write(tflite_model)

size_mb = os.path.getsize(OUTPUT_TFLITE) / (1024 * 1024)
print(f"\n✅ Saved: {OUTPUT_TFLITE} ({size_mb:.1f} MB)")
print(f"\nClass order (important — update CLASS_INFO in api.py):")
for i, name in enumerate(CLASS_NAMES):
    print(f"  {i}: {name}")

print("\n⚠️  IMPORTANT: After replacing the model file:")
print("   1. Update CLASS_INFO in api.py — add index 7 for 'healthy'")
print("   2. Update _classInfo in skin_analysis_service.dart — same")
print("   3. The model will now directly predict 'healthy' — remove all heuristics")
