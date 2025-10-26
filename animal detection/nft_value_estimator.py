"""
Enhanced NFT Value Estimation System for Cattle
Considers rarity, market trends, health, and breed for comprehensive valuation
"""

import json
import random
from datetime import datetime
from typing import Dict, List, Any
import statistics


class NFTValueEstimator:
    """
    Comprehensive NFT value estimation for livestock assets
    """
    
    # Breed rarity scores (higher = more rare)
    BREED_RARITY = {
        "White Fulani": 1.2,
        "Red Fulani": 1.5,
        "Sokoto Gudali": 1.3,
        "Kuri": 1.8,
        "Muturu": 2.0,
        "Yankasa": 1.4,
        "Bunaji": 1.1,
        "Gudali": 1.0,
    }
    
    # Age multiplier (younger cattle in prime age range are more valuable)
    AGE_MULTIPLIERS = {
        "1Y": 0.5, "2Y": 0.7, "3Y": 0.85,
        "4Y": 1.0, "5Y": 1.1, "6Y": 1.0,
        "7Y": 0.95, "8Y": 0.85, "9Y": 0.75,
        "10Y": 0.65, "11Y": 0.55, "12Y": 0.45,
        "13Y": 0.35, "14Y": 0.25, "15Y": 0.15
    }
    
    # Health impact on value
    HEALTH_PENALTIES = {
        "healthy": 0.0,
        "Dermatitis": 0.15,
        "Ecthym": 0.12,
        "Respiratory": 0.20,
        "lumpy": 0.25,
        "Skin": 0.18,
    }
    
    # Sex premium/discount
    SEX_MULTIPLIER = {
        "Male": 1.15,  # Males are typically more valuable for breeding
        "Female": 1.05,  # Females valuable for milk production
    }
    
    # Base market value (in local currency)
    BASE_MARKET_VALUE = 8000
    
    def __init__(self):
        self.market_trends = self._load_market_trends()
        
    def _load_market_trends(self) -> Dict[str, float]:
        """Load historical market trends if available"""
        return {
            "current_multiplier": 1.0,  # Can be adjusted based on market conditions
            "seasonality": 1.0,
            "demand_factor": 1.0
        }
    
    def calculate_rarity_score(self, attributes: Dict[str, Any]) -> float:
        """
        Calculate rarity score based on animal attributes
        
        Factors:
        - Breed rarity
        - Age rarity (prime age = common, extremes = rare)
        - Health rarity (healthy = common, unique diseases = rare)
        - Sex ratio (based on breeding potential)
        """
        score = 1.0
        
        # Breed rarity
        breed = attributes.get("breed", "Unknown")
        score *= self.BREED_RARITY.get(breed, 1.0)
        
        # Age rarity (extremes are rarer)
        age = attributes.get("age", "Unknown")
        age_num = int(age.replace("Y", "")) if "Y" in age else 7
        if 3 <= age_num <= 6:  # Prime breeding age
            score *= 0.9  # Less rare
        else:
            score *= 1.5  # More rare
        
        # Health rarity (multiple/unique diseases = rarer)
        health = attributes.get("health", [])
        if "healthy" not in health:
            disease_count = len(health)
            score *= 1.0 + (disease_count * 0.3)
        
        # Sex-based rarity
        sex = attributes.get("sex", "Unknown")
        score *= self.SEX_MULTIPLIER.get(sex, 1.0)
        
        return min(score, 5.0)  # Cap at 5x
    
    def estimate_market_value(self, attributes: Dict[str, Any]) -> float:
        """
        Calculate market value based on multiple factors
        """
        # Get base price from model prediction (in real scenario)
        # For now, calculate from rules
        
        age = attributes.get("age", "5Y")
        sex = attributes.get("sex", "Unknown")
        health = attributes.get("health", ["healthy"])
        
        # Age multiplier
        age_mult = self.AGE_MULTIPLIERS.get(age, 1.0)
        
        # Sex multiplier
        sex_mult = self.SEX_MULTIPLIER.get(sex, 1.0)
        
        # Health penalty
        health_mult = 1.0
        for disease in health:
            health_mult -= self.HEALTH_PENALTIES.get(disease, 0.0)
        health_mult = max(health_mult, 0.1)  # At least 10% of value
        
        # Breed modifier
        breed = attributes.get("breed", "Unknown")
        breed_mult = self.BREED_RARITY.get(breed, 1.0)
        
        # Calculate final value
        base_value = self.BASE_MARKET_VALUE
        value = base_value * age_mult * sex_mult * health_mult * breed_mult
        
        # Apply market trends
        value *= self.market_trends["current_multiplier"]
        
        return max(value, 500)  # Minimum floor price
    
    def calculate_nft_value(self, attributes: Dict[str, Any], rarity_score: float) -> Dict[str, Any]:
        """
        Calculate NFT value considering rarity premiums
        
        NFT value formula:
        base_market_value + (rarity_premium * rarity_score * market_trend)
        """
        
        market_value = self.estimate_market_value(attributes)
        
        # Rarity premium (higher rarity = higher premium)
        rarity_premium_base = 2000
        rarity_premium = rarity_premium_base * rarity_score
        
        # Total NFT value
        nft_value = market_value + rarity_premium
        
        # Add utility value for NFT features
        utility_bonus = 500  # For blockchain tracking, ownership verification, etc.
        
        total_value = nft_value + utility_bonus
        
        return {
            "market_value": round(market_value, 2),
            "rarity_premium": round(rarity_premium, 2),
            "rarity_score": round(rarity_score, 3),
            "utility_bonus": utility_bonus,
            "total_nft_value": round(total_value, 2),
            "price_range": {
                "floor": round(total_value * 0.85, 2),
                "estimate": round(total_value, 2),
                "premium": round(total_value * 1.25, 2)
            }
        }
    
    def generate_nft_metadata(self, cattle_data: Dict[str, Any], image_path: str = None) -> Dict[str, Any]:
        """
        Generate comprehensive NFT metadata following ERC-721 standard
        """
        attributes = cattle_data
        
        # Calculate metrics
        rarity_score = self.calculate_rarity_score(attributes)
        value_metrics = self.calculate_nft_value(attributes, rarity_score)
        
        # Build NFT metadata
        nft_metadata = {
            "name": f"Zauro Cattle #{cattle_data.get('animal_id', 'UNKNOWN')}",
            "description": "A verified livestock asset backed by blockchain technology",
            "image": image_path or "ipfs://...",  # IPFS hash in production
            "external_url": "https://zauro.app",
            "attributes": [
                {
                    "trait_type": "Breed",
                    "value": attributes.get("breed", "Unknown")
                },
                {
                    "trait_type": "Age",
                    "value": attributes.get("age", "Unknown")
                },
                {
                    "trait_type": "Sex",
                    "value": attributes.get("sex", "Unknown")
                },
                {
                    "trait_type": "Health Status",
                    "value": ", ".join(attributes.get("health", [])) or "Healthy"
                },
                {
                    "trait_type": "Rarity Score",
                    "value": round(rarity_score, 2),
                    "display_type": "number"
                },
                {
                    "trait_type": "Est. Market Value",
                    "value": value_metrics["market_value"],
                    "display_type": "number"
                },
                {
                    "trait_type": "NFT Value",
                    "value": value_metrics["total_nft_value"],
                    "display_type": "number"
                }
            ],
            "properties": {
                "animal_id": cattle_data.get("animal_id", ""),
                "timestamp": datetime.utcnow().isoformat(),
                "verified": True,
                "scientific_name": "Bos taurus",
                "value_metrics": value_metrics
            }
        }
        
        return nft_metadata
    
    def estimate_trading_fee(self, nft_value: float) -> Dict[str, float]:
        """
        Estimate trading fees and costs for NFT transactions
        
        Returns:
        - Marketplace fee: 2.5% (typical NFT marketplace fee)
        - Gas fee: Variable based on network
        - Total cost to seller
        """
        marketplace_fee_percentage = 0.025  # 2.5%
        gas_fee_estimate = 10.0  # Estimated in USD (varies by network)
        
        marketplace_fee = nft_value * marketplace_fee_percentage
        
        return {
            "marketplace_fee": round(marketplace_fee, 2),
            "gas_fee_estimate": gas_fee_estimate,
            "total_fees": round(marketplace_fee + gas_fee_estimate, 2),
            "net_seller_receives": round(nft_value - marketplace_fee - gas_fee_estimate, 2)
        }
    
    def get_valuation_report(self, cattle_data: Dict[str, Any], image_path: str = None) -> Dict[str, Any]:
        """
        Generate comprehensive valuation report for NFT
        """
        rarity_score = self.calculate_rarity_score(cattle_data)
        value_metrics = self.calculate_nft_value(cattle_data, rarity_score)
        nft_metadata = self.generate_nft_metadata(cattle_data, image_path)
        fee_estimate = self.estimate_trading_fee(value_metrics["total_nft_value"])
        
        return {
            "valuation_summary": {
                "timestamp": datetime.utcnow().isoformat(),
                "animal_id": cattle_data.get("animal_id", "Unknown"),
                "estimated_value": value_metrics["total_nft_value"]
            },
            "rarity_analysis": {
                "rarity_score": rarity_score,
                "rarity_tier": self._get_rarity_tier(rarity_score),
                "factors": self._get_rarity_breakdown(cattle_data)
            },
            "value_metrics": value_metrics,
            "nft_metadata": nft_metadata,
            "fee_estimation": fee_estimate,
            "recommendation": self._get_valuation_recommendation(value_metrics["total_nft_value"], rarity_score)
        }
    
    def _get_rarity_tier(self, score: float) -> str:
        """Classify rarity tier"""
        if score >= 3.0:
            return "Legendary"
        elif score >= 2.0:
            return "Epic"
        elif score >= 1.5:
            return "Rare"
        elif score >= 1.2:
            return "Uncommon"
        else:
            return "Common"
    
    def _get_rarity_breakdown(self, attributes: Dict[str, Any]) -> List[str]:
        """Explain rarity factors"""
        factors = []
        
        breed = attributes.get("breed", "")
        if self.BREED_RARITY.get(breed, 1.0) > 1.3:
            factors.append(f"Rare breed: {breed}")
        
        age = attributes.get("age", "")
        age_num = int(age.replace("Y", "")) if "Y" in age else 7
        if age_num < 3 or age_num > 8:
            factors.append(f"Non-standard age: {age}")
        
        health = attributes.get("health", [])
        if "healthy" not in health and len(health) > 1:
            factors.append(f"Multiple health conditions: {len(health)} issues")
        
        return factors
    
    def _get_valuation_recommendation(self, value: float, rarity: float) -> Dict[str, Any]:
        """Generate recommendation based on value and rarity"""
        if value >= 15000 or rarity >= 3.0:
            return {
                "action": "Premium listing recommended",
                "reason": "High-value, rare asset",
                "suggested_listing_price": value * 1.3,
                "confidence": "high"
            }
        elif value >= 10000:
            return {
                "action": "Standard listing",
                "reason": "Good market value",
                "suggested_listing_price": value * 1.1,
                "confidence": "medium"
            }
        else:
            return {
                "action": "Consider valuation review",
                "reason": "Lower market value - verify data",
                "suggested_listing_price": value * 0.95,
                "confidence": "low"
            }


# Convenience function for easy integration
def estimate_nft_value(cattle_data: Dict[str, Any], image_path: str = None) -> Dict[str, Any]:
    """
    Main function to estimate NFT value for cattle
    
    Args:
        cattle_data: Dictionary with keys: sex, age, health, breed, animal_id
        image_path: Path to cattle image (optional)
    
    Returns:
        Comprehensive valuation report
    """
    estimator = NFTValueEstimator()
    return estimator.get_valuation_report(cattle_data, image_path)


if __name__ == "__main__":
    # Example usage
    sample_cattle = {
        "animal_id": "ZAURO-001",
        "sex": "Male",
        "age": "3Y",
        "health": ["healthy"],
        "breed": "White Fulani"
    }
    
    report = estimate_nft_value(sample_cattle)
    print(json.dumps(report, indent=2))

