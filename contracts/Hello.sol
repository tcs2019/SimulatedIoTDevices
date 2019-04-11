pragma solidity ^0.5.0;
contract Hello {
  event SayHello(string _message);

  string public message;

  function HelloWorld() public {
    message = "Hello, World : This is a Solidity Smart Contract on the Private Ethereum Blockchain ";
    emit SayHello(message);
  }
}