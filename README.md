# NFT Collateralized Lending Platform

A decentralized lending platform that enables NFT holders to use their NFTs as collateral for loans, built using the Diamond Standard (EIP-2535) for upgradeability.

## Table of Contents
- [Overview](#overview)
- [Features](#features)
- [Architecture](#architecture)
- [Installation](#installation)
- [Testing](#testing)
- [Contract Interactions](#contract-interactions)
- [Security Considerations](#security-considerations)
- [Development](#development)
- [License](#license)

## Overview

This platform enables NFT owners to use their digital assets as collateral for loans. Built using the Diamond Pattern, it ensures upgradeability and modularity while maintaining secure custody of NFTs and loan management.

### Key Features
- NFT collateralization
- Flexible loan terms
- Automated liquidation
- Upgradeable architecture
- Price oracle integration
- Interest rate management
- Emergency pause functionality

## Architecture

[NFT Collateralized Lending Platform Flow Diagram](https://app.eraser.io/workspace/RjVO5XWiFb0eH50AcEPc?origin=share&elements=_h_MN4VxWp80G0x_GNDzLw)

### Diamond Pattern Implementation
The platform uses the Diamond Pattern (EIP-2535) with the following facets:

```
├── DiamondProxy.sol       # Main proxy contract
├── facets/
│   ├── AdminFacet.sol     # Administrative functions
│   ├── EscrowFacet.sol    # NFT custody management
│   ├── LoanFacet.sol      # Loan lifecycle management
│   ├── LiquidationFacet.sol # Default handling
│   └── PriceFacet.sol     # NFT price oracle
```

### Core Components

1. **Diamond Proxy**
   - Central contract that delegates calls to facets
   - Manages contract upgrades
   - Handles access control

2. **Storage Library**
   - Manages shared state across facets
   - Implements diamond storage pattern
   - Handles data structure versioning

3. **Facets**
   - AdminFacet: Platform administration
   - EscrowFacet: NFT custody
   - LoanFacet: Loan management
   - LiquidationFacet: Default handling
   - PriceFacet: NFT valuation

## Installation

### Prerequisites
- Foundry
- Solidity ^0.8.0

### Setup
```bash
# Clone the repository
git clone https://github.com/RahmanC/NFT-Collateralized-lending-platform

# Install dependencies
forge install

# Build contracts
forge build

# Run tests
forge test
```

## Testing

The platform includes comprehensive tests covering all major functionality:

```bash
# Run all tests
forge test

# Run specific test file
forge test --match-path test/LendingPlatformTest.t.sol

# Run tests with gas reporting
forge test --gas-report
```

### Test Coverage
- Full loan lifecycle
- NFT escrow management
- Liquidation scenarios
- Access control
- Emergency procedures

## Contract Interactions

### For NFT Owners (Borrowers)

1. **Depositing NFT Collateral**
```solidity
// Approve NFT transfer
IERC721(nftContract).approve(platformAddress, tokenId);

// Create escrow
EscrowFacet(platformAddress).createEscrow(nftContract, tokenId);
```

2. **Taking a Loan**
```solidity
// Get loan terms
LoanFacet(platformAddress).getLoanTerms(escrowId);

// Accept loan
LoanFacet(platformAddress).acceptLoan(escrowId, loanTerms);
```

3. **Repaying a Loan**
```solidity
// Repay loan
LoanFacet(platformAddress).repayLoan{value: repaymentAmount}(loanId);
```

### For Lenders

1. **Providing a Loan**
```solidity
// Create loan offer
LoanFacet(platformAddress).createLoan{value: loanAmount}(
    escrowId,
    amount,
    interest,
    duration
);
```

2. **Claiming Defaulted Collateral**
```solidity
// Initiate liquidation
LiquidationFacet(platformAddress).liquidate(loanId);
```

## Security Considerations

### Implemented Security Measures
- Reentrancy protection
- Access control
- Emergency pause
- Input validation
- State validation
- Event emission



## Development

### Adding New Features

1. Create new facet contract
```solidity
contract NewFacet {
    function newFunction() external {
        // Implementation
    }
}
```

2. Deploy facet
```bash
forge create src/facets/NewFacet.sol:NewFacet
```

3. Add to Diamond
```solidity
diamondCut.push(FacetCut({
    facetAddress: newFacetAddress,
    action: FacetCutAction.Add,
    functionSelectors: selectors
}));
```


## License

MIT License. 
