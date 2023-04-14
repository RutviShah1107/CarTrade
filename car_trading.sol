pragma solidity >=0.4.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CarTrading {
    struct Car {
        uint256 id;
        string model;
        string company;
        uint256 madeYear;
        uint256 boughtYear;
        uint256 miles;
        bool cleanTitle;
        bool repacking;
        string VIN;
        uint256 markedPrice;
    }

    mapping(uint256 => Car) public cars;
    mapping(uint256 => address) public carOwners;
    IERC20 public stablecoin;

    uint256 public exchangeRate; // USD to ETH exchange rate in wei (1 USD = exchangeRate wei)
    constructor(address _stablecoin, uint256 _exchangeRate) {
        stablecoin = IERC20(_stablecoin);
        exchangeRate = _exchangeRate;
    }

    function addCar(
        uint256 id,
        string memory model,
        string memory company,
        uint256 madeYear,
        uint256 boughtYear,
        uint256 miles,
        bool cleanTitle,
        bool repacking,
        string memory VIN,
        uint256 markedPrice
    ) public {
        cars[id] = Car(id, model, company, madeYear, boughtYear, miles, cleanTitle, repacking, VIN, markedPrice);
        carOwners[id] = msg.sender;
    }

    function tradeCar(uint256 id, address newOwner) public {
        require(carOwners[id] == msg.sender, "Only the owner can transfer the car.");
        carOwners[id] = newOwner;
    }

    function usdToEth(uint256 usdAmount) public view returns (uint256) {
        return usdAmount / exchangeRate;
    }

    function estimateCarPrice(uint256 id) public view returns (uint256) {
    Car storage car = cars[id];
    uint256 value = car.markedPrice;
    //uint256 age = block.timestamp - car.boughtYear;  - (car.miles * 10)- (age * 1000);
    if (!car.cleanTitle) {
        value = value * 75 / 100; // reduce value by 25% if car doesn't have the clean title
    }
    
    if (car.repacking) {
        value = value * 110 / 100; // increase value by 10% if car has been repacked
    }
    return value;
}

}

// SPDX-License-Identifier: GPL-3.0-or-later
