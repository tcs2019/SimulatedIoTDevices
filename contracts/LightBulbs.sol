pragma solidity ^0.5.6;

contract LightBulbs {

    event NameChange(uint lightbulbId, string name);
    event StatusChange(uint lightbulbId, bool status);
    event ColorChange(uint lightbulbId, uint8 red, uint8 green, uint8 blue);

    struct LightBulb {
        string name; // front door 
        string description; // for plug -> what to, where
        bool status; // true/false = on/off
        uint8 red; // 0-255
        uint8 green;
        uint8 blue;
        uint8 intensity; // 0-100
    }

    LightBulb[] public lightbulbs;

    mapping (uint => address) public lightbulbToOwner;

    function _addNewLightBulb(string memory _name) public {
        uint _id = lightbulbs.push(LightBulb(_name, false, 255, 255, 255)) - 1;
        lightbulbToOwner[_id] = msg.sender;
    }

    function _changeName(uint _lightbulbId, string memory _name) public {
        require(msg.sender == lightbulbToOwner[_lightbulbId]);
        lightbulbs[_lightbulbId].name = _name;
        emit NameChange(_lightbulbId, _name);
    }

    function _changeStatus(uint _lightbulbId, bool _status) public {
        require(msg.sender == lightbulbToOwner[_lightbulbId]);
        lightbulbs[_lightbulbId].status = _status;
        emit StatusChange(_lightbulbId, _status);
    }

    function _changeColor(uint _lightbulbId, uint8 _red, uint8 _green, uint8 _blue) public {
        require(msg.sender == lightbulbToOwner[_lightbulbId]);
        lightbulbs[_lightbulbId].red = _red;
        lightbulbs[_lightbulbId].green = _green;
        lightbulbs[_lightbulbId].green = _blue;
        emit ColorChange(_lightbulbId, _red, _green, _blue);
    }


}
