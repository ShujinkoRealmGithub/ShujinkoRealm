pragma solidity 0.5.17;

import "./Ownable.sol";
import "./Shujinko.sol";
import "./ShujinkoRealmToken.sol";
import "./SafeMath.sol";

contract ShujinkoFarming is Ownable {
    
    using SafeMath for uint256;
    
    // Tokens used in the farming
    Shujinko public Shujinko;
    ShujinkoRealmToken public Shujinko;
    
    constructor(Shujinko _Shujinko, ShujinkoRealmToken _ShujinkoRealmToken) public{
        //init Shujinko token address
        setShujinkoToken(_Shujinko);
        setShujinkoRealmToken(_ShujinkoRealmToken);
    }
    
    // Shujinko farming variable
    mapping(uint256 => bool) public canBeFarmed;
    mapping(uint256 => bool) public farmed;
    // Shujinko who is farming
    mapping(uint256 => bool) public onFarming;
    // address who farm the Shujinko
    mapping(uint256 => address) private _farmingBy;
    
    // array of spots for Shujinko can be farmed
    uint256[] private _spots;
    
    // Number of SJKR Locked on stacking
    uint256 public SJKRStackedOnFarming;
    
    // Time for farming
    uint256 public KillerShujinkoFarmingTime = 45 days;
    uint256 public MonsterShujinkoFarmingTime = 30 days;
    uint256 public PreyShujinkoFarmingTime = 15 days;
    
    // Amount for farming Values will and can change 
    uint256 public amountForKillerShujinko = 7000; 
    uint256 public amountForMonsterShujinko = 5000;
    uint256 public amountForPreyShujinko = 2000;
 
    
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
    // Setting Farming conditions
    // =========================================================================================


    //functions for setting time needed for farming a Shujinko
    function setFarmingTimeKillerShujinko(uint256 _time) public onlyOwner(){
        KillerShujinkoFarmingTime = _time;
    }
    
    function setFarmingTimeMonsterShujinko(uint256 _time) public onlyOwner(){
        MonsterShujinkoFarmingTime = _time;
    }
    
    function setFarmingTimePreyShujinko(uint256 _time) public onlyOwner(){
        PreyShujinkoFarmingTime = _time;
    }
    
    //setting amount DMW needed for farming a Shujinko
    function setAmountForFarmingKillerShujinko(uint256 _amount) public onlyOwner(){
        amountForKillerShujinko = _amount;
    }
    
    function setAmountForFarmingMonsterShujinko(uint256 _amount) public onlyOwner(){
        amountForMonsterShujinko = _amount;
    }
    
    function setAmountForFarmingPreyShujinko(uint256 _amount) public onlyOwner(){
        amountForPreyShujinko = _amount;
    }
    
    // =========================================================================================
    // Setting Shujinko ID can be farmed
    // =========================================================================================

    // Create a spot for a Shujinko who can be farmed
    function setShujinkoIdCanBeFarmed(uint256 _id) public onlyOwner(){
        require(_id>=1 && _id<=160);
        require(farmed[_id] == false,"Already farmed");
        canBeFarmed[_id] = true;
        _spots.push(_id);
    }
    
    // =========================================================================================
    // Farming
    // =========================================================================================

    struct farmingInstance {
        uint256 ShujinkoId;
        uint256 farmingBeginningTime;
        uint256 amount;
        bool isActive;
    }
    
    // 1 address can only farmed 1 Shujinko for a period
    mapping(address => farmingInstance) public farmingInstances;

    // init a farming 
    function farmingShujinko(uint256 _id) public{
        require(canBeFarmed[_id] == true,"This Shujinko can't be farmed");
        require(Shujinko.balanceOf(msg.sender) > _ShujinkoAmount(_id), "Value isn't good");
        delete _spots[_getSpotIndex(_id)];
        canBeFarmed[_id] = false;
        Shujinko.transferFrom(msg.sender,address(this),_ShujinkoAmount(_id).mul(1E18));
        farmingInstances[msg.sender] = farmingInstance(_id,now,_ShujinkoAmount(_id),true);
        SJKRStackedOnFarming = SJKRStackedOnFarming.add(_ShujinkoAmount(_id));
    }
    
    // cancel my farming instance
    function renounceFarming() public {
        require(farmingInstances[msg.sender].isActive == true, "You don't have any farming instance");
        Shujinko.transferFrom(address(this),msg.sender,farmingInstances[msg.sender].amount.mul(1E18));
        canBeFarmed[farmingInstances[msg.sender].ShujinkoId] = false;
        delete farmingInstances[msg.sender];
        _spots.push(farmingInstances[msg.sender].ShujinkoId);
        SJKRStackedOnFarming = SJKRStackedOnFarming.sub(_ShujinkoAmount(farmingInstances[msg.sender].ShujinkoId));
        
    }
    
    // Claim Shujinko at the end of farming
    function claimShujinko() public {
        require(farmingInstances[msg.sender].isActive == true, "You don't have any farming instance");
        require(now.sub(farmingInstances[msg.sender].farmingBeginningTime) >= _ShujinkoDuration(farmingInstances[msg.sender].ShujinkoId));
        
        Shujinko.transferFrom(address(this),msg.sender,farmingInstances[msg.sender].amount.mul(1E18));
        farmed[farmingInstances[msg.sender].ShujinkoId] = true;
        Shujinko.mintShujinko(msg.sender, farmingInstances[msg.sender].ShujinkoId);
        delete farmingInstances[msg.sender];
        SJKRStackedOnFarming = SJKRStackedOnFarming.sub(_ShujinkoAmount(farmingInstances[msg.sender].ShujinkoId));
    }
    
    // function allow to now the necessary amount for the Shujinko farming
    function _ShujinkoAmount(uint256 _id) private view returns(uint256){
        // function will return amount needed to farm Shujinko
        uint256 _amount;
        if(_id >= 1 && _id <= 10){
            _amount = amountForKillerShujinko;
        } else if(_id >= 11 && _id <= 60){
            _amount = amountForMonsterShujinko;
        } else if(_id >= 61 && _id <= 160){
            _amount = amountForPreyShujinko;
        }
        return _amount;
    }
    
     // function allow to now the necessary time for the Shujinko farming
    function _ShujinkoDuration(uint256 _id) private view returns(uint256){
        // function will return amount needed to farm Shujinko
        uint256 _duration;
        if(_id >= 1 && _id <= 10){
            _duration = KillerShujinkoFarmingTime;
        } else if(_id >= 11 && _id <= 60){
            _duration = MonsterShujinkoFarmingTime;
        } else if(_id >= 61 && _id <= 160){
            _duration = PreyShujinkoFarmingTime;
        }
        return _duration;
    }
    
    function _getSpotIndex(uint256 _id) private view returns(uint256){
        uint256 index;
        for( uint256 i = 0 ; i< _spots.length ; i++){
            if(_spots[i] == _id){
                index = i;
                break;
            }
        }
        return index;
    }
    
    // return spots of farming
    function ShujinkoSpot() public view returns(uint256[] memory spots){
        return _spots;
    }
    
    // winner of contests will receive Shujinko
    function ShujinkoFor(uint256 _id, address _winner ) public onlyOwner(){
        require(farmed[_id]==false);
        farmed[_id] = true;
        Shujinko.Shujinko(_winner,_id);
    }

    
}