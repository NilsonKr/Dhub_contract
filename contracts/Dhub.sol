//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Dhub {
  struct User {
    string name;
    string profileUrl;
  }    

  mapping (address => User) public users;

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


  function editUser (string memory field, string memory value) external returns(User memory){ 
    User storage user = users[msg.sender];

    require(bytes(user.name).length > 0, "User not found");

    if(keccak256(abi.encodePacked(field)) == keccak256(abi.encodePacked("name"))){
      require(bytes(value).length > 0, "Name is required");
      user.name = value;

    } else if(keccak256(abi.encodePacked(field)) == keccak256(abi.encodePacked("name"))){
      require(bytes(value).length > 0, "Profile url is required");
      user.profileUrl = value;

    } else {
      require(false, "Field not found");
    }

    return user;
  }
}
 