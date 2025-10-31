import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import axios, { AxiosInstance } from 'axios';

export interface DetectedAttributes {
  sex: string;
  age: string;
  breed: string;
  health_status: string;
  health_details: string[];
}

export interface AIConfidence {
  sex_confidence: number;
  age_confidence: number;
  health_confidence: number;
  breed_confidence: number;
}

export interface AnimalAnalysisResult {
  animal_id: string;
  detected_attributes: DetectedAttributes;
  ai_confidence: AIConfidence;
  vet_integration: boolean;
  notes: string;
  market_price?: string;
  nft_valuation?: any;
}

export interface VetInfo {
  age?: string | number;
  breed?: string;
  sex?: string;
  health?: string | string[];
  vaccinations?: string[];
  medical_history?: string[];
}

@Injectable()
export class AIAnalysisService {
  private readonly client: AxiosInstance;
  private readonly baseUrl: string;

  constructor(private configService: ConfigService) {
    // Get animal detection service URL from config or default
    this.baseUrl =
      this.configService.get<string>('ANIMAL_DETECTION_URL') ||
      'http://animal-detection:5000';
    
    this.client = axios.create({
      baseURL: this.baseUrl,
      timeout: 60000, // 60 seconds for ML inference
      headers: {
        'Content-Type': 'application/json',
      },
    });
  }

  /**
   * Analyze animal from image with optional vet certification data
   */
  async analyzeAnimal(
    imagePath: string,
    animalId?: string,
    vetInfo?: VetInfo,
  ): Promise<AnimalAnalysisResult> {
    try {
      const response = await this.client.post<AnimalAnalysisResult>('/analyze', {
        image_path: imagePath,
        animal_id: animalId,
        vet_info: vetInfo,
      });

      return response.data;
    } catch (error) {
      console.error('AI Analysis Service Error:', error.message);
      throw new Error(`Failed to analyze animal: ${error.message}`);
    }
  }

  /**
   * Predict market value of animal
   */
  async predictMarketValue(
    imagePath: string,
    animalId?: string,
    vetInfo?: VetInfo,
  ) {
    try {
      const response = await this.client.post('/predict', {
        image_path: imagePath,
        animal_id: animalId,
        vet_info: vetInfo,
      });

      return response.data;
    } catch (error) {
      console.error('Price Prediction Error:', error.message);
      throw new Error(`Failed to predict market value: ${error.message}`);
    }
  }

  /**
   * Estimate NFT value with comprehensive valuation
   */
  async estimateNFTValue(
    imagePath: string,
    animalId?: string,
    vetInfo?: VetInfo,
  ) {
    try {
      const response = await this.client.post('/estimate-nft-value', {
        image_path: imagePath,
        animal_id: animalId,
        vet_info: vetInfo,
      });

      return response.data;
    } catch (error) {
      console.error('NFT Valuation Error:', error.message);
      throw new Error(`Failed to estimate NFT value: ${error.message}`);
    }
  }

  /**
   * Health check for animal detection service
   */
  async healthCheck(): Promise<boolean> {
    try {
      const response = await this.client.get('/health');
      return response.data.status === 'healthy';
    } catch (error) {
      console.error('AI Analysis Service not available');
      return false;
    }
  }

  /**
   * Map detected attributes to backend format
   */
  mapAttributesToBackend(detectedAttributes: DetectedAttributes) {
    return {
      breed: detectedAttributes.breed,
      age: this.parseAge(detectedAttributes.age),
      gender: this.mapGender(detectedAttributes.sex),
      description: this.generateDescription(detectedAttributes),
      // The backend will use aiPredictionValue field for market value
    };
  }

  /**
   * Parse age string to number (e.g., "5Y" -> 5)
   */
  parseAge(age: string): number | undefined {
    if (!age) return undefined;
    
    const match = age.match(/(\d+)/);
    if (match) {
      const years = parseInt(match[1]);
      return years >= 0 && years <= 50 ? years : undefined;
    }
    return undefined;
  }

  /**
   * Map AI detected sex to backend gender enum
   */
  private mapGender(sex: string): 'MALE' | 'FEMALE' {
    const normalized = sex?.toUpperCase();
    if (normalized === 'MALE') return 'MALE';
    if (normalized === 'FEMALE') return 'FEMALE';
    
    // Default to MALE for ambiguity
    return 'MALE';
  }

  /**
   * Generate description from detected attributes
   */
  generateDescription(attributes: DetectedAttributes): string {
    const { breed, age, sex, health_status, health_details } = attributes;
    
    let description = `A ${age} ${sex.toLowerCase()} ${breed || 'cattle'}. `;
    
    if (health_status === 'HEALTHY') {
      description += 'The animal appears to be in good health with no detected diseases. ';
    } else {
      description += `Health status: ${health_status.toLowerCase()}. `;
      if (health_details.length > 0) {
        description += `Detected concerns: ${health_details.join(', ')}. `;
      }
    }
    
    description += 'This information was generated using AI analysis of the animal image.';
    
    return description;
  }
}

