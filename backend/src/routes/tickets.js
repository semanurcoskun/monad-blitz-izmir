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
 * POST /api/tickets/mint
 * Mint a new ticket NFT
 */
router.post(
  "/mint",
  [
    body("toAddress").isEthereumAddress().withMessage("Invalid wallet address"),
    body("eventName").isString().notEmpty().withMessage("Event name required"),
    body("eventDate").isString().notEmpty().withMessage("Event date required"),
    body("eventLocation").isString().notEmpty().withMessage("Location required"),
    body("seatInfo").isString().withMessage("Seat info required"),
    body("price").isFloat({ min: 0 }).withMessage("Invalid price"),
  ],
  async (req, res) => {
    try {
      const errors = validationResult(req);
      if (!errors.isEmpty()) {
        return res.status(400).json({ errors: errors.array() });
      }

      const blockchain = await initializeBlockchain();
      const {
        toAddress,
        eventName,
        eventDate,
        eventLocation,
        seatInfo,
        price,
      } = req.body;

      const txHash = await blockchain.mintTicket(
        toAddress,
        eventName,
        eventDate,
        eventLocation,
        seatInfo,
        price
      );

      res.status(201).json({
        success: true,
        message: "Ticket minted successfully",
        transactionHash: txHash,
        ticket: {
          to: toAddress,
          eventName,
          eventDate,
          eventLocation,
          seatInfo,
          price,
        },
      });
    } catch (error) {
      console.error("Minting error:", error);
      res.status(500).json({
        error: "Failed to mint ticket",
        details: error.message,
      });
    }
  }
);

/**
 * GET /api/tickets/user/:address
 * Get all tickets owned by a user
 */
router.get("/user/:address", async (req, res) => {
  try {
    const blockchain = await initializeBlockchain();
    const { address } = req.params;

    if (!address.startsWith("0x") || address.length !== 42) {
      return res.status(400).json({ error: "Invalid address format" });
    }

    const tickets = await blockchain.getUserTickets(address);

    res.json({
      success: true,
      address: address,
      count: tickets.length,
      tickets: tickets,
    });
  } catch (error) {
    console.error("Error fetching user tickets:", error);
    res.status(500).json({
      error: "Failed to fetch user tickets",
      details: error.message,
    });
  }
});

/**
 * GET /api/tickets/:tokenId
 * Get ticket details
 */
router.get("/:tokenId", async (req, res) => {
  try {
    const blockchain = await initializeBlockchain();
    const { tokenId } = req.params;

    if (!Number.isInteger(Number(tokenId))) {
      return res.status(400).json({ error: "Invalid token ID" });
    }

    const ticket = await blockchain.getTicketData(tokenId);

    res.json({
      success: true,
      ticket: ticket,
    });
  } catch (error) {
    console.error("Error fetching ticket:", error);
    res.status(500).json({
      error: "Failed to fetch ticket",
      details: error.message,
    });
  }
});

/**
 * POST /api/tickets/:tokenId/use
 * Mark ticket as used
 */
router.post("/:tokenId/use", async (req, res) => {
  try {
    const blockchain = await initializeBlockchain();
    const { tokenId } = req.params;

    if (!Number.isInteger(Number(tokenId))) {
      return res.status(400).json({ error: "Invalid token ID" });
    }

    const txHash = await blockchain.useTicket(tokenId);

    res.json({
      success: true,
      message: "Ticket marked as used",
      transactionHash: txHash,
      tokenId: tokenId,
    });
  } catch (error) {
    console.error("Error using ticket:", error);
    res.status(500).json({
      error: "Failed to use ticket",
      details: error.message,
    });
  }
});

export default router;
