// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//import "@openzeppelin/contracts/access/Ownable.sol";

contract MyToken is ERC20 {
    address private _master;
    address private _censor;
    mapping(address => bool) private _blacklist;

    modifier onlyMaster() {
        require(msg.sender == _master, "Caller is not the master");
        _;
    }

    modifier onlyMasterOrCensor() {
        require(msg.sender == _master || msg.sender == _censor, "Caller is not the master or censor");
        _;
    }

    function mint(address account, uint256 value) internal onlyMaster {
        if (account == address(0)) {
            revert ERC20InvalidReceiver(address(0));
        }
        _update(address(0), account, value);
    }

    function burn(address account, uint256 value) internal onlyMaster{
        if (account == address(0)) {
            revert ERC20InvalidSender(address(0));
        }
        _update(account, address(0), value);
    }

    constructor() payable ERC20("IVY.CC", "77") {
        _master = msg.sender;
        _censor = msg.sender;
        mint(msg.sender, 100000000 * 10 ** uint(decimals())); //change amount???need check
    }

    function changeMaster(address newMaster) external onlyMaster {
        _master = newMaster;
    }

    function changeCensor(address newCensor) external onlyMaster {
        _censor = newCensor;
    }

    function setBlacklist(address target, bool blacklisted) external onlyMasterOrCensor {
        //require(msg.sender == _master || msg.sender == _censor, "Only master or censor can blacklist an address");

        _blacklist[target] = blacklisted;

        if (blacklisted) {
            _blacklist[target] = true;
        } else {
            _blacklist[target] = false; //check???
        }
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {

        if (_blacklist[recipient]) {
            _blacklist[msg.sender] = true; 
            //burn()
        } 

        require(!_blacklist[msg.sender], "Sender is blacklisted");
        require(!_blacklist[recipient], "Recipient is blacklisted");
        return super.transfer(recipient, amount);
    }

    
    function transferFrom(address sending, address recipient, uint256 amount) public virtual override returns (bool) {

        if(_blacklist[recipient]){
            _blacklist[sending] = true;
            //burn(send, amount);
        } 

        require(!_blacklist[msg.sender], "Sender is blacklisted");
        require(!_blacklist[recipient], "Recipient is blacklisted");
        return super.transferFrom(sending, recipient, amount);
    }
    
    function clawBack(address target, uint256 amount) external onlyMaster {
        _transfer(target, _master, amount);
    }
}
