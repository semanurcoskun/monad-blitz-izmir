const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Monad Ticket System", function () {
  let ticketNFT;
  let marketplace;
  let owner;
  let seller;
  let buyer;

  before(async function () {
    [owner, seller, buyer] = await ethers.getSigners();

    // Deploy TicketNFT
    const TicketNFT = await ethers.getContractFactory("TicketNFT");
    ticketNFT = await TicketNFT.deploy();
    await ticketNFT.waitForDeployment();

    // Deploy Marketplace
    const TicketMarketplace = await ethers.getContractFactory("TicketMarketplace");
    const ticketNFTAddress = await ticketNFT.getAddress();
    marketplace = await TicketMarketplace.deploy(ticketNFTAddress);
    await marketplace.waitForDeployment();
  });

  describe("TicketNFT", function () {
    it("Should mint a ticket", async function () {
      const tx = await ticketNFT.mintTicket(
        seller.address,
        "Concert 2024",
        "2024-12-25",
        "Istanbul Arena",
        "Section A, Row 5",
        ethers.parseEther("50")
      );

      const receipt = await tx.wait();
      expect(receipt).to.exist;

      const tickets = await ticketNFT.getOwnerTickets(seller.address);
      expect(tickets.length).to.equal(1);
    });

    it("Should get ticket metadata", async function () {
      const tickets = await ticketNFT.getOwnerTickets(seller.address);
      const tokenId = tickets[0];

      const ticketData = await ticketNFT.getTicketData(tokenId);
      expect(ticketData.eventName).to.equal("Concert 2024");
      expect(ticketData.eventLocation).to.equal("Istanbul Arena");
    });

    it("Should mark ticket as used", async function () {
      const tickets = await ticketNFT.getOwnerTickets(seller.address);
      const tokenId = tickets[0];

      const tx = await ticketNFT.connect(seller).useTicket(tokenId);
      expect(tx).to.exist;

      const ticketData = await ticketNFT.getTicketData(tokenId);
      expect(ticketData.used).to.be.true;
    });
  });

  describe("TicketMarketplace", function () {
    before(async function () {
      // Mint a ticket for marketplace testing
      await ticketNFT.mintTicket(
        seller.address,
        "Concert 2024",
        "2024-12-25",
        "Istanbul Arena",
        "Section B, Row 10",
        ethers.parseEther("75")
      );

      // Approve marketplace to transfer token
      const tickets = await ticketNFT.getOwnerTickets(seller.address);
      const tokenId = tickets[tickets.length - 1];
      await ticketNFT.connect(seller).approve(await marketplace.getAddress(), tokenId);
    });

    it("Should list a ticket", async function () {
      const tickets = await ticketNFT.getOwnerTickets(seller.address);
      const tokenId = tickets[tickets.length - 1];

      const tx = await marketplace
        .connect(seller)
        .listTicket(tokenId, ethers.parseEther("75"));

      expect(tx).to.exist;

      const listing = await marketplace.getListing(tokenId);
      expect(listing.active).to.be.true;
    });

    it("Should buy a ticket", async function () {
      const tickets = await ticketNFT.getOwnerTickets(seller.address);
      const tokenId = tickets[tickets.length - 1];

      const price = ethers.parseEther("75");
      const tx = await marketplace.connect(buyer).buyTicket(tokenId, {
        value: price,
      });

      expect(tx).to.exist;

      const owner = await ticketNFT.ownerOf(tokenId);
      expect(owner).to.equal(buyer.address);
    });

    it("Should cancel a listing", async function () {
      // Create a new listing
      await ticketNFT.mintTicket(
        seller.address,
        "Concert 2024",
        "2024-12-25",
        "Istanbul Arena",
        "Section C, Row 15",
        ethers.parseEther("100")
      );

      const tickets = await ticketNFT.getOwnerTickets(seller.address);
      const tokenId = tickets[tickets.length - 1];

      await ticketNFT.connect(seller).approve(await marketplace.getAddress(), tokenId);
      await marketplace
        .connect(seller)
        .listTicket(tokenId, ethers.parseEther("100"));

      // Cancel the listing
      const tx = await marketplace.connect(seller).cancelListing(tokenId);
      expect(tx).to.exist;

      const listing = await marketplace.getListing(tokenId);
      expect(listing.active).to.be.false;
    });

    it("Should track purchase history", async function () {
      const history = await marketplace.getPurchaseHistory();
      expect(history.length).to.be.greaterThan(0);
    });
  });
});
