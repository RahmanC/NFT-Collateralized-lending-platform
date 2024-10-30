// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EscrowFacet {
    struct Escrow {
        address owner;
        address nftContract;
        uint256 tokenId;
    }

    mapping(uint256 => Escrow) public escrows;
    uint256 public escrowCounter;

    event EscrowCreated(uint256 escrowId, address owner, address nftContract, uint256 tokenId);
    
    function createEscrow(address _nftContract, uint256 _tokenId) external {
        escrowCounter++;
        escrows[escrowCounter] = Escrow(msg.sender, _nftContract, _tokenId);
        emit EscrowCreated(escrowCounter, msg.sender, _nftContract, _tokenId);
    }
}
