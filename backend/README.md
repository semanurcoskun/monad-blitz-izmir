# Monad Decentralized Ticket Booking Backend

A blockchain-based ticket booking system built on the Monad blockchain with Solidity smart contracts and Node.js/Express backend.

## Project Overview

This backend enables:

- **Ticket NFT Minting**: Create unique ticket NFTs for events
- **Marketplace**: Buy/sell tickets using Monad (MON) cryptocurrency
- **Decentralized Ownership**: Complete NFT ownership and transfer
- **Transaction History**: Track all purchases and sales

## Architecture

```
┌─────────────────┐
│  Flutter App    │
└────────┬────────┘
         │
    ┌────▼───────────┐
    │  Express.js    │
    │   Backend      │
    └────┬───────┬───┘
         │       │
    ┌────▼──┐┌───▼────┐
    │Ethers │║ Monad  │
    │.js    ║ Testnet │
    └────┬──┘└───┬────┘
         │       │
    ┌────▼───────▼────┐
    │  Smart Contracts│
    │ (TicketNFT,    │
    │  Marketplace)  │
    └────────────────┘
```

## Smart Contracts

### TicketNFT.sol

ERC-721 based contract for ticket NFTs

**Key Functions:**

- `mintTicket()` - Create new ticket NFT
- `getOwnerTickets()` - Retrieve user's tickets
- `useTicket()` - Mark ticket as used
- `transferFrom()` - Transfer ticket to another address

### TicketMarketplace.sol

Handles ticket buying and selling with Monad

**Key Functions:**

- `listTicket()` - List ticket for sale
- `buyTicket()` - Purchase ticket with Monad
- `cancelListing()` - Remove listing
- `getListing()` - Get listing details

## Setup & Installation

### Prerequisites

- Node.js 18+
- npm or yarn
- Monad testnet account with test MON tokens

### Installation

```bash
cd backend
npm install
```

### Configuration

1. Create `.env` file:

```bash
cp .env.example .env
```

2. Update `.env` with your values:

```env
PRIVATE_KEY=your_private_key_here
MONAD_RPC_URL=https://testnet-rpc.monad.xyz/
PORT=3000
NODE_ENV=development
```

### Deploy Smart Contracts

```bash
# Compile contracts
npm run compile

# Deploy to Monad testnet
npm run deploy:testnet

# Or deploy locally
npm run node:local  # In one terminal
npm run deploy:local  # In another terminal
```

The deployment script will:

- Deploy TicketNFT contract
- Deploy TicketMarketplace contract
- Save contract addresses to `.env`

## API Endpoints

### Tickets

#### Mint Ticket

```
POST /api/tickets/mint
Content-Type: application/json

{
  "toAddress": "0x...",
  "eventName": "Concert 2024",
  "eventDate": "2024-12-25",
  "eventLocation": "Istanbul Arena",
  "seatInfo": "Section A, Row 5, Seat 12",
  "price": "50"
}
```

#### Get User Tickets

```
GET /api/tickets/user/:address
```

#### Get Ticket Details

```
GET /api/tickets/:tokenId
```

#### Use Ticket

```
POST /api/tickets/:tokenId/use
```

### Marketplace

#### List Ticket for Sale

```
POST /api/marketplace/list
Content-Type: application/json

{
  "sellerAddress": "0x...",
  "tokenId": "1",
  "price": "75"
}
```

#### Get Listing

```
GET /api/marketplace/listing/:tokenId
```

#### Cancel Listing

```
POST /api/marketplace/cancel/:tokenId
```

#### Get Seller's Listings

```
GET /api/marketplace/listings/seller/:address
```

#### Get Marketplace Transactions

```
GET /api/marketplace/transactions
```

### Purchases

#### Buy from Marketplace

```
POST /api/purchases/from-marketplace
Content-Type: application/json

{
  "buyerAddress": "0x...",
  "tokenId": "1",
  "amount": "75"
}
```

#### Get Purchase History

```
GET /api/purchases/history
```

#### Get User Purchases

```
GET /api/purchases/user/:address
```

## Running the Server

```bash
# Development with watch mode
npm run dev

# Production
npm start
```

Server runs on `http://localhost:3000` by default.

## Response Format

### Success Response

```json
{
  "success": true,
  "message": "Operation completed",
  "data": {}
}
```

### Error Response

```json
{
  "error": "Error message",
  "details": "Additional details"
}
```

## Transaction Flow

### Buying a Ticket

1. Seller lists ticket on marketplace
2. Buyer calls `/api/purchases/from-marketplace`
3. Backend verifies listing exists and price matches
4. Backend calls `buyTicket()` on smart contract
5. Smart contract:
   - Transfers NFT to buyer
   - Splits payment (95% to seller, 5% platform fee)
   - Records transaction
6. Response returns transaction hash

## Wallet Integration

The backend uses a backend wallet for minting operations. For user purchases:

1. Mobile app has user's wallet
2. User signs transaction with their wallet
3. Transaction is sent to blockchain via user's wallet
4. Backend only queries blockchain state

## Testing

```bash
npm test
```

## Environment Variables

| Variable            | Description                                 |
| ------------------- | ------------------------------------------- |
| MONAD_RPC_URL       | Monad blockchain RPC endpoint               |
| PRIVATE_KEY         | Private key for backend wallet (minting)    |
| PORT                | Server port (default: 3000)                 |
| NODE_ENV            | Environment (development/production)        |
| TICKET_NFT_ADDRESS  | Deployed TicketNFT contract address         |
| MARKETPLACE_ADDRESS | Deployed TicketMarketplace contract address |

## Important Notes

- All prices are in MON tokens
- Backend wallet is only used for minting new tickets
- User purchases require WalletConnect or direct wallet signing
- 5% platform fee on all marketplace transactions
- Ticket can only be used once (burned on use)

## Security Notes

- Never commit `.env` file
- Use environment variables for sensitive data
- Validate all user inputs
- Implement rate limiting in production
- Use HTTPS in production
- Implement proper error logging

## Future Enhancements

- [ ] Database integration for user profiles
- [ ] Authentication system with JWT
- [ ] Event management dashboard
- [ ] Advanced marketplace filters
- [ ] Ticket transfer without marketplace
- [ ] Subscription/loyalty system
- [ ] Multi-currency support

## Support

For issues or questions, check:

- Monad documentation: https://docs.monad.xyz/
- OpenZeppelin contracts: https://docs.openzeppelin.com/contracts/
- Express documentation: https://expressjs.com/
