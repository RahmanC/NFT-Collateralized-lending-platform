// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LiquidationFacet {
    struct Loan {
        bool isDefaulted;
    }
    
    mapping(uint256 => Loan) public loans;

    event Liquidated(uint256 loanId);

    function liquidate(uint256 _loanId) external {
        Loan storage loan = loans[_loanId];
        require(loan.isDefaulted, "Loan is not in default");

        // Liquidation logic here

        emit Liquidated(_loanId);
    }

    function getLoanDefaultStatus(uint256 _loanId) external view returns (bool) {
        return loans[_loanId].isDefaulted;
    }
}
