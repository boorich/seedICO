pragma solidity 0.4.21;

contract Owned {
    // address of owner
    address public owner;

    function Owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

}

contract KYC is Owned {

    mapping(address => bool) public whitelisted;
    // maybe not put names on the blockchain? is local storage in db enough?
    mapping(address => string) public names;
    mapping(address => bool) public contracts;

    function whitelist(address _user, string _name) external onlyOwner {
        whitelisted[_user] = true;
        names[_user] = _name;
    }

    function addContract(address _contract) external onlyOwner {
        contracts[_contract] = true;
    }
    
}