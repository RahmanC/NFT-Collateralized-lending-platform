// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";


contract EscrowFacet is ReentrancyGuard {
    event EscrowCreated(uint256 indexed escrowId, address indexed owner, address nftContract, uint256 tokenId);
    event EscrowReleased(uint256 indexed escrowId);
    
    function createEscrow(address _nftContract, uint256 _tokenId) external nonReentrant whenNotPaused {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        
        IERC721 nft = IERC721(_nftContract);
        require(nft.ownerOf(_tokenId) == msg.sender, "Not NFT owner");
        
        ds.escrowCounter++;
        uint256 escrowId = ds.escrowCounter;
        
        ds.escrows[escrowId] = LibDiamond.EscrowData({
            owner: msg.sender,
            nftContract: _nftContract,
            tokenId: _tokenId,
            loanId: 0,
            active: true
        });
        
        nft.transferFrom(msg.sender, address(this), _tokenId);
        emit EscrowCreated(escrowId, msg.sender, _nftContract, _tokenId);
    }
}

