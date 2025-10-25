/**
 * Utility for creating NFT metadata that complies with Hedera's 100-byte limit
 */

export interface NftMetadata {
  name: string;
  id: string; // Reference ID to full data in database
  [key: string]: string | number; // Additional fields
}

/**
 * Creates NFT metadata JSON string that fits within Hedera's 100-byte limit
 * @param metadata - The metadata object to serialize
 * @returns JSON string that should be under 100 bytes
 */
export function createNftMetadata(metadata: NftMetadata): string {
  const jsonString = JSON.stringify(metadata);
  
  // Check if metadata exceeds 100 bytes
  if (Buffer.byteLength(jsonString, 'utf8') > 100) {
    throw new Error(`NFT metadata exceeds 100-byte limit: ${Buffer.byteLength(jsonString, 'utf8')} bytes`);
  }
  
  return jsonString;
}

/**
 * Creates minimal animal NFT metadata
 * @param name - Animal name
 * @param species - Animal species
 * @param breed - Animal breed (optional)
 * @param age - Animal age (optional)
 * @param id - Animal database ID
 * @returns JSON metadata string under 100 bytes
 */
export function createAnimalNftMetadata(
  name: string,
  species: string,
  breed: string | null,
  age: number | null,
  id: string
): string {
  return createNftMetadata({
    name: name.substring(0, 20), // Truncate name if too long
    species,
    breed: breed || '',
    age: age || 0,
    id,
  });
}

/**
 * Validates that metadata string is under 100 bytes
 * @param metadata - The metadata string to validate
 * @returns true if valid, throws error if invalid
 */
export function validateNftMetadata(metadata: string): boolean {
  const byteLength = Buffer.byteLength(metadata, 'utf8');
  if (byteLength > 100) {
    throw new Error(`NFT metadata exceeds 100-byte limit: ${byteLength} bytes`);
  }
  return true;
}
