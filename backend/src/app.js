import express from "express";
import cors from "cors";
import helmet from "helmet";
import dotenv from "dotenv";
import purchaseRoutes from "./routes/purchases.js";
import ticketRoutes from "./routes/tickets.js";
import marketplaceRoutes from "./routes/marketplace.js";
import { errorHandler } from "./middleware/errorHandler.js";

dotenv.config();

const app = express();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());

// Health check
app.get("/health", (req, res) => {
  res.json({ status: "ok", timestamp: new Date().toISOString() });
});

// API Routes
app.use("/api/purchases", purchaseRoutes);
app.use("/api/tickets", ticketRoutes);
app.use("/api/marketplace", marketplaceRoutes);

// Error handling
app.use(errorHandler);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: "Route not found" });
});

export default app;
