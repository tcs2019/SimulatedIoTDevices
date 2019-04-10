pragma solidity ^0.5.0;


contract IoTDevices {
  // custom types
  struct Device {
    uint256 id;
    address seller;
    string name;
    string description;
    uint switchon;
    string deviceid;
    string color;
    string lastcomtime;
  }

  // state variables
  mapping (uint => Device) public  deviceslist;
  
  uint  deviceCounter;

  // events
  event LogAddDevice(
    uint indexed _id,
    address indexed _seller,
    string _name,
    string _deviceid
  );

  event LogColorChange(
    uint indexed _id,
    string color
  );

  event LogSwitchonChange(
    uint indexed _id,
    uint switchon
  );

  // add a device
  function addDevice(
    string memory _name, 
    string memory _description, 
    string memory _deviceid,
    string memory lastcomtime
    ) public returns (string memory) {

    // if(bytes(deviceslist[deviceCounter].name).length != bytes(_name).length) {

    // } else if(uint(keccak256(abi.encodePacked(deviceslist[deviceCounter].name))) == uint(keccak256(abi.encodePacked(_name)))) {

	  // } else {
          // a new device
           deviceCounter++;

          // store this device
           deviceslist[deviceCounter] = Device(
            deviceCounter,
            msg.sender,
            _name,
            _description,
            0,
            _deviceid,
            "03a9f4",
            lastcomtime
          );
    
          emit LogAddDevice(deviceCounter, msg.sender, _name, _deviceid);
    // }
  }
  function changeDeviceColor(uint256 id, string memory color) public {
    deviceslist[id].color = color;
    emit LogColorChange(id, color);
  } 

    function changeDeviceSwitchon(uint256 id, uint256 switchon) public {
    deviceslist[id].switchon = switchon;
    emit LogSwitchonChange(id, switchon);
  } 



    // fetch a device's status
  function fetchDeviceStatus(uint256 id) external view returns (
    string memory name,
    string memory description,
    uint switchon,
    string memory deviceid,
    string memory color,
    string memory lastcomtime
    ) {
    return (
    name = deviceslist[id].name,
    description = deviceslist[id].description,
    switchon = deviceslist[id].switchon,
    deviceid = deviceslist[id].deviceid,
    color = deviceslist[id].color,
    lastcomtime = deviceslist[id].lastcomtime
    );
  }

  // fetch the number of  deviceslist in the contract
  function getNumberOfdevices() public view returns (uint) {
    return  deviceCounter;
  }

  // fetch and return all device IDs for  deviceslist still for sale
  function getDevices() public view returns (uint[] memory) {
    // prepare output array
    uint[] memory deviceIds = new uint[](deviceCounter);
    uint numberOfDevices = 0;
    // iterate over  deviceslist
    for(uint i = 1; i <= deviceCounter;  i++) {
      // keep the ID if the device
        deviceIds[numberOfDevices] = deviceslist[i].id;
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
