// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract LoanFacet is ReentrancyGuard {
    event LoanCreated(uint256 indexed loanId, address indexed borrower, address indexed lender, uint256 amount);
    event LoanRepaid(uint256 indexed loanId);
    
    function createLoan(
        uint256 _escrowId,
        uint256 _amount,
        uint256 _interest,
        uint256 _duration
    ) external payable nonReentrant whenNotPaused {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(msg.value == _amount, "Incorrect loan amount");
        
        LibDiamond.EscrowData storage escrow = ds.escrows[_escrowId];
        require(escrow.active, "Escrow not active");
        require(escrow.loanId == 0, "Escrow already has loan");
        
        ds.loanCounter++;
        uint256 loanId = ds.loanCounter;
        
        ds.loans[loanId] = LibDiamond.LoanData({
            borrower: escrow.owner,
            lender: msg.sender,
            amount: _amount,
            interest: _interest,
            duration: _duration,
            startTime: block.timestamp,
            escrowId: _escrowId,
            active: true,
            defaulted: false,
            repaid: false
        });
        
        escrow.loanId = loanId;
        payable(escrow.owner).transfer(_amount);
        
        emit LoanCreated(loanId, escrow.owner, msg.sender, _amount);
    }
}
