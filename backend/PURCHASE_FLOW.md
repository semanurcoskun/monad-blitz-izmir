# Ticket Purchase Flow with Monad Wallet

## Overview

This document outlines how users purchase tickets using their Monad wallet in the mobile app.

## Complete Purchase Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        User's Phone (Flutter)                    │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Flutter App                                             │   │
│  │  - Browse available tickets                            │   │
│  │  - Check marketplace listings                          │   │
│  │  - Select ticket to purchase                           │   │
│  └──────────┬───────────────────────────────────────────────┘   │
│             │                                                     │
│             │ 1. Get wallet connected (WalletConnect/MetaMask)  │
│             ▼                                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Wallet Module                                           │   │
│  │  - Store user's wallet address                         │   │
│  │  - Sign transactions                                    │   │
│  │  - Manage private keys securely                        │   │
│  └──────────┬───────────────────────────────────────────────┘   │
│             │                                                     │
└─────────────┼─────────────────────────────────────────────────────┘
              │
              │ 2. API Call: GET /api/marketplace/listing/:tokenId
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Backend Server                              │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Verify listing exists and price matches               │   │
│  │  Response: { seller, price, active }                   │   │
│  └──────────┬───────────────────────────────────────────────┘   │
│             │                                                     │
│             │ 3. Prepare transaction for signing                │
│             ▼                                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Generate transaction data for buyTicket()             │   │
│  │  Return to app for user signature                      │   │
│  └──────────┬───────────────────────────────────────────────┘   │
└─────────────┼─────────────────────────────────────────────────────┘
              │
              │ Response: Transaction data
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│  User's Phone - Wallet Signing                                  │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  User Reviews Transaction                              │   │
│  │  - Amount: 75 MON                                      │   │
│  │  - To: TicketMarketplace contract                     │   │
│  │  - Confirm to proceed                                 │   │
│  └──────────┬───────────────────────────────────────────────┘   │
│             │                                                     │
│             │ User confirms transaction                         │
│             ▼                                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Wallet Signs Transaction                              │   │
│  │  - Private key signs the data                         │   │
│  │  - Returns signed transaction                         │   │
│  └──────────┬───────────────────────────────────────────────┘   │
│             │                                                     │
└─────────────┼─────────────────────────────────────────────────────┘
              │
              │ 4. Signed Transaction Sent to Backend
              │    POST /api/purchases/from-marketplace
              │    { buyerAddress, tokenId, amount, signature }
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Backend Server                              │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Validate Transaction                                   │   │
│  │  - Verify signature is valid                           │   │
│  │  - Check listing still exists                          │   │
│  │  - Verify price matches                                │   │
│  └──────────┬───────────────────────────────────────────────┘   │
│             │                                                     │
│             ▼                                                     │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Submit Transaction to Blockchain                      │   │
│  │  - Call marketplace.buyTicket() via ethers.js         │   │
│  │  - Wait for confirmation                              │   │
│  └──────────┬───────────────────────────────────────────────┘   │
│             │                                                     │
└─────────────┼─────────────────────────────────────────────────────┘
              │
              │ Transaction submitted to Monad network
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Monad Blockchain                              │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Smart Contract Execution (buyTicket)                   │   │
│  │  1. Verify NFT is listed                               │   │
│  │  2. Transfer MON from buyer to contract                │   │
│  │  3. Calculate fees (5% platform, 95% to seller)        │   │
│  │  4. Transfer NFT to buyer                              │   │
│  │  5. Send seller's payment (95%)                        │   │
│  │  6. Send platform fee (5%)                             │   │
│  │  7. Emit TicketPurchased event                         │   │
│  └──────────┬───────────────────────────────────────────────┘   │
│             │                                                     │
└─────────────┼─────────────────────────────────────────────────────┘
              │
              │ Transaction confirmed (Tx Hash)
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Backend Server                              │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Return Success Response                               │   │
│  │  {                                                       │   │
│  │    "success": true,                                    │   │
│  │    "transactionHash": "0x...",                         │   │
│  │    "buyer": "0x...",                                   │   │
│  │    "tokenId": "0",                                     │   │
│  │    "amount": "75"                                      │   │
│  │  }                                                      │   │
│  └──────────┬───────────────────────────────────────────────┘   │
│             │                                                     │
└─────────────┼─────────────────────────────────────────────────────┘
              │
              │ Success response with transaction hash
              │
              ▼
┌─────────────────────────────────────────────────────────────────┐
│                  User's Phone (Flutter)                          │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  Display Success Message                               │   │
│  │  - Show transaction hash for verification             │   │
│  │  - Display "Ticket Added to Wallet"                   │   │
│  │  - Allow viewing of newly owned ticket                │   │
│  │  - Redirect to user's tickets page                    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Step-by-Step Integration Guide for Flutter App

### 1. Connect User's Wallet

```dart
// In Flutter app
final walletAddress = await walletConnect.connect();
// walletAddress example: "0x742d35Cc6634C0532925a3b844Bc57e0f988e6db"
```

### 2. Display Available Listings

```dart
Future<void> fetchListings() async {
  final response = await http.get(
    Uri.parse('http://localhost:3000/api/marketplace/transactions'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      listings = data['transactions'];
    });
  }
}
```

### 3. Show Listing Details Before Purchase

```dart
Future<void> getListingDetails(String tokenId) async {
  final response = await http.get(
    Uri.parse('http://localhost:3000/api/marketplace/listing/$tokenId'),
  );

  if (response.statusCode == 200) {
    final listing = jsonDecode(response.body)['listing'];
    // Show price: listing['price']
    // Show seller: listing['seller']
    // Show status: listing['active']
  }
}
```

### 4. Create Purchase Transaction

```dart
Future<void> purchaseTicket(String tokenId, String price) async {
  // Step 1: Prepare transaction data
  final transactionData = {
    'to': MARKETPLACE_CONTRACT_ADDRESS,
    'data': web3.encodeFunction('buyTicket', [tokenId]),
    'value': web3.parseEther(price), // Convert to Wei
  };

  // Step 2: User signs with their wallet
  final signature = await walletConnect.signPersonalMessage(
    serializedTransaction: transactionData,
  );

  // Step 3: Send signed transaction to backend
  final response = await http.post(
    Uri.parse('http://localhost:3000/api/purchases/from-marketplace'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'buyerAddress': walletAddress,
      'tokenId': tokenId,
      'amount': price,
      'signature': signature, // Optional, for verification
    }),
  );

  if (response.statusCode == 200) {
    final result = jsonDecode(response.body);
    print('Purchase successful!');
    print('Transaction Hash: ${result['transactionHash']}');

    // Refresh user tickets
    await fetchUserTickets();
  }
}
```

### 5. Verify User Owns Ticket

```dart
Future<void> fetchUserTickets() async {
  final response = await http.get(
    Uri.parse(
      'http://localhost:3000/api/tickets/user/$walletAddress',
    ),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    setState(() {
      userTickets = data['tickets'];
    });
  }
}
```

## Cost Breakdown

When user buys a ticket for 75 MON:

1. **Platform Fee**: 75 × 5% = 3.75 MON → Backend wallet
2. **Seller Payment**: 75 × 95% = 71.25 MON → Seller's wallet
3. **Total from buyer**: 75 MON

## Error Scenarios

### Insufficient Balance

```
Error: "Insufficient funds for transaction"
Action: Suggest user get more MON from faucet
```

### Price Mismatch

```
Error: "Price mismatch with listing"
Cause: Listing price changed between viewing and purchase
Action: Refresh and try again
```

### Listing Inactive

```
Error: "Listing is not active"
Cause: Seller cancelled listing before purchase completed
Action: Show alternative listings
```

### Invalid Wallet Address

```
Error: "Invalid wallet address"
Cause: Address format incorrect
Action: Ensure wallet is properly connected
```

## Production Considerations

1. **Environment Setup**
   - Use Monad mainnet RPC URL in production
   - Keep contract addresses in secure config
   - Implement API rate limiting

2. **Security**
   - Never store private keys on backend
   - Always validate addresses
   - Implement transaction verification
   - Use HTTPS for all API calls

3. **User Experience**
   - Show transaction pending state
   - Display transaction explorer link
   - Implement polling for confirmation
   - Clear error messages

4. **Monitoring**
   - Log all transactions
   - Monitor failed purchases
   - Track platform fees
   - Alert on unusual activity

## Testing Purchase Flow Locally

```bash
# Terminal 1: Start local Monad node
cd backend
npm run node:local

# Terminal 2: Deploy contracts
npm run deploy:local

# Terminal 3: Start backend server
npm run dev

# Terminal 4: Test API
curl -X POST http://localhost:3000/api/purchases/from-marketplace \
  -H "Content-Type: application/json" \
  -d '{
    "buyerAddress": "0x70997970C51812e339D9B73b0245ad59e1gg6F07",
    "tokenId": "0",
    "amount": "75"
  }'
```

## Next Steps

1. Implement wallet connection in Flutter using WalletConnect or MetaMask
2. Add transaction signing functionality
3. Implement real-time transaction status monitoring
4. Add refund/cancellation logic
5. Implement user profiles and purchase history
