// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../libraries/LibDiamond.sol";
import "./PausableModifier.sol";

contract EscrowFacet is ReentrancyGuard, PausableModifier {
    event EscrowCreated(uint256 indexed escrowId, address indexed owner, address nftContract, uint256 tokenId);
    event EscrowReleased(uint256 indexed escrowId);
    
    function createEscrow(address _nftContract, uint256 _tokenId) external nonReentrant whenNotPaused returns (uint256) {
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
        
        // Transfer NFT to this contract
        nft.transferFrom(msg.sender, address(this), _tokenId);
        emit EscrowCreated(escrowId, msg.sender, _nftContract, _tokenId);
        
        return escrowId;
    }

    function releaseEscrow(uint256 _escrowId) external nonReentrant whenNotPaused {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        LibDiamond.EscrowData storage escrow = ds.escrows[_escrowId];
        
        require(escrow.active, "Escrow not active");
        require(escrow.loanId == 0, "Escrow has active loan");
        require(escrow.owner == msg.sender, "Not escrow owner");
        
        escrow.active = false;
        IERC721(escrow.nftContract).transferFrom(address(this), msg.sender, escrow.tokenId);
        
        emit EscrowReleased(_escrowId);
    }
}