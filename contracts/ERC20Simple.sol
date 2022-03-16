// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";

contract ERC20Simple is
    Initializable,
    ERC20Upgradeable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    PausableUpgradeable
{
    using SafeMathUpgradeable for uint256;

    uint256 private _cap;
    uint256 private _burnRate;
    uint256 private _min;

    mapping(address=>bool) private _managers;

    event ManagerAdded(address);
    event ManagerRemoved(address);

    function initialize(uint256 min_, uint256 cap_, uint256 burnRate_) public initializer {
        __ERC20_init("ERC20Simple", "SMP");
        __Ownable_init();
        __UUPSUpgradeable_init();
        __Pausable_init();

        __Init_burnRate(burnRate_);
        __Init_supply(cap_, min_);
      
        __Init_managers();
    }
    
    
    modifier onlyManagers {
      require(_managers[msg.sender], "ERC20Simple: sender not an admin");
      _;
    }

    function __Init_burnRate(uint256 burnRate_) internal onlyInitializing {
        require(burnRate_ <= 100, "ERC20Simple: Burn rate is > 100");
        require(burnRate_ >= 0, "ERC20Simple: Burn rate is < 0");
        _burnRate = burnRate_;
    }

    function __Init_supply(uint256 cap_, uint256 min_) internal onlyInitializing {
        require(cap_ > 0, "ERC20Simple: cap is 0");
        require(min_ <= cap_ , "ERC20Simple: min larger than cap");
        _cap = cap_ * (10 ** decimals());
        _min = min_ * (10 ** decimals());
        _mint(msg.sender,_min);
    }

    function __Init_managers() internal onlyInitializing {
        _managers[msg.sender] = true;
    }
    

    function cap() public view virtual returns (uint256) {
        return _cap;
    }

    function transfer(address to, uint256 amount) public override returns (bool)
    {
        require(amount > 0, "ERC20Simple: amount is 0");
        require( balanceOf(msg.sender) >= amount, "ERC20Simple: transfer amount exceeds balance");

        uint256 toBurn = _burnAmount(amount);
        uint256 toTransfer = amount.sub(toBurn);
        _transfer(msg.sender, to, toTransfer);
        _burn(msg.sender, toBurn);

        return true;
    }

    function transferFrom(address from, address to, uint256 amount) public override returns (bool) {
        require(amount > 0, "ERC20Simple: amount is 0");
        uint256 toBurn = _burnAmount(amount);
        uint256 toTransfer = amount.sub(toBurn);
        _transfer(from, to, toTransfer);
        _burn(from, toBurn);
        return true;
    }

    function addManager(address account) external onlyOwner {
        _managers[account] = true;
        emit ManagerAdded(account);
    }

    function removeManager(address account) external onlyOwner {
        delete _managers[account];
        emit ManagerRemoved(account);
    }

    function mint(uint256 amount) external whenNotPaused {
        require(totalSupply() + amount <= cap(), "ERC20Simple: cap exceeded");
        _mint(msg.sender, amount);
    }

    function burn(address from, uint256 amount) external whenNotPaused {
        require(from == msg.sender);
        _burn(from, amount);
    }

    function pause() public onlyManagers {
        _pause();
    }

    function unpause() public onlyManagers {
        _unpause();
    }

    function _burnAmount(uint256 amount) internal view returns(uint256) {
       return amount.mul(_burnRate).div(100);
    }


    function isManager(address account) public view returns(bool){
      return _managers[account];
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}
}
