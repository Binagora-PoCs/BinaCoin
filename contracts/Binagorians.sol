//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Binagorians is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    event AirdropSent(address _address, uint256 _time);

    // Modifier to check that an address
    // was already registered.
    modifier addressAlreadyRegistered(address _addr) {
        require(
            keccak256(abi.encodePacked((_binagorians[_addr].name))) == keccak256(abi.encodePacked((""))) && 
            _binagorians[_addr].entryTime == 0 &&
            _binagorians[_addr].rate == 0 &&
            _binagorians[_addr].index == 0, 
            "Address already registered");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

    // Modifier to check that an address
    // currently exists.
    modifier addressExists(address _addr) {
        require(
            keccak256(abi.encodePacked((_binagorians[_addr].name))) != keccak256(abi.encodePacked((""))) && 
            _binagorians[_addr].entryTime != 0 &&
            _binagorians[_addr].rate != 0, 
            "Address does not exists");
        // Underscore is a special character only used inside
        // a function modifier and it tells Solidity to
        // execute the rest of the code.
        _;
    }

    // Modifier to check that the
    // address passed in is not the zero address.
    modifier validAddress(address _addr) {
        require(_addr != address(0), "Not valid address");
        _;
    }

    // Modifier to check if an address
    // could be deleted
    modifier validAddressToRemove(address _addr) {
        uint256 index = _binagorians[_addr].index;
        require(index < _binagoriansArray.length, "Index out of bounds");
        _;
    }

    struct Binagorian {
        string name;
        uint256 entryTime;
        uint16 rate;
        uint256 index;
    }

    struct BinagorianAirdrop {
        address addr;
        uint256 amount;
    }
    
    mapping(address => Binagorian) private _binagorians;
    address [] private _binagoriansArray;

    function create(address _bAddress, uint256 _entryTime, string memory _name, uint16 _rate) 
        public 
        onlyOwner 
        validAddress(_bAddress) 
        addressAlreadyRegistered(_bAddress) 
    {
        _binagoriansArray.push(_bAddress);
        _binagorians[_bAddress] = Binagorian(_name, _entryTime, _rate, _binagoriansArray.length - 1);
    }

    // Move the last element to the deleted spot.
    // Remove the last element.
    // Update the index in the map.
    function remove(address _bAddress) 
        public 
        onlyOwner 
        validAddress(_bAddress) 
        addressExists(_bAddress) 
        validAddressToRemove(_bAddress) 
    {
        uint256 index = _binagorians[_bAddress].index;
        uint256 lastBinagorianArrayIndex = _binagoriansArray.length-1;
        address lastBinagorianAddress = _binagoriansArray[lastBinagorianArrayIndex];
        _binagorians[lastBinagorianAddress].index = index;
        _binagoriansArray[index] = lastBinagorianAddress;
        _binagoriansArray.pop();
        delete _binagorians[_bAddress];
    }

    function updateRate(address _bAddress, uint16 _newRate) 
        public 
        onlyOwner 
        validAddress(_bAddress) 
        addressExists(_bAddress) 
    {
        Binagorian storage binagorian = _binagorians[_bAddress];
        binagorian.rate = _newRate;
    }

    function get(address _bAddress) 
        public 
        onlyOwner 
        validAddress(_bAddress) 
        addressExists(_bAddress) 
        view 
        returns (string memory name, uint256 entryTime, uint16 rate, uint256 airdropAmount) 
    {
        return (_binagorians[_bAddress].name, _binagorians[_bAddress].entryTime, _binagorians[_bAddress].rate, getAirdropAmount(_bAddress));
    }

    function getCurrent() 
        public 
        addressExists(msg.sender) 
        view 
        returns (string memory name, uint256 entryTime, uint16 rate) 
    {
        address bAddress = msg.sender;
        return (_binagorians[bAddress].name, _binagorians[bAddress].entryTime, _binagorians[bAddress].rate);
    }

    function getRegisteredAddresses() 
        public 
        onlyOwner 
        view 
        returns (address [] memory) 
    {
        return _binagoriansArray;
    }

    function getAirdropAmount(address bAddress) 
        private 
        view 
        returns (uint256 amount) 
    {
        uint256 entryTime = _binagorians[bAddress].entryTime;
        uint256 timeWorking = block.timestamp - entryTime;
        uint256 monthsWorking = SafeMath.div(timeWorking, 2629743); // 2629743 is the number of seconds in a month
        
        if (monthsWorking <= 6) {
            return 3;
        }
        else if (monthsWorking <= 12) {
            return 6;
        }
        else if (monthsWorking <= 36) {
            return 10;
        }
        else if (monthsWorking <= 60) {
            return 15;
        }
        else {
            return 20;
        }
    }

    function generateAirdrop(address _token) 
        public 
        onlyOwner
    {
        for (uint256 i = 0; i < _binagoriansArray.length; i++) {
            address bAddress = _binagoriansArray[i];
            IERC20(_token).safeTransfer(bAddress, getAirdropAmount(bAddress) * (10 ** 18));
            emit AirdropSent(bAddress, block.timestamp);
        }
    }
}
