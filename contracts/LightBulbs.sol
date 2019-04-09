pragma solidity ^0.5.0;

contract LightBulbs {

    event NewLightBulb(uint lightBulbId, string name, string description, bool status, uint8 red, uint8 green, uint8 blue, uint8 intensity);
    event NameChange(uint lightBulbId, string name);
    event DescriptionChange(uint lightBulbId, string description);
    event StatusChange(uint lightBulbId, bool status);
    event ColorChange(uint lightBulbId, uint8 red, uint8 green, uint8 blue);
    event IntensityChange(uint lightBulbId, uint8 intensity);

    struct LightBulb {
        uint256 bid;
        string id;
        string name; // front door 
        string description; // for plug -> what to, where
        bool status; // true/false = on/off
        uint8 red; // 0-255
        uint8 green;
        uint8 blue;
        uint8 intensity; // 0-100
    }
    uint  deviceCounter;
    mapping (uint => LightBulb) public lightbulblist;
  

    LightBulb[] public lightBulbs;

    mapping (uint => address) public lightBulbToOwner;

        // fetch a device's status
  function fetchDeviceStatus(uint256 id) external view returns (
    string memory name,
    string memory description,
    bool status, // true/false = on/off
    uint8 red, // 0-255
    uint8 green,
    uint8 blue,
    uint8 intensity // 0-100
    ) {
    return (
    name = lightbulblist[id].name,
    description = lightbulblist[id].description,
    status = lightbulblist[id].status,
    red = lightbulblist[id].red,
    green = lightbulblist[id].green,
    blue = lightbulblist[id].blue,
    intensity = lightbulblist[id].intensity
    );
  }

    // fetch the number of  deviceslist in the contract
  function getNumberOfdevices() public view returns (uint) {
    return  deviceCounter;
  }

  function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
    if (_i == 0) {
        return "0";
    }
    uint j = _i;
    uint len;
    while (j != 0) {
        len++;
        j /= 10;
    }
    bytes memory bstr = new bytes(len);
    uint k = len - 1;
    while (_i != 0) {
        bstr[k--] = byte(uint8(48 + _i % 10));
        _i /= 10;
    }
    return string(bstr);
}

    function _addNewLightBulb(string memory _name, string memory _description) public {
        deviceCounter++;
        string memory s = string(abi.encodePacked("Lib", uint2str(deviceCounter)));
        
        uint _id = lightBulbs.push(LightBulb(deviceCounter, s, _name, _description, false, 255, 255, 255, 100)) - 1;
        lightbulblist[deviceCounter] = LightBulb(
            deviceCounter,
            s,
            _name,
            _description,
            false,
            255,
            255,
            255,
            100
          );
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

      function getDevices() public view returns (uint[] memory) {
    // prepare output array
    uint[] memory deviceIds = new uint[](deviceCounter);
    uint numberOfDevices = 0;
    // iterate over  deviceslist
    for(uint i = 1; i <= deviceCounter;  i++) {
      // keep the ID if the device
        deviceIds[numberOfDevices] = lightbulblist[i].bid;
        numberOfDevices++;
    }
    // copy the deviceIds array into a smaller forSale array
    uint[] memory forSale = new uint[](numberOfDevices);
    for(uint j = 0; j < numberOfDevices; j++) {
      forSale[j] = deviceIds[j];
    }
    return forSale;
  }


}
