import express from "express";
import { body, validationResult } from "express-validator";
import BlockchainService from "../services/BlockchainService.js";

const router = express.Router();
let blockchainService = null;

// Initialize blockchain service on first use
async function initializeBlockchain() {
  if (!blockchainService) {
    blockchainService = new BlockchainService();
    if (process.env.PRIVATE_KEY) {
      await blockchainService.initializeWithPrivateKey(process.env.PRIVATE_KEY);
    }
  }
  return blockchainService;
}

/**
 * POST /api/marketplace/list
 * List a ticket for sale
 */
router.post(
  "/list",
  [
    body("sellerAddress").isEthereumAddress().withMessage("Invalid seller address"),
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
      const { sellerAddress, tokenId, price } = req.body;

      // List ticket on marketplace
      const txHash = await blockchain.listTicket(tokenId, price);

      res.status(201).json({
        success: true,
        message: "Ticket listed successfully",
        transactionHash: txHash,
        listing: {
          tokenId: tokenId,
          seller: sellerAddress,
          price: price,
          listedAt: new Date().toISOString(),
        },
      });
    } catch (error) {
      console.error("Listing error:", error);
      res.status(500).json({
        error: "Failed to list ticket",
        details: error.message,
      });
    }
  }
);

/**
 * GET /api/marketplace/listing/:tokenId
 * Get listing details
 */
router.get("/listing/:tokenId", async (req, res) => {
  try {
    const blockchain = await initializeBlockchain();
    const { tokenId } = req.params;

    if (!Number.isInteger(Number(tokenId))) {
      return res.status(400).json({ error: "Invalid token ID" });
    }

    const listing = await blockchain.getListing(tokenId);

    if (!listing.active) {
      return res.status(404).json({
        error: "Listing not found or inactive",
        tokenId,
      });
    }

    res.json({
      success: true,
      tokenId: tokenId,
      listing: listing,
    });
  } catch (error) {
    console.error("Error fetching listing:", error);
    res.status(500).json({
      error: "Failed to fetch listing",
      details: error.message,
    });
  }
});

/**
 * POST /api/marketplace/cancel/:tokenId
 * Cancel a listing
 */
router.post("/cancel/:tokenId", async (req, res) => {
  try {
    const blockchain = await initializeBlockchain();
    const { tokenId } = req.params;

    if (!Number.isInteger(Number(tokenId))) {
      return res.status(400).json({ error: "Invalid token ID" });
    }

    const txHash = await blockchain.cancelListing(tokenId);

    res.json({
      success: true,
      message: "Listing cancelled successfully",
      transactionHash: txHash,
      tokenId: tokenId,
    });
  } catch (error) {
    console.error("Error cancelling listing:", error);
    res.status(500).json({
      error: "Failed to cancel listing",
      details: error.message,
    });
  }
});

/**
 * GET /api/marketplace/listings/seller/:address
 * Get all listings by a seller
 */
router.get("/listings/seller/:address", async (req, res) => {
  try {
    const blockchain = await initializeBlockchain();
    const { address } = req.params;

    if (!address.startsWith("0x") || address.length !== 42) {
      return res.status(400).json({ error: "Invalid address format" });
    }

    const history = await blockchain.getPurchaseHistory();
    const sellerTickets = await blockchain.getUserTickets(address);

    // Get active listings from user's tickets
    const activeListings = [];
    for (const ticket of sellerTickets) {
      const listing = await blockchain.getListing(ticket.tokenId);
      if (listing.active) {
        activeListings.push({
          tokenId: ticket.tokenId,
          ...ticket,
          listingPrice: listing.price,
        });
      }
    }

    res.json({
      success: true,
      seller: address,
      count: activeListings.length,
      listings: activeListings,
    });
  } catch (error) {
    console.error("Error fetching seller listings:", error);
    res.status(500).json({
      error: "Failed to fetch seller listings",
      details: error.message,
    });
  }
});

/**
 * GET /api/marketplace/transactions
 * Get all marketplace transactions
 */
router.get("/transactions", async (req, res) => {
  try {
    const blockchain = await initializeBlockchain();
    const transactions = await blockchain.getPurchaseHistory();

    res.json({
      success: true,
      count: transactions.length,
      transactions: transactions,
    });
  } catch (error) {
    console.error("Error fetching transactions:", error);
    res.status(500).json({
      error: "Failed to fetch transactions",
      details: error.message,
    });
  }
});

export default router;
