//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Dhub {
  struct User {
    string name;
    string profileUrl;
  }    

  struct UserFile { 
   uint8 id;
   string url;
   string title;
   string uploadDate;
   uint256 size;
  }

  mapping (address => User) public users;
  mapping (address => UserFile[]) public filesByUser;

  function login () external view returns(User memory){
    User memory user = users[msg.sender];
    require(bytes(user.name).length > 0, "User not found");

    return user;
  }

  function register (string memory name, string memory profileUrl) external {
    require(bytes(name).length > 0, "Name is required");
    require(bytes(profileUrl).length > 0, "Profile url is required");

    User memory user = users[msg.sender];
    require(bytes(user.name).length == 0, "User already exists");

    users[msg.sender] = User(name, profileUrl);
  }


  function editUser (string memory field, string memory value) external{ 
    User storage user = users[msg.sender];

    require(bytes(user.name).length > 0, "User not found");
    bytes32 fieldToCompare = keccak256(abi.encodePacked(field));

    if(fieldToCompare == keccak256(abi.encodePacked("name"))){
      require(bytes(value).length > 0, "Name is required");
      user.name = value;

    } else if(fieldToCompare == keccak256(abi.encodePacked("profileUrl"))){
      require(bytes(value).length > 0, "Profile url is required");
      user.profileUrl = value;

    } else {
      require(false, "Field not found");
    }

  }

  function uploadFile (UserFile calldata file) external {
    uint8 idCounter = uint8(filesByUser[msg.sender].length + 1);

    UserFile memory newFile = UserFile(idCounter,file.url,file.title, file.uploadDate, file.size);
   
    filesByUser[msg.sender].push(newFile);
  } 

  function getFilesByUser () external view returns(UserFile[] memory list) {
    return filesByUser[msg.sender];
  }
}
 