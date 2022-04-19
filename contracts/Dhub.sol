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
   * Address agnostic add function to either upload file or transfer movement
   * @dev Create a new id based on filesByUser array size
   * @dev Create a new struct UserFile record in filesByUser mapping 
   */
  function _addFile (address user,UserFile memory file) private {
    uint8 idCounter = uint8(filesByUser[user].length + 1);

    UserFile memory newFile = UserFile(idCounter, file.url, file.title, file.description, file.uploadDate, file.size);
   
    filesByUser[msg.sender].push(newFile);
  }

  /**
   * Agnostic address remove function to either remove process or transfer movement
   * @param position index of file in user's collection
   * @dev shift elements until the end of array and then executes a .pop() to delete the leftover
   */
  function _safeRemoveFile (address from,uint8 position) private {
    UserFile[] storage collection = filesByUser[from];
    
    for(uint i = position; i < collection.length; i++){
      collection[i] = collection[i + 1];
    }

    collection.pop();
  }

  /**
   * @notice Upload new file to the application
   * @param file receive UserFile data after been uploaded to IPFS by the client
   * @dev calls private function to build up the new file record
   */
  function uploadFile (UserFile calldata file) external {
    _addFile(msg.sender, file);
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
   * @param position receive the index in array to access to target file
   * @param title new title to set to the fil  
   * @param description new description to set to the file 
   * @dev if either "title" or "description" are the same as olders, won't set up again 
   */
  function editFile (uint8 position, string calldata title, string calldata description ) external {
    UserFile storage file = filesByUser[msg.sender][position];

    if(keccak256(abi.encode(file.title)) != keccak256(abi.encode(title))){
      file.title = title;
    }

    if(keccak256(abi.encode(file.description)) != keccak256(abi.encode(description))){
      file.description = description;
    }
  }

  /**
   * @notice remove a file from the collection
   * @dev calls private function to do the removing process
   */
  function removeFile(uint8 index) public {
    _safeRemoveFile(msg.sender, index);
  }

  /**
   * @notice Transfer a file from a user to other
   * @param from origin user address
   * @param to destiny user address
   * @param filePosition index in file array by users
   * This will add a new file into destiny user's file array and will remove from origin user's array the file
   * @dev calls private function to do the transfer movement 
   */
  function transferFile(address from, address to, uint8 filePosition) external {
    require(bytes(users[to].name).length > 0, "Destiny user doesn't exist");

    UserFile storage file =  filesByUser[from][filePosition];

    _addFile(to, file);
    _safeRemoveFile(from, filePosition);
  } 
}
 