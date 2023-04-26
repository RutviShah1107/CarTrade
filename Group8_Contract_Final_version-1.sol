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
        bool refitted_car;
        string VIN;
        uint256 markedPrice;
    }

    mapping(uint256 => Car) public cars;
    mapping(uint256 => address) public carOwners;
    IERC20 public stablecoin;

    uint256 public exchangeRate;
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
        bool refitted_car,
        string memory VIN,
        uint256 markedPrice
    ) public {
        cars[id] = Car(id, model, company, madeYear, boughtYear, miles, cleanTitle, refitted_car, VIN, markedPrice);
        carOwners[id] = msg.sender;
    }

    function setCarPrice(uint256 id, uint256 price) public {
        require(carOwners[id] == msg.sender, "Only the owner can set the price.");
        cars[id].markedPrice = price;
    }

    function tradeCar(uint256 id) public payable {
        address payable seller = payable(carOwners[id]);
        require(msg.sender != seller, "You can't buy your own car.");
        require(msg.value == cars[id].markedPrice, "Payment amount is incorrect.");
        seller.transfer(msg.value);
        carOwners[id] = msg.sender;
    }

    function usdToEth(uint256 id) public view returns (uint256) {
        return cars[id].markedPrice / exchangeRate;
    }

    function estimateCarPrice(uint256 id) public view returns (uint256) {
        Car storage car = cars[id];
        uint256 value = car.markedPrice;
        //uint256 age = block.timestamp - car.boughtYear;  - (car.miles * 10)- (age * 1000);
        if (!car.cleanTitle) {
            value = value * 75 / 100; // reduce value by 25% if car doesn't have the clean title
        }
        
        if (car.refitted_car) {
            value = value * 110 / 100; // increase value by 10% if car has been refitted_car
        }
        return value;
    }
}


// SPDX-License-Identifier: GPL-3.0-or-later
