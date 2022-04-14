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
}
