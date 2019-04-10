pragma solidity ^0.5.0;

contract LightBulbs {

  event NewLightBulb(string hash_id, string name, string description, bool status, uint8 red, uint8 green, uint8 blue, uint8 intensity);
  event NameChange(string hash_id, string name);
  event DescriptionChange(string hash_id, string description);
  event StatusChange(string hash_id, bool status);
  event ColorChange(string hash_id, uint8 red, uint8 green, uint8 blue);
  event IntensityChange(string hash_id, uint8 intensity);

  struct LightBulb {
    string hash_id; //in format Lib_1
    string name; // front door 
    string description; // for plug -> what to, where
    bool status; // true/false = on/off
    uint8 red; // 0-255
    uint8 green;
    uint8 blue;
    uint8 intensity; // 0-100
  }

  uint deviceCounter = 0;
  LightBulb[] public lightBulbs;

  mapping (uint => address) public lightBulbToOwner;

  // fetch the number of  deviceslist in the contract
  function getNumberOfdevices() public view returns (uint) {
    return  deviceCounter;
  }

  // help function to convert uint 2 string
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

  // fetch a device's information
  function fetchDeviceStatus(uint256 _id) external view returns (
    // string memory _hash_id,
    string memory _name,
    string memory _description,
    bool _status, // true/false = on/off
    uint8 _red, // 0-255
    uint8 _green,
    uint8 _blue,
    uint8 _intensity // 0-100
    ) {
    return (
    // _hash_id = lightBulbs[_id].hash_id,
    _name = lightBulbs[_id].name,
    _description = lightBulbs[_id].description,
    _status = lightBulbs[_id].status,
    _red = lightBulbs[_id].red,
    _green = lightBulbs[_id].green,
    _blue = lightBulbs[_id].blue,
    _intensity = lightBulbs[_id].intensity
    );
  }

  // Add a new device
  function _addNewLightBulb(string memory _name, string memory _description) public {
      uint _id = lightBulbs.push(LightBulb("Lib_X", _name, _description, false, 255, 255, 255, 100)) - 1;
      string memory _hash_id = string(abi.encodePacked("Lib_", uint2str(_id)));
      lightBulbs[_id].hash_id = _hash_id;

      deviceCounter = _id+1;

      lightBulbToOwner[_id] = msg.sender;
      emit NewLightBulb(_hash_id, _name, _description, false, 255, 255, 255, 100);
  }

  // All changes
  function _changeName(uint _lightBulbId, string memory _name) public {
      require(msg.sender == lightBulbToOwner[_lightBulbId]);
      lightBulbs[_lightBulbId].name = _name;
      emit NameChange(lightBulbs[_lightBulbId].hash_id, _name);
  }

  function _changeStatus(uint _lightBulbId, bool _status) public {
      require(msg.sender == lightBulbToOwner[_lightBulbId]);
      lightBulbs[_lightBulbId].status = _status;
      emit StatusChange(lightBulbs[_lightBulbId].hash_id, _status);
  }

  function _changeDescription(uint _lightBulbId, string memory _description) public {
      require(msg.sender == lightBulbToOwner[_lightBulbId]);
      lightBulbs[_lightBulbId].description = _description;
      emit DescriptionChange(lightBulbs[_lightBulbId].hash_id, _description);
  }

  function _changeColor(uint _lightBulbId, uint8 _red, uint8 _green, uint8 _blue) public {
      require(msg.sender == lightBulbToOwner[_lightBulbId]);
      lightBulbs[_lightBulbId].red = _red;
      lightBulbs[_lightBulbId].green = _green;
      lightBulbs[_lightBulbId].green = _blue;
      emit ColorChange(lightBulbs[_lightBulbId].hash_id, _red, _green, _blue);
  }

  function _changeIntensity(uint _lightBulbId, uint8 _intensity) public {
      require(msg.sender == lightBulbToOwner[_lightBulbId]);
      lightBulbs[_lightBulbId].intensity = _intensity;
      emit IntensityChange(lightBulbs[_lightBulbId].hash_id, _intensity);
  }

} // end of contract
