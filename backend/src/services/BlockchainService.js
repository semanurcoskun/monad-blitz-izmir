import { ethers } from "ethers";
import dotenv from "dotenv";

dotenv.config();

const TICKET_NFT_ABI = [
  "function mintTicket(address to, string memory eventName, string memory eventDate, string memory eventLocation, string memory seatInfo, uint256 price) public returns (uint256)",
  "function ownerOf(uint256 tokenId) public view returns (address)",
  "function getOwnerTickets(address owner) public view returns (uint256[])",
  "function getTicketData(uint256 tokenId) public view returns (tuple(string eventName, string eventDate, string eventLocation, string seatInfo, uint256 price, uint256 purchaseTimestamp, bool used))",
  "function transferFrom(address from, address to, uint256 tokenId) public",
  "function useTicket(uint256 tokenId) public",
];

const MARKETPLACE_ABI = [
  "function listTicket(uint256 tokenId, uint256 price) public",
  "function buyTicket(uint256 tokenId) public payable",
  "function cancelListing(uint256 tokenId) public",
  "function getListing(uint256 tokenId) public view returns (tuple(address seller, uint256 price, bool active))",
  "function getPurchaseHistory() public view returns (tuple(address buyer, address seller, uint256 tokenId, uint256 price, uint256 timestamp)[])",
  "function setPlatformFeePercentage(uint256 newFeePercentage) public",
];

class BlockchainService {
  constructor() {
    this.provider = new ethers.JsonRpcProvider(
      process.env.MONAD_RPC_URL || "https://testnet-rpc.monad.xyz/"
    );
    this.signer = null;
    this.ticketNFT = null;
    this.marketplace = null;
  }

  /**
   * Initialize with private key
   */
  async initializeWithPrivateKey(privateKey) {
    this.signer = new ethers.Wallet(privateKey, this.provider);
    this.initializeContracts();
  }

  /**
   * Initialize contract instances
   */
  initializeContracts() {
    if (!this.signer) {
      throw new Error("Signer not initialized");
    }

    this.ticketNFT = new ethers.Contract(
      process.env.TICKET_NFT_ADDRESS,
      TICKET_NFT_ABI,
      this.signer
    );

    this.marketplace = new ethers.Contract(
      process.env.MARKETPLACE_ADDRESS,
      MARKETPLACE_ABI,
      this.signer
    );
  }

  /**
   * Get wallet balance
   */
  async getBalance(address) {
    const balance = await this.provider.getBalance(address);
    return ethers.formatEther(balance);
  }

  /**
   * Mint a new ticket NFT
   */
  async mintTicket(toAddress, eventName, eventDate, eventLocation, seatInfo, price) {
    try {
      const tx = await this.ticketNFT.mintTicket(
        toAddress,
        eventName,
        eventDate,
        eventLocation,
        seatInfo,
        ethers.parseEther(price.toString())
      );

      const receipt = await tx.wait();
      console.log("Ticket minted:", receipt.hash);
      return receipt.hash;
    } catch (error) {
      console.error("Error minting ticket:", error);
      throw error;
    }
  }

  /**
   * Get user's tickets
   */
  async getUserTickets(address) {
    try {
      const tokenIds = await this.ticketNFT.getOwnerTickets(address);
      const tickets = [];

      for (const tokenId of tokenIds) {
        const data = await this.ticketNFT.getTicketData(tokenId);
        tickets.push({
          tokenId: tokenId.toString(),
          ...data,
          price: ethers.formatEther(data.price),
        });
      }

      return tickets;
    } catch (error) {
      console.error("Error fetching user tickets:", error);
      throw error;
    }
  }

  /**
   * Get single ticket data
   */
  async getTicketData(tokenId) {
    try {
      const data = await this.ticketNFT.getTicketData(tokenId);
      return {
        tokenId: tokenId.toString(),
        ...data,
        price: ethers.formatEther(data.price),
      };
    } catch (error) {
      console.error("Error fetching ticket data:", error);
      throw error;
    }
  }

  /**
   * List ticket for sale
   */
  async listTicket(tokenId, priceInEther) {
    try {
      const tx = await this.marketplace.listTicket(
        tokenId,
        ethers.parseEther(priceInEther.toString())
      );

      const receipt = await tx.wait();
      console.log("Ticket listed:", receipt.hash);
      return receipt.hash;
    } catch (error) {
      console.error("Error listing ticket:", error);
      throw error;
    }
  }

  /**
   * Buy a ticket from marketplace
   */
  async buyTicket(tokenId, priceInEther) {
    try {
      const tx = await this.marketplace.buyTicket(tokenId, {
        value: ethers.parseEther(priceInEther.toString()),
      });

      const receipt = await tx.wait();
      console.log("Ticket purchased:", receipt.hash);
      return receipt.hash;
    } catch (error) {
      console.error("Error buying ticket:", error);
      throw error;
    }
  }

  /**
   * Cancel a listing
   */
  async cancelListing(tokenId) {
    try {
      const tx = await this.marketplace.cancelListing(tokenId);
      const receipt = await tx.wait();
      console.log("Listing cancelled:", receipt.hash);
      return receipt.hash;
    } catch (error) {
      console.error("Error cancelling listing:", error);
      throw error;
    }
  }

  /**
   * Get listing information
   */
  async getListing(tokenId) {
    try {
      const listing = await this.marketplace.getListing(tokenId);
      return {
        seller: listing[0],
        price: ethers.formatEther(listing[1]),
        active: listing[2],
      };
    } catch (error) {
      console.error("Error fetching listing:", error);
      throw error;
    }
  }

  /**
   * Get purchase history
   */
  async getPurchaseHistory() {
    try {
      const history = await this.marketplace.getPurchaseHistory();
      return history.map((purchase) => ({
        buyer: purchase[0],
        seller: purchase[1],
        tokenId: purchase[2].toString(),
        price: ethers.formatEther(purchase[3]),
        timestamp: new Date(Number(purchase[4]) * 1000),
      }));
    } catch (error) {
      console.error("Error fetching purchase history:", error);
      throw error;
    }
  }

  /**
   * Use a ticket (mark as used)
   */
  async useTicket(tokenId) {
    try {
      const tx = await this.ticketNFT.useTicket(tokenId);
      const receipt = await tx.wait();
      console.log("Ticket used:", receipt.hash);
      return receipt.hash;
    } catch (error) {
      console.error("Error using ticket:", error);
      throw error;
    }
  }
}

export default BlockchainService;
