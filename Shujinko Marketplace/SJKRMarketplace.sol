pragma solidity 0.5.17;

import "./Ownable.sol";
import "./Shujinko.sol";
import "./ShujinkoRealmToken.sol";
import "./SafeMath.sol";

// Market Place contract

contract MarketPlace is Ownable {
    
    using SafeMath for uint256;
    
    // Tokens used in the farming
    Shujinko public Shujinko;
    ShujinkoRealmToken public Shujinko;
    
    constructor(Shujinko _Shujinko, ShujinkoRealmToken _ShujinkoRealmToken) public{
        //init Shujinko token address
        setShujinkoToken(_Shujinko);
        setShujinkoRealmToken(_ShujinkoRealmToken);
    }
    
    event newSellingInstance(uint256 _tokenId, uint256 _amountAsked);
    event Shujinkoold(uint256 _tokenId, address _newOwner);
    event sellingCanceled(uint256 _tokenId);
    
    // =========================================================================================
    // Setting Tokens Functions
    // =========================================================================================

    
    // Set the ShujinkoToken address
    function setShujinkoToken(Shujinko _Shujinko) public onlyOwner() {
        Shujinko = _Shujinko;
    }
    
    // Set the ShujinkoRealmToken address
    function setShujinkoRealmToken(ShujinkoRealmToken _ShujinkoRealmToken) public onlyOwner() {
        Shujinko = _ShujinkoRealmToken;
    }
    
    // =========================================================================================
    // Setting Tokens Functions
    // =========================================================================================

    //Counter
    uint256 onSaleQuantity = 0;
    uint256[] public tokensOnSale;

    struct sellInstance{
        uint256 tokenId;
        uint256 amountAsked;
        bool onSale;
        address owner;
    }
    
    mapping(uint256 => sellInstance) public sellsInstances;
    
    // sell my Shujinko
    function sellingMyShujinko(uint256 _tokenId, uint256 _amountAsked) public {
        require(Shujinko.ownerOf(_tokenId) == msg.sender, "Not your Shujinko");
        Shujinko.transferFrom(msg.sender,address(this),_tokenId);
        sellsInstances[_tokenId] = sellInstance(_tokenId,_amountAsked,true,msg.sender);
        onSaleQuantity = onSaleQuantity.add(1);
        tokensOnSale.push(_tokenId);
        emit newSellingInstance(_tokenId,_amountAsked);
    }
    
    // cancel my selling sellInstance
    function cancelMySellingInstance(uint256 _tokenId)public{
        require(sellsInstances[_tokenId].owner == msg.sender, "Not your Shujinko");
        Shujinko.transferFrom(address(this),msg.sender,_tokenId);
        uint256 index = getSellingIndexOfToken(_tokenId);
        delete tokensOnSale[index];
        delete sellsInstances[_tokenId];
        onSaleQuantity = onSaleQuantity.sub(1);
        emit sellingCanceled(_tokenId);
    }
    
    // buy the NFT Shujinko
    // Need amount of Shujinko allowed to contract
    function buyTheShujinko(uint256 _tokenId, uint256 _amount)public{
        require(sellsInstances[_tokenId].onSale == true,"Not on Sale");
        require(_amount == sellsInstances[_tokenId].amountAsked,"Not enough Value");
        uint256 amount = _amount.mul(1E18);
        require(Shujinko.balanceOf(msg.sender) > amount, "You don't got enough MGT");
        Shujinko.transferFrom(msg.sender,sellsInstances[_tokenId].owner,amount);
        Shujinko.transferFrom(address(this),msg.sender,_tokenId);
        uint256 index = getSellingIndexOfToken(_tokenId);
        delete tokensOnSale[index];
        delete sellsInstances[_tokenId];
        onSaleQuantity = onSaleQuantity.sub(1);
        emit Shujinkoold(_tokenId,msg.sender);
    }
    
    function getSellingIndexOfToken(uint256 _tokenId) private view returns(uint256){
        require(sellsInstances[_tokenId].onSale == true, "Not on sale");
        uint256 index;
        for(uint256 i = 0 ; i< tokensOnSale.length ; i++){
            if(tokensOnSale[i] == _tokenId){
                index = i;
                break;
            }
        }
        return index;
    }
    
}