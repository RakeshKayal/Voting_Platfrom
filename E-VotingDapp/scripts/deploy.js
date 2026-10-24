// scripts/deploy.js
const hre = require("hardhat");
const fs = require("fs");
const path = require("path");

async function main() {
  // Deploy the contract
  const eVoting = await hre.ethers.getContractFactory("eVoting");
  const eVotings = await eVoting.deploy();
  await eVotings.waitForDeployment();

  const address = await eVotings.getAddress();
  console.log("✅ eVoting deployed to:", address);

  // Path to your React app folder (adjust if needed)
  const frontendDir = path.join(__dirname, "../../client-frontend/src/Contract");

  // Ensure the folder exists
  if (!fs.existsSync(frontendDir)) {
    fs.mkdirSync(frontendDir, { recursive: true });
  }

  // Save the contract address
  const addressPath = path.join(frontendDir, "contract-address.json");
  fs.writeFileSync(addressPath, JSON.stringify({ address }, null, 2));

  console.log("✅ Contract address saved to:", addressPath);

  // Copy the ABI (interface)
  const artifact = await hre.artifacts.readArtifact("eVoting");
  const abiPath = path.join(frontendDir, "eVoting.json");
  fs.writeFileSync(abiPath, JSON.stringify(artifact, null, 2));

  console.log("✅ ABI saved to:", abiPath);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
