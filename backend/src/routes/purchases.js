import express from "express";
import { body, validationResult } from "express-validator";
import BlockchainService from "../services/BlockchainService.js";

const router = express.Router();
let blockchainService = null;

function isValidPrivateKey(value) {
  return /^0x[a-fA-F0-9]{64}$/.test(value || "");
}

function isValidAddress(value) {
  return /^0x[a-fA-F0-9]{40}$/.test(value || "");
}

function validateBlockchainEnv() {
  const errors = [];

  if (!isValidPrivateKey(process.env.PRIVATE_KEY)) {
    errors.push("PRIVATE_KEY geçersiz. 0x ile başlayan 64 hex karakter olmalı.");
  }

  if (!isValidAddress(process.env.TICKET_NFT_ADDRESS)) {
    errors.push("TICKET_NFT_ADDRESS geçersiz veya deploy edilmemiş.");
  }

  if (!isValidAddress(process.env.MARKETPLACE_ADDRESS)) {
    errors.push("MARKETPLACE_ADDRESS geçersiz veya deploy edilmemiş.");
  }

  if (errors.length > 0) {
    const err = new Error(errors.join(" "));
    err.statusCode = 503;
    throw err;
  }
}

// Initialize blockchain service on first use
async function initializeBlockchain() {
  if (!blockchainService) {
    validateBlockchainEnv();
    blockchainService = new BlockchainService();
    if (process.env.PRIVATE_KEY) {
      await blockchainService.initializeWithPrivateKey(process.env.PRIVATE_KEY);
    }
  }
  return blockchainService;
}

/**
 * POST /api/purchases/create
 * Create a purchase (buy ticket directly)
 * Body: { buyerAddress, tokenId, price }
 */
router.post(
  "/create",
  [
    body("buyerAddress").isEthereumAddress().withMessage("Invalid wallet address"),
    body("tokenId").isNumeric().withMessage("Invalid token ID"),
    body("price").isFloat({ min: 0 }).withMessage("Invalid price"),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const blockchain = await initializeBlockchain();
      const { buyerAddress, tokenId, price } = req.body;

      // Check listing exists and is active
      const listing = await blockchain.getListing(tokenId);
      if (!listing.active) {
        return res.status(400).json({ error: "Listing is not active" });
      }

      if (parseFloat(listing.price) !== parseFloat(price)) {
        return res
          .status(400)
          .json({ error: "Price mismatch with listing" });
      }

      // Execute purchase
      const txHash = await blockchain.buyTicket(tokenId, price);

      res.json({
        success: true,
        message: "Purchase initiated",
        transactionHash: txHash,
        buyer: buyerAddress,
        tokenId: tokenId,
        price: price,
      });
    } catch (error) {
      console.error("Purchase error:", error);
      res.status(error.statusCode || 500).json({ error: error.message });
    }
  }
);

/**
 * POST /api/purchases/from-marketplace
 * Buy ticket from marketplace
 * Body: { buyerAddress, tokenId, amount (in Monad) }
 */
router.post(
  "/from-marketplace",
  [
    body("buyerAddress").isEthereumAddress().withMessage("Invalid wallet address"),
    body("tokenId").isNumeric().withMessage("Invalid token ID"),
    body("amount").isFloat({ min: 0 }).withMessage("Invalid amount"),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const blockchain = await initializeBlockchain();
      const { buyerAddress, tokenId, amount } = req.body;

      // Get listing to verify
      const listing = await blockchain.getListing(tokenId);

      if (!listing.active) {
        return res.status(400).json({
          error: "Ticket is not listed for sale",
          tokenId,
        });
      }

      if (listing.price !== amount.toString()) {
        return res.status(400).json({
          error: "Amount does not match listing price",
          listedPrice: listing.price,
          providedAmount: amount,
        });
      }

      // Execute purchase on blockchain
      const txHash = await blockchain.buyTicket(tokenId, amount);

      res.json({
        success: true,
        message: "Marketplace purchase completed successfully",
        transactionHash: txHash,
        buyer: buyerAddress,
        tokenId: tokenId,
        amount: amount,
        timestamp: new Date().toISOString(),
      });
    } catch (error) {
      console.error("Marketplace purchase error:", error);
      res.status(error.statusCode || 500).json({
        error: "Purchase failed",
        details: error.message,
      });
    }
  }
);

/**
 * GET /api/purchases/history
 * Get all purchases from marketplace
 */
router.get("/history", async (req, res) => {
  try {
    const blockchain = await initializeBlockchain();
    const history = await blockchain.getPurchaseHistory();

    res.json({
      success: true,
      count: history.length,
      purchases: history,
    });
  } catch (error) {
    console.error("Error fetching purchase history:", error);
    res.status(error.statusCode || 500).json({
      error: "Failed to fetch purchase history",
      details: error.message,
    });
  }
});

/**
 * GET /api/purchases/user/:address
 * Get purchases by a specific user
 */
router.get("/user/:address", async (req, res) => {
  try {
    const blockchain = await initializeBlockchain();
    const { address } = req.params;

    if (!address.startsWith("0x") || address.length !== 42) {
      return res.status(400).json({ error: "Invalid address format" });
    }

    const allHistory = await blockchain.getPurchaseHistory();

    // Filter purchases for this buyer
    const userPurchases = allHistory.filter(
      (p) => p.buyer.toLowerCase() === address.toLowerCase()
    );

    res.json({
      success: true,
      address: address,
      count: userPurchases.length,
      purchases: userPurchases,
    });
  } catch (error) {
    console.error("Error fetching user purchases:", error);
    res.status(error.statusCode || 500).json({
      error: "Failed to fetch user purchases",
      details: error.message,
    });
  }
});

export default router;
