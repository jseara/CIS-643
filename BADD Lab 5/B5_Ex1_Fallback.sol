pragma solidity ^0.8.15;

contract FallbackReceiver {
  event Log(string func, uint gas);
  fallback() external payable {
    emit Log("fallback", gasleft());}

  function getBalance() public view returns (uint) {
    return address(this).balance;}}

contract FallbackSender {
  function call(address payable _to) public payable {
    (bool sent, ) = _to.call{value: msg.value}("");
    require(sent, "Failed to send Ether");}}