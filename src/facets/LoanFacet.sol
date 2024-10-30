// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LoanFacet {
    struct Loan {
        address borrower;
        uint256 amount;
        bool repaid;
        bool isDefaulted;
    }
    
    mapping(uint256 => Loan) public loans;
    uint256 public loanCounter;
    
    event LoanInitiated(uint256 loanId, address borrower, uint256 amount);
    event LoanRepaid(uint256 loanId);

    function initiateLoan(uint256 _amount) external {
        loanCounter++;
        loans[loanCounter] = Loan(msg.sender, _amount, false, false);
        emit LoanInitiated(loanCounter, msg.sender, _amount);
    }

    function getLoan(uint256 _loanId) external view returns (Loan memory) {
    return loans[_loanId];
}

    function repayLoan(uint256 _loanId) external {
        Loan storage loan = loans[_loanId];
        require(msg.sender == loan.borrower, "Not the borrower");
        require(!loan.repaid, "Already repaid");

        loan.repaid = true;
        emit LoanRepaid(_loanId);
    }

        // Function for testing: mark loan as defaulted
    function setLoanAsDefaulted(uint256 _loanId) external {
        loans[_loanId].isDefaulted = true;
    }

}
