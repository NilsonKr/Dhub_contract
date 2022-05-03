import { expect } from "chai";
import { ethers } from "hardhat";

import { UserInfo } from "../types";

describe("Dhub", function () {
  const USER_NAME = "NilsonKr";
  const USER_PROFILE_URL = "https://someurl/image.png";

  const setup = async () => {
    const [owner] = await ethers.getSigners();
    const DhubContract = await ethers.getContractFactory("Dhub");
    const deploy = await DhubContract.deploy();

    return { owner, deploy };
  };

  it("Check contract is deployed correctly", async function () {
    const { owner, deploy } = await setup();
    const user = await deploy.users(owner.address);

    expect(user.name).to.be.empty;
  });

  it("Creates an user correctly", async function () {
    const { deploy } = await setup();
    await deploy.register(USER_NAME, USER_PROFILE_URL);

    const user: UserInfo = await deploy.login();

    expect(user).to.does.not.be.undefined;
    expect(user.name).to.be.equals(USER_NAME);
    expect(user.profileUrl).to.be.equals(USER_PROFILE_URL);
  });

  it("Succesfully edit a user", async function () {
    const { deploy } = await setup();
    await deploy.register(USER_NAME, USER_PROFILE_URL);
    //New constants
    const newName = "Rosie";
    const newUrl = "https://hello.com/newProfilePic.png";
    //Edit actions
    await deploy.editUser("name", newName);
    await deploy.editUser("profileUrl", newUrl);

    const user: UserInfo = await deploy.login();

    expect(user.name).to.be.equals(newName);
    expect(user.profileUrl).to.be.equals(newUrl);
  });
});
