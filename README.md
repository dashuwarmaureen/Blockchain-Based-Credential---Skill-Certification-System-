# 🎓 Blockchain-Based Credential & Skill Certification System

A decentralized solution for verifying academic and vocational qualifications to combat credential fraud. This smart contract enables trusted verification of credentials for employers and educational institutions.

## ✨ Features

- 📝 Issue verifiable credentials on the Stacks blockchain
- 🏢 Register as a credential issuer (schools, universities, certification bodies)
- ✅ Verify credentials without intermediaries
- ⏱️ Support for credential expiration dates
- 🚫 Ability to revoke credentials when necessary
- 🔍 Authorized verifiers system for enhanced privacy

## 🚀 Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) installed
- Basic understanding of Clarity and Stacks blockchain

### Installation

1. Create a new Clarinet project:
```bash
clarinet new credential-system
```

2. Copy the contract code into `contracts/Blockchain-Based-Credential-System.clar`

3. Test the contract:
```bash
clarinet test
```

## 📖 Usage Guide

### For Credential Issuers

1. Register as an issuer:
```clarity
(contract-call? .Blockchain-Based-Credential-System register-issuer "University Name" "https://university.edu")
```

2. Wait for verification by contract owner (for trusted issuers)

3. Issue a credential:
```clarity
(contract-call? .Blockchain-Based-Credential-System issue-credential 
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM 
  "Degree" 
  "Bachelor of Computer Science" 
  u999999 
  "ipfs://QmHash")
```

### For Credential Holders

- Your credentials are automatically associated with your Stacks address
- Share your credential ID with potential employers or verifiers

### For Verifiers

- Verify a credential:
```clarity
(contract-call? .Blockchain-Based-Credential-System verify-credential u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

## 🔐 Security Considerations

- Credentials are publicly visible on the blockchain
- Only the credential issuer can revoke credentials
- Contract owner can authorize trusted verifiers
- Metadata can be stored off-chain with URI pointing to IPFS or similar systems

## 🤝 Contributing
Contributions are welcome! Please feel free to submit a Pull Request.

## 📜 License

This project is licensed under the MIT License.
```