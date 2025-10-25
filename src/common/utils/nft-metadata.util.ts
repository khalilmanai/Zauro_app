/**
 * Utility for creating NFT metadata that complies with Hedera's 100-byte limit
 */

export interface NftMetadata {
  name: string;
  id: string; // Reference ID to full data in database
  [key: string]: string | number; // Additional fields
}

export interface MinimalNftMetadata {
  n: string; // name
  s: string; // species
  b: string; // breed
  a: number; // age
  i: string; // id
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
  // Create minimal metadata with aggressive truncation
  const metadata: MinimalNftMetadata = {
    n: name.substring(0, 15), // Truncate name to 15 chars
    s: species.substring(0, 10), // Truncate species to 10 chars
    b: (breed || '').substring(0, 8), // Truncate breed to 8 chars
    a: age || 0,
    i: id.substring(0, 8), // Use only first 8 chars of ID
  };

  let jsonString = JSON.stringify(metadata);
  
  // If still too long, progressively reduce field sizes
  while (Buffer.byteLength(jsonString, 'utf8') > 100) {
    if (metadata.n.length > 10) {
      metadata.n = metadata.n.substring(0, 10);
    } else if (metadata.s.length > 8) {
      metadata.s = metadata.s.substring(0, 8);
    } else if (metadata.b.length > 6) {
      metadata.b = metadata.b.substring(0, 6);
    } else if (metadata.i.length > 6) {
      metadata.i = metadata.i.substring(0, 6);
    } else {
      // Last resort: minimal metadata
      metadata.n = metadata.n.substring(0, 8);
      metadata.s = metadata.s.substring(0, 6);
      metadata.b = '';
      metadata.a = 0;
      metadata.i = metadata.i.substring(0, 4);
    }
    jsonString = JSON.stringify(metadata);
  }

  // Convert minimal metadata to standard format for validation
  const standardMetadata: NftMetadata = {
    name: metadata.n,
    id: metadata.i,
    species: metadata.s,
    breed: metadata.b,
    age: metadata.a,
  };

  return createNftMetadata(standardMetadata);
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
