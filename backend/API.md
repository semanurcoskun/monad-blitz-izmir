# Monad Ticket Backend - API Reference

## Base URL

```
http://localhost:3000/api
```

## Authentication

Currently, no authentication is required. Future versions will implement JWT tokens.

---

## Tickets Endpoints

### 1. Mint Ticket

Create a new ticket NFT for an event.

**Endpoint:** `POST /tickets/mint`

**Request Body:**

```json
{
  "toAddress": "0x...",
  "eventName": "Concert 2024",
  "eventDate": "2024-12-25",
  "eventLocation": "Istanbul Arena",
  "seatInfo": "Section A, Row 5, Seat 12",
  "price": "50"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Ticket minted successfully",
  "transactionHash": "0x...",
  "ticket": {
    "to": "0x...",
    "eventName": "Concert 2024",
    "eventDate": "2024-12-25",
    "eventLocation": "Istanbul Arena",
    "seatInfo": "Section A, Row 5, Seat 12",
    "price": "50"
  }
}
```

**Status Codes:**

- `201` - Ticket minted successfully
- `400` - Validation error
- `500` - Server error

---

### 2. Get User Tickets

Retrieve all tickets owned by a user.

**Endpoint:** `GET /tickets/user/:address`

**Parameters:**

- `address` (required) - Ethereum wallet address

**Response:**

```json
{
  "success": true,
  "address": "0x...",
  "count": 3,
  "tickets": [
    {
      "tokenId": "0",
      "eventName": "Concert 2024",
      "eventDate": "2024-12-25",
      "eventLocation": "Istanbul Arena",
      "seatInfo": "Section A, Row 5, Seat 12",
      "price": "50",
      "purchaseTimestamp": 1700000000,
      "used": false
    }
  ]
}
```

---

### 3. Get Ticket Details

Retrieve details of a specific ticket.

**Endpoint:** `GET /tickets/:tokenId`

**Parameters:**

- `tokenId` (required) - Token ID of the ticket

**Response:**

```json
{
  "success": true,
  "ticket": {
    "tokenId": "0",
    "eventName": "Concert 2024",
    "eventDate": "2024-12-25",
    "eventLocation": "Istanbul Arena",
    "seatInfo": "Section A, Row 5, Seat 12",
    "price": "50",
    "purchaseTimestamp": 1700000000,
    "used": false
  }
}
```

---

### 4. Use Ticket

Mark a ticket as used (e.g., at event entry).

**Endpoint:** `POST /tickets/:tokenId/use`

**Parameters:**

- `tokenId` (required) - Token ID of the ticket

**Response:**

```json
{
  "success": true,
  "message": "Ticket marked as used",
  "transactionHash": "0x...",
  "tokenId": "0"
}
```

---

## Marketplace Endpoints

### 1. List Ticket

List a ticket for sale on the marketplace.

**Endpoint:** `POST /marketplace/list`

**Request Body:**

```json
{
  "sellerAddress": "0x...",
  "tokenId": "0",
  "price": "75"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Ticket listed successfully",
  "transactionHash": "0x...",
  "listing": {
    "tokenId": "0",
    "seller": "0x...",
    "price": "75",
    "listedAt": "2024-03-28T10:00:00Z"
  }
}
```

---

### 2. Get Listing Details

Get information about a listing.

**Endpoint:** `GET /marketplace/listing/:tokenId`

**Parameters:**

- `tokenId` (required) - Token ID of the ticket

**Response:**

```json
{
  "success": true,
  "tokenId": "0",
  "listing": {
    "seller": "0x...",
    "price": "75",
    "active": true
  }
}
```

---

### 3. Cancel Listing

Remove a ticket from the marketplace.

**Endpoint:** `POST /marketplace/cancel/:tokenId`

**Parameters:**

- `tokenId` (required) - Token ID of the ticket

**Response:**

```json
{
  "success": true,
  "message": "Listing cancelled successfully",
  "transactionHash": "0x...",
  "tokenId": "0"
}
```

---

### 4. Get Active Listings by Seller

Get all active listings for a specific seller.

**Endpoint:** `GET /marketplace/listings/seller/:address`

**Parameters:**

- `address` (required) - Seller's wallet address

**Response:**

```json
{
  "success": true,
  "seller": "0x...",
  "count": 2,
  "listings": [
    {
      "tokenId": "0",
      "eventName": "Concert 2024",
      "eventDate": "2024-12-25",
      "eventLocation": "Istanbul Arena",
      "seatInfo": "Section A, Row 5, Seat 12",
      "price": "50",
      "listingPrice": "75"
    }
  ]
}
```

---

### 5. Get Marketplace Transactions

Retrieve all transactions on the marketplace.

**Endpoint:** `GET /marketplace/transactions`

**Response:**

```json
{
  "success": true,
  "count": 5,
  "transactions": [
    {
      "buyer": "0x...",
      "seller": "0x...",
      "tokenId": "0",
      "price": "75",
      "timestamp": "2024-03-28T10:05:00Z"
    }
  ]
}
```

---

## Purchases Endpoints

### 1. Buy from Marketplace

Purchase a ticket listed on the marketplace.

**Endpoint:** `POST /purchases/from-marketplace`

**Request Body:**

```json
{
  "buyerAddress": "0x...",
  "tokenId": "0",
  "amount": "75"
}
```

**Response:**

```json
{
  "success": true,
  "message": "Marketplace purchase completed successfully",
  "transactionHash": "0x...",
  "buyer": "0x...",
  "tokenId": "0",
  "amount": "75",
  "timestamp": "2024-03-28T10:05:00Z"
}
```

---

### 2. Get Purchase History

Get all purchases made.

**Endpoint:** `GET /purchases/history`

**Response:**

```json
{
  "success": true,
  "count": 3,
  "purchases": [
    {
      "buyer": "0x...",
      "seller": "0x...",
      "tokenId": "0",
      "price": "75",
      "timestamp": "2024-03-28T10:05:00Z"
    }
  ]
}
```

---

### 3. Get User Purchase History

Get all purchases made by a specific user.

**Endpoint:** `GET /purchases/user/:address`

**Parameters:**

- `address` (required) - Buyer's wallet address

**Response:**

```json
{
  "success": true,
  "address": "0x...",
  "count": 2,
  "purchases": [
    {
      "buyer": "0x...",
      "seller": "0x...",
      "tokenId": "0",
      "price": "75",
      "timestamp": "2024-03-28T10:05:00Z"
    }
  ]
}
```

---

## Health Check

### Health Status

Check if the API is running.

**Endpoint:** `GET /health`

**Response:**

```json
{
  "status": "ok",
  "timestamp": "2024-03-28T10:00:00Z"
}
```

---

## Error Responses

### Validation Error

```json
{
  "errors": [
    {
      "msg": "Invalid wallet address",
      "param": "buyerAddress",
      "location": "body"
    }
  ]
}
```

### Contract Error

```json
{
  "error": "Failed to buy ticket",
  "details": "Listing is not active"
}
```

### Server Error

```json
{
  "error": "Internal server error",
  "details": "Application specific error message"
}
```

---

## Rate Limiting

No rate limiting is currently implemented. Will be added in production.

---

## Pagination

Pagination is not currently implemented. All results are returned in full.

---

## Price Format

All prices are in MON (Monad tokens) as decimal strings.

- Example: `"75"` = 75 MON
- Can include decimals: `"75.5"` = 75.5 MON

---

## Address Format

All Ethereum addresses must be:

- Valid checksummed addresses (optional)
- 42 characters long (including `0x` prefix)
- Hexadecimal format: `0x[0-9a-fA-F]{40}`

---

## Testing with cURL

### List a ticket

```bash
curl -X POST http://localhost:3000/api/marketplace/list \
  -H "Content-Type: application/json" \
  -d '{
    "sellerAddress": "0x742d35Cc6634C0532925a3b844Bc57e0f988e6db",
    "tokenId": "0",
    "price": "75"
  }'
```

### Buy a ticket

```bash
curl -X POST http://localhost:3000/api/purchases/from-marketplace \
  -H "Content-Type: application/json" \
  -d '{
    "buyerAddress": "0x1234567890123456789012345678901234567890",
    "tokenId": "0",
    "amount": "75"
  }'
```

---

## Integration with Flutter App

The Flutter mobile app should:

1. **Connect user's wallet** using WalletConnect or similar
2. **Call blockchain endpoints** to:
   - Get user's tickets via `GET /api/tickets/user/:address`
   - View marketplace listings via `GET /api/marketplace/transactions`
3. **Sign transactions** with user's wallet:
   - User approves ticket transfer
   - User signs purchase transaction
4. **Backend processes** transaction confirmation and updates state

---

## WebSocket/Real-time Updates (Future)

Currently using HTTP polling. WebSocket support for real-time updates is planned.

---

## Changelog

### v1.0.0 (Current)

- Initial release
- Ticket minting
- Marketplace listing and purchasing
- Purchase history tracking
