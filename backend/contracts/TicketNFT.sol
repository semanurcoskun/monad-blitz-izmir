// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title TicketNFT
 * @dev NFT contract for event tickets on Monad blockchain
 */
contract TicketNFT is ERC721, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    struct TicketMetadata {
        string eventName;
        string eventDate;
        string eventLocation;
        string seatInfo;
        uint256 price;
        uint256 purchaseTimestamp;
        bool used;
    }

    mapping(uint256 => TicketMetadata) public ticketData;
    mapping(address => uint256[]) public ownerTickets;

    event TicketMinted(
        address indexed to,
        uint256 indexed tokenId,
        string eventName,
        uint256 price
    );

    event TicketUsed(uint256 indexed tokenId);

    constructor() ERC721("MonadTicket", "MNDT") {}

    /**
     * @dev Mint a new ticket NFT
     */
    function mintTicket(
        address to,
        string memory eventName,
        string memory eventDate,
        string memory eventLocation,
        string memory seatInfo,
        uint256 price
    ) public onlyOwner returns (uint256) {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(to, tokenId);

        ticketData[tokenId] = TicketMetadata({
            eventName: eventName,
            eventDate: eventDate,
            eventLocation: eventLocation,
            seatInfo: seatInfo,
            price: price,
            purchaseTimestamp: block.timestamp,
            used: false
        });

        ownerTickets[to].push(tokenId);

        emit TicketMinted(to, tokenId, eventName, price);

        return tokenId;
    }

    /**
     * @dev Mark ticket as used
     */
    function useTicket(uint256 tokenId) public {
        require(ownerOf(tokenId) == msg.sender, "Not ticket owner");
        require(!ticketData[tokenId].used, "Ticket already used");

        ticketData[tokenId].used = true;
        emit TicketUsed(tokenId);
    }

    /**
     * @dev Get all tickets owned by an address
     */
    function getOwnerTickets(address owner) public view returns (uint256[] memory) {
        return ownerTickets[owner];
    }

    /**
     * @dev Get ticket metadata
     */
    function getTicketData(uint256 tokenId) public view returns (TicketMetadata memory) {
        require(_exists(tokenId), "Token does not exist");
        return ticketData[tokenId];
    }

    /**
     * @dev Override _update to track ownership changes
     */
    function _update(address to, uint256 tokenId, address auth) internal override returns (address) {
        address previousOwner = super._update(to, tokenId, auth);

        if (previousOwner != address(0) && to != address(0)) {
            // Remove from old owner
            uint256[] storage oldTickets = ownerTickets[previousOwner];
            for (uint256 i = 0; i < oldTickets.length; i++) {
                if (oldTickets[i] == tokenId) {
                    oldTickets[i] = oldTickets[oldTickets.length - 1];
                    oldTickets.pop();
                    break;
                }
            }

            // Add to new owner
            ownerTickets[to].push(tokenId);
        }

        return previousOwner;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
