pragma solidity ^0.5.6;

contract ElectricPlugs {

    event NameChange(uint electricPlugId, string name);
    event DescriptionChange(uint electricPlugId, string description);
    event StatusChange(uint electricPlugId, bool status);

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
        emit StatusChange(_electricplugId, _status);
    }
} 