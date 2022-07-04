// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const Binagorians = await hre.ethers.getContractFactory("Binagorians");
  const binagorians = await Binagorians.deploy();

  await binagorians.deployed();

  console.log("Binagorians deployed to:", binagorians.address);

  await binagorians.create("0x7eD249bA0fcE2749AcC69dEff7B7c27caB2b1d1a", 123, "Ema", 20);
  await binagorians.create("0x3C44CdDdB6a900fa2b585dd299e03d12FA4293BC", 123, "Mati", 30);
  await binagorians.create("0x70997970C51812dc3A010C7d01b50e0d17dc79C8", 1232233, "Fer", 40);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
