import { expect } from "chai";
import { ethers } from "hardhat";

describe("Dhub", function () {
  const setup = async () => {
    const [owner] = await ethers.getSigners()
    const DhubContract = await ethers.getContractFactory('Dhub');
    const deploy = await DhubContract.deploy();
    
    return {owner, deploy }
  } 

  it("Check contract is deployed correctly", async function () {
    const {owner,deploy} = await setup();
    const user = await deploy.users(owner.address);

    expect(user.name).to.be.empty;
  });
});
