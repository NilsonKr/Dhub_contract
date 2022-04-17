//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Dhub {

  // User information data structure
  struct User {
    string name;
    string profileUrl;
  }    

  // User file storage data structure
  struct UserFile { 
   uint8 id;
   string url;
   string title;
   string description;
   string uploadDate;
   uint256 size;
  }

  // Track user information by address
  mapping (address => User) public users;

  // Track user files by address
  mapping (address => UserFile[]) public filesByUser;


  /**
   * @notice Login into the application through a wallet connection
   * @dev Checks if the user exists and proceed to login in the application
   * @return User struct information
   */
  function login () external view returns(User memory){
    User memory user = users[msg.sender];
    require(bytes(user.name).length > 0, "User not found");

    return user;
  }

  /**
   * @notice Register a new user into the application
   * @dev validate that the new user fields are not empty 
   * @dev checks if the user already exists and proceed to register a new user
   * @dev Create a new record in users mapping 
   */
  function register (string memory name, string memory profileUrl) external {
    require(bytes(name).length > 0, "Name is required");
    require(bytes(profileUrl).length > 0, "Profile url is required");

    User memory user = users[msg.sender];
    require(bytes(user.name).length == 0, "User already exists");

    users[msg.sender] = User(name, profileUrl);
  }

  /**
   * @notice Allow to update user information such as "nickname" and "profile url"
   * @dev validate that the user exists 
   * @dev math the field to edit and update the information otherwise will revert
   * @param field should be "name" or "profileUrl", mustn't be empty 
   * @param value corresponding value to field, mustn't be empty 
   */
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
      revert("Field not found");
    }

  }

  /**
   * @notice Upload new file to the application
   * @param file receive UserFile data after been uploaded to IPFS by the client
   * @dev Create a new id based on filesByUser array size
   * @dev Create a new struct UserFile record in filesByUser mapping 
   */
  function uploadFile (UserFile calldata file) external {
    uint8 idCounter = uint8(filesByUser[msg.sender].length + 1);

    UserFile memory newFile = UserFile(idCounter, file.url, file.title, file.description, file.uploadDate, file.size);
   
    filesByUser[msg.sender].push(newFile);
  } 

  /**
   * @notice retrieves user's files list
   * @return list of UserFile struct by user address
   */
  function getFilesByUser () external view returns(UserFile[] memory) {
    return filesByUser[msg.sender];
  }


  /**
   * @notice retrieves user's specific file
   * @param position indicates the index of file in UserFile array
   * @dev search the file by its index position in array
   * @return UserFile corresponding struct 
   */
  function getFileByPosition (uint8 position) external view returns(UserFile memory){
    return filesByUser[msg.sender][position];
  }
  

  /**
   * @notice updates the fields "name" & "description" of a specific file of a user
   * @dev this function should update at once both fields, so it might receive more than 1 field and value
   */
  function editFile () external {

  }
}
 