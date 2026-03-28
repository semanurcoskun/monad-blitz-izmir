// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./TicketNFT.sol";

/**
 * @title TicketMarketplace
 * @dev Marketplace for buying and selling tickets using Monad
 */
contract TicketMarketplace {
    TicketNFT public ticketNFT;
    address public owner;
    uint256 public platformFeePercentage = 5; // 5% fee

    struct Listing {
        address seller;
        uint256 price;
        bool active;
    }

    struct Purchase {
        address buyer;
        address seller;
        uint256 tokenId;
        uint256 price;
        uint256 timestamp;
    }

    mapping(uint256 => Listing) public listings;
    Purchase[] public purchaseHistory;

    event ListingCreated(uint256 indexed tokenId, address indexed seller, uint256 price);
    event ListingCancelled(uint256 indexed tokenId);
    event TicketPurchased(
        uint256 indexed tokenId,
        address indexed buyer,
        address indexed seller,
        uint256 price
    );
    event PlatformFeeUpdated(uint256 newFeePercentage);

    constructor(address _ticketNFT) {
        ticketNFT = TicketNFT(_ticketNFT);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this");
        _;
    }

    /**
     * @dev List a ticket for sale
     */
    function listTicket(uint256 tokenId, uint256 price) public {
        require(ticketNFT.ownerOf(tokenId) == msg.sender, "Not ticket owner");
        require(price > 0, "Price must be greater than 0");
        require(!listings[tokenId].active, "Ticket already listed");

        listings[tokenId] = Listing({
            seller: msg.sender,
            price: price,
            active: true
        });

        emit ListingCreated(tokenId, msg.sender, price);
    }

    /**
     * @dev Cancel a listing
     */
    function cancelListing(uint256 tokenId) public {
        require(listings[tokenId].seller == msg.sender, "Not listing seller");
        require(listings[tokenId].active, "Listing not active");

        listings[tokenId].active = false;
        emit ListingCancelled(tokenId);
    }

    /**
     * @dev Buy a ticket with Monad
     */
    function buyTicket(uint256 tokenId) public payable {
        Listing memory listing = listings[tokenId];
        require(listing.active, "Ticket not listed");
        require(msg.value >= listing.price, "Insufficient payment");

        address seller = listing.seller;
        require(seller != msg.sender, "Cannot buy own ticket");

        // Transfer NFT to buyer
        ticketNFT.transferFrom(seller, msg.sender, tokenId);

        // Calculate fees
        uint256 platformFee = (listing.price * platformFeePercentage) / 100;
        uint256 sellerAmount = listing.price - platformFee;

        // Transfer funds
        (bool sellerSuccess, ) = payable(seller).call{value: sellerAmount}("");
        require(sellerSuccess, "Seller payment failed");

        (bool ownerSuccess, ) = payable(owner).call{value: platformFee}("");
        require(ownerSuccess, "Platform fee transfer failed");

        // Refund excess payment
        if (msg.value > listing.price) {
            (bool refundSuccess, ) = payable(msg.sender).call{
                value: msg.value - listing.price
            }("");
            require(refundSuccess, "Refund failed");
        }

        // Record purchase
        purchaseHistory.push(
            Purchase({
                buyer: msg.sender,
                seller: seller,
                tokenId: tokenId,
                price: listing.price,
                timestamp: block.timestamp
            })
        );

        // Deactivate listing
        listings[tokenId].active = false;

        emit TicketPurchased(tokenId, msg.sender, seller, listing.price);
    }

    /**
     * @dev Get listing information
     */
    function getListing(uint256 tokenId) public view returns (Listing memory) {
        return listings[tokenId];
    }

    /**
     * @dev Get purchase history
     */
    function getPurchaseHistory() public view returns (Purchase[] memory) {
        return purchaseHistory;
    }

    /**
     * @dev Update platform fee
     */
    function setPlatformFeePercentage(uint256 newFeePercentage) public onlyOwner {
        require(newFeePercentage <= 25, "Fee too high");
        platformFeePercentage = newFeePercentage;
        emit PlatformFeeUpdated(newFeePercentage);
    }

    /**
     * @dev Withdraw collected fees
     */
    function withdrawFees() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No fees to withdraw");
        (bool success, ) = payable(owner).call{value: balance}("");
        require(success, "Withdrawal failed");
    }

    receive() external payable {}
}
