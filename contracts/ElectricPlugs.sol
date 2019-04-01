pragma solidity ^0.5.6;

contract ElectricPlugs {

    event NewElectricPlug(uint electricPlugId, string name, string description, bool status);
    event NameChange(uint electricPlugId, string name);
    event DescriptionChange(uint electricPlugId, string description);
    // FIXME: this event should only return id and status
    event StatusChange(uint electricPlugId, string name, string description, bool status);

    struct ElectricPlug {
        string name; // front door 
        string description; // for plug -> what to, where
        bool status; // true/false = on/off
    }

    ElectricPlug[] public electricPlugs;

    mapping (uint => address) public electricPlugToOwner;

    function _addElectricPlug(string memory _name, string memory _description) public {
        uint _id = electricPlugs.push(ElectricPlug(_name, _description, false)) - 1;
        electricPlugToOwner[_id] = msg.sender;
        emit NewElectricPlug(_id, _name, _description, false);
    }

    function _changeName(uint _electricPlugId, string memory _name) public {
        require(msg.sender == electricPlugToOwner[_electricPlugId]);
        electricPlugs[_electricPlugId].name = _name;
        emit NameChange(_electricPlugId, _name);
    }

    function _changeDescription(uint _electricPlugId, string memory _description) public {
        require(msg.sender == electricPlugToOwner[_electricPlugId]);
        electricPlugs[_electricPlugId].description = _description;
        emit DescriptionChange(_electricPlugId, _description);
    }

    function _changeStatus(uint _electricplugId, bool _status) public {
        require(msg.sender == electricPlugToOwner[_electricplugId]);
        electricPlugs[_electricplugId].status = _status;
        // FIXME: this event should only return id and status
        string memory _name = electricPlugs[_electricplugId].name;
        string memory _description = electricPlugs[_electricplugId].description;
        emit StatusChange(_electricplugId, _name, _description, _status);
    }
} 