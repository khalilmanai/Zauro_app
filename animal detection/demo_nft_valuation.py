"""
Demo script to showcase NFT value estimation for livestock
"""

from nft_value_estimator import NFTValueEstimator
import json
from pprint import pprint

def demo_basic_valuation():
    """Basic NFT value estimation example"""
    print("=" * 80)
    print("🐄 BASIC NFT VALUATION EXAMPLE")
    print("=" * 80)
    
    cattle_data = {
        "animal_id": "ZAURO-001",
        "sex": "Male",
        "age": "3Y",
        "health": ["healthy"],
        "breed": "White Fulani"
    }
    
    estimator = NFTValueEstimator()
    report = estimator.get_valuation_report(cattle_data)
    
    print("\n📊 VALUATION SUMMARY:")
    print(f"   Animal ID: {report['valuation_summary']['animal_id']}")
    print(f"   Estimated Value: ${report['valuation_summary']['estimated_value']:,.2f}")
    
    print("\n⭐ RARITY ANALYSIS:")
    print(f"   Rarity Score: {report['rarity_analysis']['rarity_score']:.2f}")
    print(f"   Rarity Tier: {report['rarity_analysis']['rarity_tier']}")
    print(f"   Factors: {', '.join(report['rarity_analysis']['factors'])}")
    
    print("\n💰 VALUE METRICS:")
    vm = report['value_metrics']
    print(f"   Market Value: ${vm['market_value']:,.2f}")
    print(f"   Rarity Premium: ${vm['rarity_premium']:,.2f}")
    print(f"   Utility Bonus: ${vm['utility_bonus']:,.2f}")
    print(f"   Total NFT Value: ${vm['total_nft_value']:,.2f}")
    print(f"   Price Range: ${vm['price_range']['floor']:,.2f} - ${vm['price_range']['premium']:,.2f}")
    
    print("\n📈 RECOMMENDATION:")
    rec = report['recommendation']
    print(f"   Action: {rec['action']}")
    print(f"   Suggested Listing Price: ${rec['suggested_listing_price']:,.2f}")
    print(f"   Confidence: {rec['confidence']}")
    
    print("\n💸 FEE ESTIMATION:")
    fees = report['fee_estimation']
    print(f"   Marketplace Fee (2.5%): ${fees['marketplace_fee']:,.2f}")
    print(f"   Gas Fee: ${fees['gas_fee_estimate']:,.2f}")
    print(f"   Total Fees: ${fees['total_fees']:,.2f}")
    print(f"   Net Seller Receives: ${fees['net_seller_receives']:,.2f}")


def demo_unhealthy_cattle():
    """Example with unhealthy cattle (lower value)"""
    print("\n" + "=" * 80)
    print("🐄 UNHEALTHY CATTLE VALUATION EXAMPLE")
    print("=" * 80)
    
    cattle_data = {
        "animal_id": "ZAURO-002",
        "sex": "Female",
        "age": "7Y",
        "health": ["Dermatitis", "Respiratory"],
        "breed": "Bunaji"
    }
    
    estimator = NFTValueEstimator()
    report = estimator.get_valuation_report(cattle_data)
    
    print("\n📊 VALUATION SUMMARY:")
    print(f"   Animal ID: {report['valuation_summary']['animal_id']}")
    print(f"   Estimated Value: ${report['valuation_summary']['estimated_value']:,.2f}")
    
    print("\n⭐ RARITY ANALYSIS:")
    print(f"   Rarity Score: {report['rarity_analysis']['rarity_score']:.2f}")
    print(f"   Rarity Tier: {report['rarity_analysis']['rarity_tier']}")
    print(f"   Factors: {', '.join(report['rarity_analysis']['factors'])}")


def demo_rare_breed():
    """Example with rare breed (higher value)"""
    print("\n" + "=" * 80)
    print("🐄 RARE BREED VALUATION EXAMPLE")
    print("=" * 80)
    
    cattle_data = {
        "animal_id": "ZAURO-003",
        "sex": "Male",
        "age": "4Y",
        "health": ["healthy"],
        "breed": "Muturu"
    }
    
    estimator = NFTValueEstimator()
    report = estimator.get_valuation_report(cattle_data)
    
    print("\n📊 VALUATION SUMMARY:")
    print(f"   Animal ID: {report['valuation_summary']['animal_id']}")
    print(f"   Estimated Value: ${report['valuation_summary']['estimated_value']:,.2f}")
    
    print("\n⭐ RARITY ANALYSIS:")
    print(f"   Rarity Score: {report['rarity_analysis']['rarity_score']:.2f}")
    print(f"   Rarity Tier: {report['rarity_analysis']['rarity_tier']}")
    print(f"   Factors: {', '.join(report['rarity_analysis']['factors'])}")
    
    print("\n💰 VALUE METRICS:")
    vm = report['value_metrics']
    print(f"   Market Value: ${vm['market_value']:,.2f}")
    print(f"   Rarity Premium: ${vm['rarity_premium']:,.2f}")
    print(f"   Total NFT Value: ${vm['total_nft_value']:,.2f}")


def demo_nft_metadata():
    """Show NFT metadata generation"""
    print("\n" + "=" * 80)
    print("🎨 NFT METADATA GENERATION")
    print("=" * 80)
    
    cattle_data = {
        "animal_id": "ZAURO-001",
        "sex": "Male",
        "age": "3Y",
        "health": ["healthy"],
        "breed": "White Fulani"
    }
    
    estimator = NFTValueEstimator()
    metadata = estimator.generate_nft_metadata(cattle_data, "cattle.jpg")
    
    print("\n📝 METADATA:")
    print(json.dumps(metadata, indent=2))


def compare_valuation_scenarios():
    """Compare different valuation scenarios"""
    print("\n" + "=" * 80)
    print("📊 VALUATION SCENARIOS COMPARISON")
    print("=" * 80)
    
    scenarios = [
        {"id": "ZAURO-001", "sex": "Male", "age": "3Y", "health": ["healthy"], "breed": "White Fulani"},
        {"id": "ZAURO-002", "sex": "Male", "age": "4Y", "health": ["healthy"], "breed": "Muturu"},
        {"id": "ZAURO-003", "sex": "Female", "age": "7Y", "health": ["Dermatitis"], "breed": "Bunaji"},
        {"id": "ZAURO-004", "sex": "Male", "age": "2Y", "health": ["healthy"], "breed": "Kuri"},
        {"id": "ZAURO-005", "sex": "Female", "age": "12Y", "health": ["lumpy", "Skin"], "breed": "White Fulani"},
    ]
    
    estimator = NFTValueEstimator()
    
    print("\n{:<15} {:<10} {:<8} {:<15} {:<12} {:<12}".format(
        "Animal ID", "Age", "Sex", "Breed", "Rarity", "NFT Value"
    ))
    print("-" * 80)
    
    for scenario in scenarios:
        report = estimator.get_valuation_report(scenario)
        
        print("{:<15} {:<10} {:<8} {:<15} {:<12} ${:<11,.2f}".format(
            report['valuation_summary']['animal_id'],
            scenario['age'],
            scenario['sex'],
            scenario['breed'][:13],
            report['rarity_analysis']['rarity_tier'],
            report['value_metrics']['total_nft_value']
        ))


def main():
    """Run all demos"""
    print("\n" + "🎯" * 40)
    print("ZAURO NFT VALUATION DEMONSTRATION")
    print("🎯" * 40 + "\n")
    
    # Run demonstrations
    demo_basic_valuation()
    demo_unhealthy_cattle()
    demo_rare_breed()
    demo_nft_metadata()
    compare_valuation_scenarios()
    
    print("\n" + "=" * 80)
    print("✅ DEMO COMPLETE")
    print("=" * 80)
    print("\nNext steps:")
    print("1. Run 'python api.py' to start the Flask API")
    print("2. Use the API endpoints for production integration")
    print("3. Customize breed rarity scores and market values as needed")


if __name__ == "__main__":
    main()

