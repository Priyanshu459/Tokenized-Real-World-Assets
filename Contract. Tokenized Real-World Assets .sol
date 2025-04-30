// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title RealWorldAssetToken
 * @dev A contract for tokenizing real-world assets as NFTs
 */
contract RealWorldAssetToken is ERC721, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    
    // Asset metadata structure
    struct AssetDetails {
        string assetType;      // e.g., "RealEstate", "Art", "Commodity"
        string assetLocation;  // Physical location identifier
        uint256 assetValue;    // Value in USD (scaled by 10^2 for cents precision)
        string legalReference; // Reference to legal document
        uint256 tokenizationDate;
    }
    
    // Mapping from token ID to asset details
    mapping(uint256 => AssetDetails) private _assetDetails;
    
    // Events
    event AssetTokenized(uint256 indexed tokenId, address indexed owner, string assetType, uint256 assetValue);
    event AssetDetailsUpdated(uint256 indexed tokenId, uint256 newValue, string legalReference);
    
    constructor() ERC721("RealWorldAssetToken", "RWAT") Ownable(msg.sender) {}
    
    /**
     * @dev Tokenize a new real-world asset
     * @param to Address that will own the new token
     * @param assetType Type of the real-world asset
     * @param assetLocation Physical location identifier
     * @param assetValue Value in USD (scaled by 10^2)
     * @param legalReference Reference to legal documentation
     * @return tokenId of the newly created token
     */
    function tokenizeAsset(
        address to,
        string memory assetType,
        string memory assetLocation,
        uint256 assetValue,
        string memory legalReference
    ) public onlyOwner returns (uint256) {
        require(bytes(assetType).length > 0, "Asset type cannot be empty");
        require(bytes(assetLocation).length > 0, "Asset location cannot be empty");
        require(assetValue > 0, "Asset value must be greater than zero");
        require(bytes(legalReference).length > 0, "Legal reference cannot be empty");
        
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        
        _mint(to, newTokenId);
        
        _assetDetails[newTokenId] = AssetDetails({
            assetType: assetType,
            assetLocation: assetLocation,
            assetValue: assetValue,
            legalReference: legalReference,
            tokenizationDate: block.timestamp
        });
        
        emit AssetTokenized(newTokenId, to, assetType, assetValue);
        
        return newTokenId;
    }
    
    /**
     * @dev Update asset details for an existing token
     * @param tokenId The token ID to update
     * @param newValue The updated asset value
     * @param newLegalReference The updated legal reference
     */
    function updateAssetDetails(
        uint256 tokenId,
        uint256 newValue,
        string memory newLegalReference
    ) public onlyOwner {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        require(newValue > 0, "Asset value must be greater than zero");
        require(bytes(newLegalReference).length > 0, "Legal reference cannot be empty");
        
        AssetDetails storage details = _assetDetails[tokenId];
        details.assetValue = newValue;
        details.legalReference = newLegalReference;
        
        emit AssetDetailsUpdated(tokenId, newValue, newLegalReference);
    }
    
    /**
     * @dev Get the asset details for a specific token
     * @param tokenId The token ID to query
     * @return assetType The type of asset represented by the token
     * @return assetLocation The physical location of the asset
     * @return assetValue The current value of the asset in USD
     * @return legalReference Reference to the legal documentation
     * @return tokenizationDate The timestamp when the asset was tokenized
     */
    function getAssetDetails(uint256 tokenId) public view returns (
        string memory assetType,
        string memory assetLocation,
        uint256 assetValue,
        string memory legalReference,
        uint256 tokenizationDate
    ) {
        require(_ownerOf(tokenId) != address(0), "Token does not exist");
        
        AssetDetails storage details = _assetDetails[tokenId];
        return (
            details.assetType,
            details.assetLocation,
            details.assetValue,
            details.legalReference,
            details.tokenizationDate
        );
    }
}
