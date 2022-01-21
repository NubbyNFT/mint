// SPDX-License-Identifier: LGPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PhoneyX is ERC721Enumerable, PaymentSplitter, Ownable {

    using SafeMath for uint256;

    string private _tokenURI;
    bool public mintActive;
    uint256 public maxSupply;
    uint256 public itemPrice;
    uint256 public maxPerWallet;
    
    address[] private _team = [0x3CC03bDdF245527EEa280C9d93bD64fed03192EA, 0xEf7c5EBB465e99543cCBFccA6d04D8ab8b35129A, 0x9a3c7305005f513Fcba15e358ef1AA40B111c0A0];
    uint256[] private _shares = [1, 1, 1];

    constructor() ERC721("PhoneyX", "PHONEY") PaymentSplitter(_team, _shares) {
        _tokenURI = "";
        mintActive = true;
        itemPrice = 8e16;
        maxPerWallet = 100;
    }

    function withdrawAll() public onlyOwner {
        for (uint256 i = 0; i < _team.length; i++) {
            address payable wallet = payable(_team[i]);
            release(wallet);
        }
    }    

    function mint(uint256 amount) public payable {
        uint256 ts = totalSupply();
        require(mintActive, "Sale not acitve!");
        require(balanceOf(msg.sender).add(amount) <= maxPerWallet, "Amount exeed max token per wallet!");
        require(ts.add(amount) <= maxSupply, "Amount exeeds max supply!");
        require(itemPrice.mul(amount) == msg.value, "Not enough Matic");
        for (uint256 i = ts + 1; i <= ts + amount; i++) {
            _safeMint(msg.sender, i);
        }        
    }

    function giveaway(address _address, uint256 amount) public onlyOwner{
        uint256 ts = totalSupply();
        require(ts.add(amount) <= maxSupply, "Amount exeeds max supply!");
        for (uint256 i = ts + 1; i <= ts + amount; i++) {
            _safeMint(_address, i);
        }        
    }

    function setMintActive(bool _active) public onlyOwner {
        mintActive = _active;
    }

    function setBaseURI(string memory _uri) public onlyOwner {
        _tokenURI = _uri;
    }

    function setMaxSupply(uint256 _maxSupply) public onlyOwner {
        require(_maxSupply <= 5555, "Too high");
        maxSupply = _maxSupply;
    }

    function setItemPrice(uint256 _itemPrice) public onlyOwner {
        itemPrice = _itemPrice;
    }

    function setMaxPerWallet(uint256 _maxPerWallet) public onlyOwner {
        maxPerWallet = _maxPerWallet;
    }

    function _baseURI() internal view override returns (string memory) {
        return _tokenURI;
    }
}
