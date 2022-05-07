import { expect } from "chai";
import { ethers } from "hardhat";

import { Dhub } from "../typechain";
import { UserInfo, FileInfo } from "../types";

describe("Dhub", function () {
  const USER_NAME = "NilsonKr";
  const USER_PROFILE_URL = "https://someurl/image.png";
  const DUMMIE_FILE = {
    id: 0,
    url: "someurl",
    title: "Pic",
    description: "desc",
    uploadDate: new Date().toDateString(),
    size: 1000,
  };

  const setup = async () => {
    const [owner] = await ethers.getSigners();
    const DhubContract = await ethers.getContractFactory("Dhub");
    const deploy = await DhubContract.deploy();

    return { owner, deploy };
  };

  const register = async (
    deploy: Dhub,
    name: string = USER_NAME,
    url: string = USER_PROFILE_URL
  ): Promise<UserInfo> => {
    await deploy.register(name, url);

    const user: UserInfo = await deploy.login();

    return user;
  };

  const uploadFile = async (deploy: Dhub, data: FileInfo) => {
    const recenteFile = await deploy.uploadFile(data);

    const events = await recenteFile.wait();
    const uploadEvent = events.events?.find(
      (event) => event.event === "Upload"
    );

    const file = await deploy.getFileByPosition(uploadEvent?.args?.file.id - 1);

    return file;
  };

  describe("Contract deployment", function () {
    it("Check contract is deployed correctly", async function () {
      const { owner, deploy } = await setup();
      const user = await deploy.users(owner.address);

      expect(user.name).to.be.empty;
    });
  });

  describe("User related stuff", function () {
    it("Creates an user correctly", async function () {
      const { deploy } = await setup();
      const user = await register(deploy);

      expect(user).to.does.not.be.undefined;
      expect(user.name).to.be.equals(USER_NAME);
      expect(user.profileUrl).to.be.equals(USER_PROFILE_URL);
    });

    it("Creates multiple user correctly", async function () {
      const { deploy } = await setup();
      const [_, otherAccount] = await ethers.getSigners();
      await deploy
        .connect(otherAccount)
        .register("OtherAccount", "someurl.png");

      const otherUser: UserInfo = await deploy.connect(otherAccount).login();

      expect(otherUser).to.does.not.be.undefined;
      expect(otherUser.name).to.be.equals("OtherAccount");
      expect(otherUser.profileUrl).to.be.equals("someurl.png");
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

  describe("Files related stuff", function () {
    it("Check initial files", async function () {
      const { deploy } = await setup();
      await register(deploy);

      const files = await deploy.getFilesByUser();

      expect(files).to.be.empty;
    });

    it("Correctly file upload", async function () {
      const { deploy } = await setup();
      await register(deploy);

      const recentFile = await uploadFile(deploy, DUMMIE_FILE);

      const files = await deploy.getFilesByUser();

      expect(files).to.have.lengthOf(1);
      expect(recentFile.id).to.be.equals(1);
      expect(recentFile.title).to.be.equals("Pic");
    });

    it("Upload multiple files", async function () {
      const { deploy } = await setup();
      await register(deploy);

      const firstFile = await uploadFile(deploy, DUMMIE_FILE);
      const secondFile = await uploadFile(deploy, {
        ...DUMMIE_FILE,
        title: "Hey",
      });

      const files = await deploy.getFilesByUser();

      expect(files).to.have.lengthOf(2);

      expect(firstFile.id).to.be.equals(1);
      expect(secondFile.id).to.be.equals(2);

      expect(secondFile.title === firstFile.title).to.be.false;
    });

    it("Edit file", async function () {
      const { deploy } = await setup();
      await register(deploy);

      const oldFile = await uploadFile(deploy, DUMMIE_FILE);
      const newTitle = "New title";

      await deploy.editFile(oldFile.id - 1, newTitle, "");

      const newFile = await deploy.getFileByPosition(oldFile.id - 1);

      expect(newFile.title).to.be.equals(newTitle);
      expect(newFile.description).to.be.equals(oldFile.description);
    });
  });
});
