pragma solidity ^0.5.6;

contract LightBulbs {

    event NewLightBulb(uint lightBulbId, string name, string description, bool status, uint8 red, uint8 green, uint8 blue, uint8 intensity);
    event NameChange(uint lightBulbId, string name);
    event DescriptionChange(uint lightBulbId, string description);
    event StatusChange(uint lightBulbId, bool status);
    event ColorChange(uint lightBulbId, uint8 red, uint8 green, uint8 blue);
    event IntensityChange(uint lightBulbId, uint8 intensity);

    struct LightBulb {
        string name; // front door 
        string description; // for plug -> what to, where
        bool status; // true/false = on/off
        uint8 red; // 0-255
        uint8 green;
        uint8 blue;
        uint8 intensity; // 0-100
    }

    LightBulb[] public lightBulbs;

    mapping (uint => address) public lightBulbToOwner;

    function _addNewLightBulb(string memory _name, string memory _description) public {
        uint _id = lightBulbs.push(LightBulb(_name, _description, false, 255, 255, 255, 100)) - 1;
        lightBulbToOwner[_id] = msg.sender;
        emit NewLightBulb(_id, _name, _description, false, 255, 255, 255, 100);
    }

    function _changeName(uint _lightBulbId, string memory _name) public {
        require(msg.sender == lightBulbToOwner[_lightBulbId]);
        lightBulbs[_lightBulbId].name = _name;
        emit NameChange(_lightBulbId, _name);
    }

    function _changeStatus(uint _lightBulbId, bool _status) public {
        require(msg.sender == lightBulbToOwner[_lightBulbId]);
        lightBulbs[_lightBulbId].status = _status;
        emit StatusChange(_lightBulbId, _status);
    }

    function _changeDescription(uint _lightBulbId, string memory _description) public {
        require(msg.sender == lightBulbToOwner[_lightBulbId]);
        lightBulbs[_lightBulbId].description = _description;
        emit DescriptionChange(_lightBulbId, _description);
    }

    function _changeColor(uint _lightBulbId, uint8 _red, uint8 _green, uint8 _blue) public {
        require(msg.sender == lightBulbToOwner[_lightBulbId]);
        lightBulbs[_lightBulbId].red = _red;
        lightBulbs[_lightBulbId].green = _green;
        lightBulbs[_lightBulbId].green = _blue;
        emit ColorChange(_lightBulbId, _red, _green, _blue);
    }

    function _changeIntensity(uint _lightBulbId, uint8 _intensity) public {
        require(msg.sender == lightBulbToOwner[_lightBulbId]);
        lightBulbs[_lightBulbId].intensity = _intensity;
        emit IntensityChange(_lightBulbId, _intensity);
    }
}
