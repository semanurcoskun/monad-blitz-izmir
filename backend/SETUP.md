# Quick Start Guide

## Prerequisites

- Node.js 18 or higher
- npm or yarn
- A Monad wallet address on testnet
- Monad testnet tokens (free from faucet)

## Step 1: Install Dependencies

```bash
cd backend
npm install
```

## Step 2: Configure Environment

```bash
# Copy example env file
cp .env.example .env

# Edit .env with your values
# PRIVATE_KEY - your private key for backend wallet (for minting)
# MONAD_RPC_URL - Monad testnet RPC URL
```

## Step 3: Deploy Smart Contracts

### Option A: Deploy to Monad Testnet

```bash
# Compile contracts
npm run compile

# Deploy to testnet (requires PRIVATE_KEY and funds)
npm run deploy:testnet
```

### Option B: Deploy Locally

```bash
# Terminal 1: Start local Monad node
npm run node:local

# Terminal 2: Deploy to local node
npm run deploy:local
```

After deployment, contract addresses will be automatically added to your `.env` file.

## Step 4: Start the Backend Server

```bash
# Development mode with auto-reload
npm run dev

# Or production mode
npm start
```

You should see:

```
🚀 Monad Ticket Backend Server Running
📍 Server: http://localhost:3000
✅ Ready to handle requests
```

## Step 5: Test the API

### Create a Ticket (Admin)

```bash
curl -X POST http://localhost:3000/api/tickets/mint \
  -H "Content-Type: application/json" \
  -d '{
    "toAddress": "0x742d35Cc6634C0532925a3b844Bc57e0f988e6db",
    "eventName": "Concert 2024",
    "eventDate": "2024-12-25",
    "eventLocation": "Istanbul Arena",
    "seatInfo": "Section A, Row 5, Seat 12",
    "price": "50"
  }'
```

### List a Ticket (Seller)

```bash
curl -X POST http://localhost:3000/api/marketplace/list \
  -H "Content-Type: application/json" \
  -d '{
    "sellerAddress": "0x742d35Cc6634C0532925a3b844Bc57e0f988e6db",
    "tokenId": "0",
    "price": "75"
  }'
```

### Buy a Ticket (Buyer)

```bash
curl -X POST http://localhost:3000/api/purchases/from-marketplace \
  -H "Content-Type: application/json" \
  -d '{
    "buyerAddress": "0x1234567890123456789012345678901234567890",
    "tokenId": "0",
    "amount": "75"
  }'
```

### Get User Tickets

```bash
curl http://localhost:3000/api/tickets/user/0x742d35Cc6634C0532925a3b844Bc57e0f988e6db
```

## Common Issues

### "Contract Address Not Found"

- Make sure contracts are deployed
- Check `.env` file has `TICKET_NFT_ADDRESS` and `MARKETPLACE_ADDRESS`
- Run `npm run deploy:testnet` or `npm run deploy:local`

### "Insufficient funds"

- Get free Monad testnet tokens from https://faucet.monad.xyz/
- Check balance with your wallet

### "Private Key Error"

- Make sure `.env` file has valid `PRIVATE_KEY`
- Key should start with `0x` and be 66 characters long
- Never share your private key!

### Port Already in Use

- Change PORT in `.env` file
- Or kill process on port 3000: `lsof -i :3000 | grep LISTEN | awk '{print $2}' | xargs kill -9`

## What's Included

```
backend/
├── contracts/          # Solidity smart contracts
│   ├── TicketNFT.sol
│   └── TicketMarketplace.sol
├── scripts/           # Deployment scripts
│   └── deploy.js
├── src/
│   ├── app.js        # Express app setup
│   ├── index.js      # Server entry point
│   ├── routes/       # API routes
│   │   ├── tickets.js
│   │   ├── marketplace.js
│   │   └── purchases.js
│   ├── services/     # Business logic
│   │   └── BlockchainService.js
│   └── middleware/   # Express middleware
│       └── errorHandler.js
├── test/             # Test files
├── package.json
├── hardhat.config.js # Hardhat configuration
├── .env.example      # Environment variables template
└── README.md         # Full documentation
```

## Next Steps

1. **Test with cURL or Postman** - Try the API endpoints
2. **Integrate with Frontend** - Connect Flutter app to this backend
3. **Add Authentication** - Implement JWT tokens for user management
4. **Database Integration** - Add MongoDB for user profiles and event management
5. **Advanced Features** - Implement ticket transfers, refunds, event cancellation

## Useful Resources

- Monad Docs: https://docs.monad.xyz/
- Hardhat Docs: https://hardhat.org/
- OpenZeppelin Contracts: https://docs.openzeppelin.com/contracts/
- Ethers.js: https://docs.ethers.org/v6/

## Support

For troubleshooting:

1. Check server logs for error messages
2. Verify `.env` configuration
3. Ensure smart contracts are deployed
4. Check Monad testnet faucet for funding
