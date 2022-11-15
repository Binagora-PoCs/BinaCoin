//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Binacoin is ERC20, ERC20Burnable, Ownable {
    event Withdraw(address indexed _from, uint256 _value, uint256 _date);

    constructor() ERC20("Binacoin", "BINA") {}

    struct BurnPtoData {
        uint256 date;
        uint256 amount;
    }

    mapping(address => BurnPtoData []) private _ptoBurns;

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override 
    {
        super._afterTokenTransfer(from, to, amount);
        
        if (to == address(0)) {
            // Here the binagorian should get the payment of the burned tokens
            _ptoBurns[from].push(BurnPtoData(block.timestamp, amount));
            emit Withdraw(from, amount, block.timestamp);
        }
    }

    function getBurnsByAddress(address addr) 
        public 
        onlyOwner 
        view 
        returns (BurnPtoData [] memory) 
    {
        return _ptoBurns[addr];
    }

    function getMyBurns() 
        public 
        view 
        returns (BurnPtoData [] memory) 
    {
        return _ptoBurns[msg.sender];
    }
}