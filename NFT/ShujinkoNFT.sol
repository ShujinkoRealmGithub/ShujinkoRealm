pragma solidity 0.5.17;

import "./ERC721Full.sol";
import "./Ownable.sol";

//NFT Contract


contract Shujinko is ERC721Full, Ownable {
    // All 120 Shujinko got Killer, Monster and Prey
    mapping(uint256 => string) public Shujinko;

    // Only gameAddress can burn Shujinko
    address public gameControllerAddress;
    // Only farming can mint Shujinko
    address public farmControllerAddress;

    constructor() public ERC721Full("ShujinkoToken") {
        // Shujinko Colors init

        // id 1 to 10 (10 Shujinko) are "Killer Shujinko"
        for (uint256 i = 1; i < 11; i++) {
            Shujinko[i] = "Killer";
        }

        // id 11 to 60 (50 Shujinko) are "Monster Shujinko"
        for (uint256 i = 11; i < 61; i++) {
            Shujinko[i] = "Monster";
        }

        // id 61 to 160 (100 Shujinko) are "Prey Shujinko"
        for (uint256 i = 61; i < 161; i++) {
            Shujinko[i] = "Prey";
        }
    }

    modifier onlyGameController() {
        require(msg.sender == gameControllerAddress);
        _;
    }
    
    modifier onlyFarmingController() {
        require(msg.sender == farmControllerAddress);
        _;
    }

    // events for prevent Players from any change
    event GameAddressChanged(address newGameAddress);
    
    // events for prevent Players from any change
    event FarmAddressChanged(address newFarmAddress);
    

    // init game smart contract address
    function setGameAddress(address _gameAddress) public onlyOwner() {
        gameControllerAddress = _gameAddress;
        emit GameAddressChanged(_gameAddress);
    }
    
        // init farming smart contract address
    function setFarmingAddress(address _farmAddress) public onlyOwner() {
        farmControllerAddress = _farmAddress;
        emit FarmAddressChanged(_farmAddress);
    }

    // Function that only farming smart contract address can call for mint a Shujinko
    function Shujinko(address _to, uint256 _id) public onlyFarmingController() {
        _mint(_to, _id);
    }

    // Function that only game smart contract address can call for burn Shujinko trilogy
    // Shujinko must be approvedForAll by the owner for contract of gameAddress
    function burnShujinkoTrilogy(
        address _ownerOfShujinko,
        uint256 _id1,
        uint256 _id2,
        uint256 _id3
    ) public onlyGameController() {
        require(
            keccak256(abi.encodePacked(Shujinko[_id1])) ==
                keccak256(abi.encodePacked("Killer")) &&
                keccak256(abi.encodePacked(Shujinko[_id2])) ==
                keccak256(abi.encodePacked("Monster")) &&
                keccak256(abi.encodePacked(Shujinko[_id3])) ==
                keccak256(abi.encodePacked("Prey"))
        );
        _burn(_ownerOfShujinko, _id1);
        _burn(_ownerOfShujinko, _id2);
        _burn(_ownerOfShujinko, _id3);
    }
}