import "@nomicfoundation/hardhat-ethers";
import { ethers } from "hardhat";

describe("TestGas", () => {
  it("test gas", async () => {
    const [owner] = await ethers.getSigners();

    const USDC = await ethers.getContractFactory("USDC");
    const usdc = await USDC.deploy();
    await usdc.waitForDeployment();

    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy(await usdc.getAddress(), "https://xxx/");

    await nft.waitForDeployment();
    await nft.setStateOpen(true);
    await nft.setReleaseTime(0, 0);
    await nft.setReleaseTime(1, 0);
    await nft.setReleaseTime(2, 0);
    for (let i = 0; i < 10; ++i) {
      await usdc.mint(owner.address, BigInt("30000000000000000000000"));
      await usdc.approveByAdmin(
        owner.address,
        await nft.getAddress(),
        BigInt("30000000000000000000000")
      );
      await nft.deposit(BigInt("300000000000000000000"));
      await nft.withdraw(i);
    }
  });
});
