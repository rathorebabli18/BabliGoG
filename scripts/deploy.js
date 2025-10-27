```javascript
const hre = require("hardhat");

async function main() {
  console.log("🚀 Starting ChainAxis deployment on Core Testnet 2...\n");

  // Get the deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log("📝 Deploying contracts with account:", deployer.address);

  // Get account balance
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("💰 Account balance:", hre.ethers.formatEther(balance), "CORE\n");

  // Deploy the Project contract
  console.log("📦 Deploying Project contract...");
  const Project = await hre.ethers.getContractFactory("Project");
  const project = await Project.deploy();

  await project.waitForDeployment();
  const projectAddress = await project.getAddress();

  console.log("✅ Project contract deployed to:", projectAddress);
  console.log("\n" + "=".repeat(60));
  console.log("🎉 Deployment Summary");
  console.log("=".repeat(60));
  console.log("Contract Name:     Project");
  console.log("Contract Address: ", projectAddress);
  console.log("Network:          ", hre.network.name);
  console.log("Chain ID:         ", hre.network.config.chainId);
  console.log("Deployer:         ", deployer.address);
  console.log("=".repeat(60));

  console.log("\n📋 Next Steps:");
  console.log("1. Save the contract address for frontend integration");
  console.log("2. Verify the contract on block explorer (if available)");
  console.log("3. Test contract functions using Hardhat console or scripts");
  console.log("\n💡 To verify the contract, run:");
  console.log(`npx hardhat verify --network coreTestnet2 ${projectAddress}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Error during deployment:", error);
    process.exit(1);
  });
```