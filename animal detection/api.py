from flask import Flask, request, jsonify
from flask_cors import CORS
from transformers import T5Tokenizer, T5ForConditionalGeneration
import requests
from PIL import Image
import base64
import io
import torch
import os
import tempfile
import urllib.parse
from nft_value_estimator import NFTValueEstimator

app = Flask(__name__)
CORS(app)
# === Configurations ===
ROBOFLOW_API_KEY = "YPeeLeEnmBBMD2yGzdZW"
ROBOFLOW_MODEL_VERSION = "1"

# Roboflow Project Configurations
ROBOFLOW_DISEASE_PROJECT = "cattle-diseases-y4k4x"
ROBOFLOW_SEX_PROJECT = "bull-model-olp2r"
ROBOFLOW_AGE_PROJECT = "cattle-age"
ROBOFLOW_BREED_PROJECT = "cattle-breed"  # Future breed detection


# ✅ Load once when the app starts
tokenizer = T5Tokenizer.from_pretrained("amirboudidah/t5-cattle-price")
model = T5ForConditionalGeneration.from_pretrained("amirboudidah/t5-cattle-price")
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)

# Initialize NFT Value Estimator
nft_estimator = NFTValueEstimator()


def download_image_if_url(image_path):
    """
    Download image from URL if path is a URL, otherwise return local path.
    Returns tuple: (local_path, should_cleanup)
    """
    # Check if it's a URL
    parsed = urllib.parse.urlparse(image_path)
    if parsed.scheme in ('http', 'https'):
        # It's a URL, download it
        try:
            response = requests.get(image_path, timeout=30)
            response.raise_for_status()
            
            # Create temporary file
            temp_file = tempfile.NamedTemporaryFile(delete=False, suffix='.jpg')
            temp_file.write(response.content)
            temp_file.close()
            
            return temp_file.name, True
        except Exception as e:
            print(f"❌ Error downloading image from URL {image_path}: {e}")
            raise Exception(f"Failed to download image: {str(e)}")
    else:
        # It's a local path
        return image_path, False


def format_input(data):
    return f"sex: {data['sex']}, age: {data['age']}, health: {';'.join(data['health'])}"

def predict_price(data):
    input_text = format_input(data)
    inputs = tokenizer(input_text, return_tensors="pt", padding="max_length", truncation=True, max_length=128)
    inputs = {k: v.to(device) for k, v in inputs.items()}
    outputs = model.generate(input_ids=inputs["input_ids"], attention_mask=inputs["attention_mask"])
    return tokenizer.decode(outputs[0], skip_special_tokens=True)

# === Utility: Convert image to base64 ===
def image_to_base64(image_path):
    with open(image_path, "rb") as img_file:
        return base64.b64encode(img_file.read()).decode('utf-8')

# === Step 1: Age & Sex Detection ===
def detect_sex_roboflow(image_path):
    url = f"https://detect.roboflow.com/{ROBOFLOW_SEX_PROJECT}/{ROBOFLOW_MODEL_VERSION}?api_key={ROBOFLOW_API_KEY}"
    
    with open(image_path, "rb") as image_file:
        response = requests.post(url, files={"file": image_file})

    try:
        result = response.json()
        print("🧪 Roboflow Raw Result:", result)

        predictions = result.get("predictions", [])
        if not predictions:
            return "Female"  # Assume female if no Scrotum detected

        classes = [pred["class"] for pred in predictions]
        return "Male" if "Scrotum" in classes else "Female"

    except Exception as e:
        print("❌ Error parsing response:", e)
        return "Error during detection"

# === Step 2: Cattle Disease Detection via Roboflow ===
def detect_disease_roboflow(image_path):
    url = f"https://detect.roboflow.com/{ROBOFLOW_DISEASE_PROJECT}/{ROBOFLOW_MODEL_VERSION}?api_key={ROBOFLOW_API_KEY}"
    with open(image_path, "rb") as image_file:
        response = requests.post(url, files={"file": image_file})

    try:
        result = response.json()
        print("🧪 Roboflow Raw Result:", result)

        predicted_classes = result.get("predicted_classes")
        if not predicted_classes:
            return "No disease detected"

        return list(set(predicted_classes))
    except Exception as e:
        print("❌ Error parsing response:", e)
        return "Error during detection"

# === Breed Detection (Fallback: Physical characteristics analysis) ===
def detect_breed_from_characteristics(sex, age, color_pattern=None):
    """
    Fallback breed detection based on characteristics and market data
    In production, this should use a dedicated breed detection model
    """
    # Common breeds in livestock
    common_breeds = [
        "White Fulani",
        "Red Fulani", 
        "Sokoto Gudali",
        "Muturu",
        "Yankasa",
        "Bunaji",
        "Holstein Friesian",
        "Angus",
        "Hereford"
    ]
    
    # Simple heuristic: Return most common breed
    # In production, integrate with breed detection API/model
    return common_breeds[0]  # White Fulani as default

# === MAIN FUNCTION ===
def analyze_cattle(image_path, animal_id=None, vet_info=None):
    """
    Comprehensive cattle analysis from image
    
    Args:
        image_path: Path to cattle image or URL
        animal_id: Optional animal identifier
        vet_info: Optional dictionary with vet certification data
            Expected keys: age, breed, sex, health, vaccinations, medical_history
    
    Returns:
        Dictionary with comprehensive analysis including:
        - demographic data (age, sex, breed)
        - health status
        - market value prediction
        - AI confidence scores
    """
    print("🔍 Analyzing image:", image_path)
    
    # Download image if it's a URL
    local_image_path = None
    should_cleanup = False
    try:
        local_image_path, should_cleanup = download_image_if_url(image_path)
        print(f"📥 Image path (local): {local_image_path}")
        
        # Step 1: Age & Sex Detection
        sex = detect_sex_roboflow(local_image_path)
        age = detect_age_roboflow(local_image_path)
        print(f"📌 Age Detected: {age}")
        print(f"📌 Sex Detected: {sex}")

        # Step 2: Disease Detection
        diseases = detect_disease_roboflow(local_image_path)
        print(f"💉 Detected Diseases: {diseases}")
        
        # Normalize diseases to list format
        if isinstance(diseases, str):
            diseases = [diseases]
        elif not isinstance(diseases, list):
            diseases = []

        # Step 3: Breed Detection (with fallback)
        breed = detect_breed_from_characteristics(sex, age)
        print(f"🐂 Breed Detected: {breed}")
        
        # Step 4: Merge with vet information if provided
        if vet_info:
            print("📋 Merging with vet certification data...")
            # Override detected values with vet certification if more reliable
            if vet_info.get("age"):
                age = vet_info["age"]
            if vet_info.get("breed"):
                breed = vet_info["breed"]
            if vet_info.get("sex"):
                sex = vet_info["sex"]
            if vet_info.get("health"):
                # Merge health information
                vet_health = vet_info["health"] if isinstance(vet_info["health"], list) else [vet_info["health"]]
                diseases = list(set(diseases + vet_health))
        
        # Determine health status
        if not diseases or "No disease detected" in diseases or diseases == []:
            health_status = "HEALTHY"
            health_details = []
        else:
            health_status = "CONCERN"
            health_details = diseases

        return {
            "animal_id": animal_id or f"ZAURO-{hash(image_path) % 10000}",
            "detected_attributes": {
                "sex": sex,
                "age": age,
                "breed": breed,
                "health_status": health_status,
                "health_details": health_details
            },
            "ai_confidence": {
                "sex_confidence": 0.85,  # Mock confidence score
                "age_confidence": 0.80,
                "health_confidence": 0.90 if diseases else 0.75,
                "breed_confidence": 0.60  # Lower confidence as it's a fallback
            },
            "vet_integration": vet_info is not None,
            "notes": "Analysis includes AI detection and optional vet certification data"
        }
    finally:
        # Clean up temporary file if we downloaded it
        if should_cleanup and local_image_path and os.path.exists(local_image_path):
            try:
                os.unlink(local_image_path)
                print(f"🧹 Cleaned up temporary file: {local_image_path}")
            except Exception as e:
                print(f"⚠️ Warning: Could not delete temporary file {local_image_path}: {e}")

def detect_age_roboflow(image_path):
    url = f"https://detect.roboflow.com/{ROBOFLOW_AGE_PROJECT}/{ROBOFLOW_MODEL_VERSION}?api_key={ROBOFLOW_API_KEY}&confidence=0.1"
    
    with open(image_path, "rb") as image_file:
        response = requests.post(url, files={"file": image_file})

    try:
        result = response.json()
        print("🧪 Roboflow Raw Result:", result)

        predictions = result.get("predictions", [])
        if not predictions:
            return "Unknown"

        # Get the class of the first prediction (highest ranked)
        first_class = predictions[0].get("class", "Unknown")
        return first_class

    except Exception as e:
        print("❌ Error parsing response:", e)
        return "Error during detection"


# # === Example Usage ===
# if __name__ == "__main__":
#     image_path = "download (1).jpg"  # Replace with your image path
#     results = analyze_cattle(image_path)
#     print(results)



@app.route("/predict", methods=["POST"])
def predict():
    """
    Predict cattle market value using T5 model
    Supports optional vet certification data
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
            
        image_path = data.get("image_path")
        if not image_path:
            return jsonify({"error": "image_path is required"}), 400
            
        animal_id = data.get("animal_id")
        vet_info = data.get("vet_info")
        
        # Analyze cattle from image
        results = analyze_cattle(image_path, animal_id, vet_info)
        
        # Extract attributes for price prediction
        attributes = results["detected_attributes"]
        sex = attributes["sex"]
        age = attributes["age"]
        health = attributes["health_details"]
        
        # Predict price using T5 model
        model_input = {
            "sex": sex,
            "age": age,
            "health": health if health else ["Healthy"]
        }
        predicted_price = predict_price(model_input)

        return jsonify({
            "animal_id": results["animal_id"],
            "detected_attributes": attributes,
            "predicted_market_price": predicted_price,
            "ai_confidence": results["ai_confidence"],
            "vet_integration": results["vet_integration"]
        })
    except Exception as e:
        import traceback
        error_trace = traceback.format_exc()
        print(f"❌ Error in /predict endpoint: {str(e)}")
        print(f"📋 Traceback: {error_trace}")
        return jsonify({"error": str(e)}), 500


@app.route("/estimate-nft-value", methods=["POST"])
def estimate_nft_value():
    """
    Comprehensive NFT value estimation with rarity analysis
    Supports optional vet certification data
    """
    try:
        data = request.get_json()
        image_path = data.get("image_path")
        animal_id = data.get("animal_id")
        vet_info = data.get("vet_info")
        
        # Analyze cattle from image
        analysis_result = analyze_cattle(image_path, animal_id, vet_info)
        cattle_data = analysis_result["detected_attributes"]
        
        # Generate comprehensive valuation report
        valuation_report = nft_estimator.get_valuation_report(cattle_data, image_path)

        return jsonify({
            **valuation_report,
            "ai_confidence": analysis_result["ai_confidence"],
            "vet_integration": analysis_result["vet_integration"]
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/analyze", methods=["POST"])
def analyze():
    """
    Combined analysis endpoint - returns comprehensive analysis including AI detection,
    price prediction, and NFT valuation. Supports optional vet certification data.
    """
    try:
        data = request.get_json()
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
            
        image_path = data.get("image_path")
        if not image_path:
            return jsonify({"error": "image_path is required"}), 400
            
        animal_id = data.get("animal_id")
        vet_info = data.get("vet_info")
        
        print(f"📥 Received analysis request for image: {image_path}")
        
        # Analyze cattle from image
        analysis_result = analyze_cattle(image_path, animal_id, vet_info)
        cattle_data = analysis_result["detected_attributes"]
        
        # Predict market price
        model_input = {
            "sex": cattle_data["sex"],
            "age": cattle_data["age"],
            "health": cattle_data["health_details"] if cattle_data["health_details"] else ["Healthy"]
        }
        market_price = predict_price(model_input)
        
        # Generate NFT valuation (use original image_path, not local path)
        valuation_report = nft_estimator.get_valuation_report(cattle_data, image_path)
        
        # Combine results
        return jsonify({
            "animal_id": analysis_result["animal_id"],
            "detected_attributes": cattle_data,  # Changed from "animal_analysis" to "detected_attributes"
            "ai_confidence": analysis_result["ai_confidence"],
            "vet_integration": analysis_result["vet_integration"],
            "market_price": market_price,
            "nft_valuation": valuation_report,
            "notes": analysis_result["notes"]
        })
    except Exception as e:
        import traceback
        error_trace = traceback.format_exc()
        print(f"❌ Error in /analyze endpoint: {str(e)}")
        print(f"📋 Traceback: {error_trace}")
        return jsonify({"error": str(e), "traceback": error_trace}), 500


@app.route("/health", methods=["GET"])
def health():
    """
    Health check endpoint for Docker
    """
    try:
        # Check if model is loaded
        if model is None or tokenizer is None:
            return jsonify({"status": "unhealthy", "reason": "Model not loaded"}), 503
        
        return jsonify({
            "status": "healthy",
            "service": "animal-detection",
            "model_device": str(device)
        }), 200
    except Exception as e:
        return jsonify({"status": "unhealthy", "error": str(e)}), 503


@app.route("/", methods=["GET"])
def root():
    """
    Root endpoint with API information
    """
    return jsonify({
        "service": "Animal Detection & NFT Valuation API",
        "version": "1.0.0",
        "endpoints": {
            "/predict": "POST - Predict cattle market value",
            "/estimate-nft-value": "POST - Comprehensive NFT valuation",
            "/analyze": "POST - Complete analysis",
            "/health": "GET - Health check"
        }
    }), 200


if __name__ == "__main__":
    print("🚀 Starting Animal Detection API...")
    print(f"📱 Model device: {device}")
    print(f"🤖 NFT Estimator initialized")
    app.run(host="0.0.0.0", port=5000)