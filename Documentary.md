# Fun_app Documentation

## Overview
Fun_app is a simple liquidity protocol built on the Stacks blockchain using Clarity smart contracts. It allows users to deposit STX as liquidity into a pool and receive LP (Liquidity Provider) tokens in return. Users can later withdraw their liquidity proportionally based on their LP token holdings. This is a basic implementation designed for educational and demonstration purposes, focusing on core depositing functionality.

The protocol emphasizes fun and simplicity: "Deposit STX, get fun LP tokens, and withdraw when ready!" Future expansions could include token pairs, fees, or gamified elements.

## Key Features
- **Deposit Liquidity**: Users deposit STX and receive LP tokens (1 STX = 1,000,000 LP tokens ratio for demo).
- **Withdraw Liquidity**: Burn LP tokens to withdraw proportional STX.
- **Owner Controls**: Contract owner can update ownership.
- **Read-Only Queries**: Check total liquidity, LP supply, and user balances.

## Smart Contract Details
The contract is defined in `fun-app.clar`:
- **Data Variables**:
  - `owner`: Principal controlling the contract.
  - `total-liquidity`: Total STX deposited.
  - `lp-total-supply`: Total LP tokens issued.
- **Maps**:
  - `liquidity-holders`: Tracks user STX deposits (not LP, for simplicity).
- **Public Functions**:
  - `deposit-liquidity(uint)`: Deposits STX, mints LP tokens, updates state.
  - `withdraw-liquidity(uint)`: Burns LP, withdraws STX proportionally.
  - `set-owner(principal)`: Transfers ownership (owner-only).
- **Read-Only Functions**:
  - `get-liquidity-total()`: Returns total STX in pool.
  - `get-lp-total-supply()`: Returns total LP tokens.
  - `get-user-liquidity(principal)`: User's deposited STX.
  - `get-balance(principal)`: User's effective LP balance.
- **Trait**: Implements a basic `lp-token` trait for compatibility.

## Deployment and Usage
1. **Setup with Clarinet**:
   - Install Clarinet: `cargo install clarinet`.
   - Create project: `clarinet new fun-app`.
   - Replace `contracts/fun-app.clar` with the provided code.
   - Run `clarinet check` to validate.

2. **Testing** (Recommended, though not included here):
   - Use Clarinet's testing framework to simulate deposits/withdrawals.
   - Example test scenario: Deploy, deposit 100 STX, verify LP minted, withdraw, verify STX returned.

3. **Deployment**:
   - Deploy to testnet/mainnet via Clarinet or Hiro tools.
   - Interact via wallet (e.g., Leather) or custom UI calling `deposit-liquidity` and `withdraw-liquidity`.

4. **Integration**:
   - LP Tokens: Extend with full SIP-010 for transferable tokens.

## Security Considerations
- **Reentrancy**: Clarity's atomic transactions prevent this.
- **Overflows**: Use safe math (Clarity's built-in checks).
- **Access Control**: Owner-only functions use assertions.
- **Audits**: This is demo code; professional audit recommended for production.
- **Edge Cases**: Handles zero amounts, insufficient balances.

## Future Enhancements
- Support for token pairs (e.g., STX/SIP-010).
- Yield farming or rewards.
- Gamification: Random "fun" bonuses on deposits.
- Full SIP-010 LP token contract.

## License
MIT License. Feel free to fork and build upon!

For questions, reach out on X (Twitter) or Stacks forums.