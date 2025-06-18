const hre = require("hardhat");

async function main() {
  const Escrow = await hre.ethers.getContractFactory("AdvancedEscrow");
  const escrow = await Escrow.deploy();

  await escrow.waitForDeployment(); // ✅ This is the correct method now

  console.log(`✅ AdvancedEscrow deployed to: ${escrow.target}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
