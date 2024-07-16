const { expect } = require("chai");
//const { ethers } = require("hardhat");

describe("VestingContract", function () {
  let VestingContract, vestingContract, Token, token, owner, addr1, addr2;

  beforeEach(async function () {
    [owner, addr1, addr2] = await ethers.getSigners();

    // Ensure the imports and ethers object are correct
    expect(ethers.utils).to.be.an('object');
    expect(ethers.utils.parseEther).to.be.a('function');

    Token = await ethers.getContractFactory("Token");
    token = await Token.deploy(ethers.utils.parseEther("1000000"));
    await token.deployed();

    VestingContract = await ethers.getContractFactory("VestingContract");
    vestingContract = await VestingContract.deploy(token.address);
    await vestingContract.deployed();

    // Transfer tokens to the vesting contract
    await token.transfer(vestingContract.address, ethers.utils.parseEther("1000000"));
  });

  it("Should set the right owner", async function () {
    expect(await vestingContract.owner()).to.equal(owner.address);
  });

  it("Should allow owner to start vesting", async function () {
    await vestingContract.startVesting();
    expect(await vestingContract.vestingStarted()).to.equal(true);
  });

  it("Should allow owner to add beneficiary before vesting starts", async function () {
    await vestingContract.addBeneficiary(addr1.address, 0, ethers.utils.parseEther("1000"));
    const schedule = await vestingContract.vestingSchedules(addr1.address, 0);
    expect(schedule.totalAllocation).to.equal(ethers.utils.parseEther("1000"));
  });

  it("Should not allow adding beneficiary after vesting starts", async function () {
    await vestingContract.startVesting();
    await expect(vestingContract.addBeneficiary(addr1.address, 0, ethers.utils.parseEther("1000")))
      .to.be.revertedWith("Vesting has already started");
  });

  it("Should calculate vested amount correctly", async function () {
    await vestingContract.addBeneficiary(addr1.address, 0, ethers.utils.parseEther("1000"));
    await vestingContract.startVesting();

    // Increase time by 1 year
    await ethers.provider.send("evm_increaseTime", [365 * 24 * 60 * 60]);
    await ethers.provider.send("evm_mine");

    const vestedAmount = await vestingContract.calculateVestedAmount(addr1.address, 0);
    expect(vestedAmount).to.equal(ethers.utils.parseEther("500")); // 50% after 1 year for User role
  });

  it("Should allow beneficiary to claim tokens", async function () {
    await vestingContract.addBeneficiary(addr1.address, 0, ethers.utils.parseEther("1000"));
    await vestingContract.startVesting();

    // Increase time by 1 year
    await ethers.provider.send("evm_increaseTime", [365 * 24 * 60 * 60]);
    await ethers.provider.send("evm_mine");

    await vestingContract.connect(addr1).claimTokens(0);
    const balance = await token.balanceOf(addr1.address);
    expect(balance).to.equal(ethers.utils.parseEther("500"));
  });
});
