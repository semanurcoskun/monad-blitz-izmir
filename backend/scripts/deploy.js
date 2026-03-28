const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  console.log("🚀 Deploying Monad Ticket System...\n");

  // Get deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log("📝 Deploying contracts with account:", deployer.address);

  // Check balance
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("💰 Account balance:", hre.ethers.formatEther(balance), "MON\n");

  // Deploy TicketNFT
  console.log("🎫 Deploying TicketNFT...");
  const TicketNFT = await hre.ethers.getContractFactory("TicketNFT");
  const ticketNFT = await TicketNFT.deploy();
  await ticketNFT.waitForDeployment();
  const ticketNFTAddress = await ticketNFT.getAddress();
  console.log("✅ TicketNFT deployed to:", ticketNFTAddress);

  // Deploy TicketMarketplace
  console.log("\n🏪 Deploying TicketMarketplace...");
  const TicketMarketplace = await hre.ethers.getContractFactory("TicketMarketplace");
  const marketplace = await TicketMarketplace.deploy(ticketNFTAddress);
  await marketplace.waitForDeployment();
  const marketplaceAddress = await marketplace.getAddress();
  console.log("✅ TicketMarketplace deployed to:", marketplaceAddress);

  // Save deployment info
  const deploymentInfo = {
    network: hre.network.name,
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    contracts: {
      TicketNFT: {
        address: ticketNFTAddress,
        transaction: ticketNFT.deploymentTransaction?.hash,
      },
      TicketMarketplace: {
        address: marketplaceAddress,
        transaction: marketplace.deploymentTransaction?.hash,
      },
    },
  };

  const deploymentPath = path.join(__dirname, "..", "deployments.json");
  fs.writeFileSync(deploymentPath, JSON.stringify(deploymentInfo, null, 2));
  console.log("\n📄 Deployment info saved to:", deploymentPath);

  // Update .env file
  const envPath = path.join(__dirname, "..", ".env");
  let envContent = fs.existsSync(envPath) ? fs.readFileSync(envPath, "utf8") : "";

  envContent = envContent.replace(
    /TICKET_NFT_ADDRESS=.*/,
    `TICKET_NFT_ADDRESS=${ticketNFTAddress}`
  );
  if (!envContent.includes("TICKET_NFT_ADDRESS")) {
    envContent += `\nTICKET_NFT_ADDRESS=${ticketNFTAddress}`;
  }

  envContent = envContent.replace(
    /MARKETPLACE_ADDRESS=.*/,
    `MARKETPLACE_ADDRESS=${marketplaceAddress}`
  );
  if (!envContent.includes("MARKETPLACE_ADDRESS")) {
    envContent += `\nMARKETPLACE_ADDRESS=${marketplaceAddress}`;
  }

  fs.writeFileSync(envPath, envContent);

  console.log("\n✨ Deployment completed successfully!");
  console.log("\nContract Addresses:");
  console.log("- TicketNFT:", ticketNFTAddress);
  console.log("- TicketMarketplace:", marketplaceAddress);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
