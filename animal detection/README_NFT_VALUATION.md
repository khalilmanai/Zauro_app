# 🐄 NFT Value Estimation for Livestock

## Overview

This enhanced system provides comprehensive NFT value estimation for cattle/livestock assets using advanced AI models and market analysis.

## Features

### 🎯 Core Capabilities
- **Multi-factor Valuation**: Considers age, sex, health, breed, and market trends
- **Rarity Analysis**: Calculates rarity scores based on unique attributes
- **NFT Metadata Generation**: Creates ERC-721 compliant metadata
- **Market Price Prediction**: Uses T5 transformer model for price estimation
- **Trading Fee Estimation**: Predicts transaction costs for NFT sales

### 📊 Valuation Components

#### 1. Market Value
- Base value adjusted for:
  - Age multipliers (prime age = higher value)
  - Sex premiums (typically males command higher prices)
  - Health penalties (diseases reduce value)
  - Breed modifiers (rare breeds = higher value)

#### 2. Rarity Score
Calculates rarity based on:
- **Breed rarity**: Uncommon breeds score higher
- **Age rarity**: Extremes (very young/old) are rarer
- **Health rarity**: Multiple diseases indicate rarity
- **Sex factors**: Breeding potential affects rarity

#### 3. NFT Value Formula
```
Total NFT Value = Market Value + (Rarity Premium × Rarity Score) + Utility Bonus
```

#### 4. Price Range
- **Floor Price**: 85% of estimated value
- **Estimated Price**: Calculated total value
- **Premium Price**: 125% of estimated value

## API Endpoints

### 1. `/predict` - Market Price Prediction
Predict cattle market price using AI model.

**Request:**
```json
{
  "image_path": "path/to/cattle/image.jpg",
  "animal_id": "ZAURO-001"  // optional
}
```

**Response:**
```json
{
  "animal_id": "ZAURO-001",
  "sex": "Male",
  "age": "3Y",
  "health": ["healthy"],
  "breed": "White Fulani",
  "predicted_market_price": "4500"
}
```

### 2. `/estimate-nft-value` - Comprehensive NFT Valuation
Get detailed NFT valuation with rarity analysis.

**Request:**
```json
{
  "image_path": "path/to/cattle/image.jpg",
  "animal_id": "ZAURO-001"  // optional
}
```

**Response:**
```json
{
  "valuation_summary": {
    "timestamp": "2024-01-15T10:30:00Z",
    "animal_id": "ZAURO-001",
    "estimated_value": 12500.50
  },
  "rarity_analysis": {
    "rarity_score": 2.35,
    "rarity_tier": "Rare",
    "factors": [
      "Non-standard age: 3Y",
      "Rare breed: White Fulani"
    ]
  },
  "value_metrics": {
    "market_value": 8500.00,
    "rarity_premium": 4700.00,
    "rarity_score": 2.35,
    "utility_bonus": 500,
    "total_nft_value": 13700.00,
    "price_range": {
      "floor": 11645.00,
      "estimate": 13700.00,
      "premium": 17125.00
    }
  },
  "nft_metadata": {
    "name": "Zauro Cattle #ZAURO-001",
    "description": "A verified livestock asset backed by blockchain technology",
    "attributes": [...]
  },
  "fee_estimation": {
    "marketplace_fee": 342.50,
    "gas_fee_estimate": 10.00,
    "total_fees": 352.50,
    "net_seller_receives": 13347.50
  },
  "recommendation": {
    "action": "Standard listing",
    "reason": "Good market value",
    "suggested_listing_price": 15070.00,
    "confidence": "medium"
  }
}
```

### 3. `/analyze` - Complete Analysis
Combines market prediction and NFT valuation in one endpoint.

**Request:**
```json
{
  "image_path": "path/to/cattle/image.jpg",
  "animal_id": "ZAURO-001"  // optional
}
```

**Response:**
```json
{
  "animal_analysis": {
    "animal_id": "ZAURO-001",
    "sex": "Male",
    "age": "3Y",
    "health": ["healthy"],
    "breed": "White Fulani"
  },
  "market_price": "4500",
  "nft_valuation": {
    // Full valuation report as above
  }
}
```

## Rarity Tiers

| Tier | Rarity Score Range | Description |
|------|-------------------|-------------|
| 🏆 **Legendary** | ≥ 3.0 | Extremely rare, high-value assets |
| 💎 **Epic** | 2.0 - 2.9 | Rare assets with premium pricing |
| ⭐ **Rare** | 1.5 - 1.9 | Uncommon attributes, above average value |
| 📦 **Uncommon** | 1.2 - 1.4 | Slightly unique characteristics |
| 🌾 **Common** | < 1.2 | Standard attributes |

## Usage Examples

### Python Script Usage

```python
from nft_value_estimator import estimate_nft_value

# Analyze a cattle
cattle_data = {
    "animal_id": "ZAURO-001",
    "sex": "Male",
    "age": "3Y",
    "health": ["healthy"],
    "breed": "White Fulani"
}

# Get comprehensive valuation
report = estimate_nft_value(cattle_data, image_path="cattle.jpg")

print(f"Estimated NFT Value: ${report['value_metrics']['total_nft_value']}")
print(f"Rarity Tier: {report['rarity_analysis']['rarity_tier']}")
print(f"Rarity Score: {report['rarity_analysis']['rarity_score']}")
```

### CLI Usage

```bash
# Start the Flask API
python api.py

# Test with curl
curl -X POST http://localhost:5000/estimate-nft-value \
  -H "Content-Type: application/json" \
  -d '{"image_path": "download (1).jpg", "animal_id": "TEST-001"}'
```

## Configuration

### Breed Rarity Scores
Edit `nft_value_estimator.py` to adjust breed rarity:
```python
BREED_RARITY = {
    "White Fulani": 1.2,      # Slightly rare
    "Muturu": 2.0,            # Very rare
    "Kuri": 1.8,              # Rare
    # ... add more breeds
}
```

### Base Market Value
Adjust the base market value in `NFTValueEstimator`:
```python
BASE_MARKET_VALUE = 8000  # Change based on market conditions
```

### Age Multipliers
Modify age-based value calculations:
```python
AGE_MULTIPLIERS = {
    "4Y": 1.0,   # Prime breeding age (baseline)
    "5Y": 1.1,   # Slightly above prime
    # ... adjust as needed
}
```

## NFT Metadata Standards

Generated metadata follows ERC-721 standard with:
- **name**: Asset identifier
- **description**: Generic description
- **image**: IPFS hash (production)
- **attributes**: Trait-based data
- **properties**: Additional metadata

## Advanced Features

### Market Trend Integration
The system supports dynamic market trend adjustments:
```python
market_trends = {
    "current_multiplier": 1.15,  # 15% premium
    "seasonality": 0.95,         # 5% seasonal discount
    "demand_factor": 1.2         # High demand
}
```

### Rarity Factors Breakdown
The system automatically explains rarity factors:
- Rare breed detection
- Non-standard age
- Multiple health conditions
- Breeding potential

### Smart Recommendations
Based on valuation, the system suggests:
- Listing price
- Confidence level
- Action to take (premium/standard/review)

## Integration with Blockchain

The NFT metadata can be:
1. **Minted** to Ethereum/IPFS
2. **Tracked** on Hedera blockchain
3. **Stored** on Arweave for permanent storage
4. **Verified** on marketplace platforms

## Requirements

```txt
flask
transformers
torch
requests
PIL
```

## Future Enhancements

- [ ] Historical price trend analysis
- [ ] Genetic verification integration
- [ ] Breeding value calculation
- [ ] Insurance premium estimation
- [ ] Real-time market data feeds
- [ ] Multi-marketplace comparison
- [ ] Dynamic liquidity scoring

## Notes

- All prices in base currency (adjust per market)
- Health status updates dynamically affect value
- Rarity scores compound with multiple rare traits
- Marketplace fees estimated at 2.5% industry standard

