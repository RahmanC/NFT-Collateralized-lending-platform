// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PriceFacet {
    struct PriceData {
        uint256 price;
        uint256 updatedAt;
    }
    
    mapping(address => mapping(uint256 => PriceData)) private nftPrices;
    
    event PriceUpdated(address indexed nftContract, uint256 indexed tokenId, uint256 price);
    
    function updatePrice(address _nftContract, uint256 _tokenId, uint256 _price) external {
        nftPrices[_nftContract][_tokenId] = PriceData(_price, block.timestamp);
        emit PriceUpdated(_nftContract, _tokenId, _price);
    }
    
    function getPrice(address _nftContract, uint256 _tokenId) external view returns (uint256, uint256) {
        PriceData memory data = nftPrices[_nftContract][_tokenId];
        return (data.price, data.updatedAt);
    }
}