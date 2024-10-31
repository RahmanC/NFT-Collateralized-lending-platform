// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library LibDiamond {
    bytes32 constant DIAMOND_STORAGE_POSITION = keccak256("diamond.storage");
    
    struct DiamondStorage {
        mapping(bytes4 => address) facets;
        mapping(uint256 => LoanData) loans;
        mapping(uint256 => EscrowData) escrows;
        uint256 loanCounter;
        uint256 escrowCounter;
        address owner;
        address treasury;
        mapping(address => bool) admins;
        bool paused;  // Added pause state to diamond storage
    }
    
    struct LoanData {
        address borrower;
        address lender;
        uint256 amount;
        uint256 interest;
        uint256 duration;
        uint256 startTime;
        uint256 escrowId;
        bool active;
        bool defaulted;
        bool repaid;
    }
    
    struct EscrowData {
        address owner;
        address nftContract;
        uint256 tokenId;
        uint256 loanId;
        bool active;
    }
    
    function diamondStorage() internal pure returns (DiamondStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}