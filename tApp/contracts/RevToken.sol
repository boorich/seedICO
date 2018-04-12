pragma solidity 0.4.21;

// Safe Math library that automatically checks for overflows and underflows
library SafeMath {
    // Safe multiplication
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        require(a == 0 || c / a == b);
        return c;
    }
    // Safe subtraction
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }
    // Safe addition
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c>=a && c>=b);
        return c;
    }
}

contract Owned {
    address public owner;
    address public enterprise = 0xDEB80077101d919b6ad1e004Cff36203A0F0CE60;

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    function Owned() public {
        owner = msg.sender;
    }
}

contract Token is Owned {
    using SafeMath for uint256;
    
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // This creates a mapping with all balances
    mapping (address => uint256) public balanceOf;
    // Another array with spending allowances
    mapping (address => mapping (address => uint256)) public allowance;
    // The total supply of the token
    uint256 public totalSupply;
    // Some variables for nice wallet integration
    string public name;         // name of token
    string public symbol;       // symbol of token
    uint8 public decimals;      // decimals of token

    // Send coins
    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_to != 0x0);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != 0x0);
        balanceOf[_to] = balanceOf[_to].add(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function increaseApproval(address _spender, uint _addedValue) public returns (bool success) {
        allowance[msg.sender][_spender] = allowance[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }
    
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool success) {
        uint oldValue = allowance[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowance[msg.sender][_spender] = 0;
        } else {
            allowance[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
        return true;
    }
}

contract DevRev is Token {
    address public DevTokenAddress;

    // swap can be only called by the devtokencontract, adds tokenamount to tokenHolder and 5% to enterprise 
    function swap(uint256 _tokenAmount, address _tokenHolder) external returns(bool success) { 
        require(msg.sender == DevTokenAddress);
        balanceOf[_tokenHolder] = balanceOf[_tokenHolder].add(_tokenAmount);
        uint256 fee = _tokenAmount.mul(5)/100;
        balanceOf[enterprise] = balanceOf[enterprise].add(fee);
        totalSupply = totalSupply.add(_tokenAmount).add(fee);
        emit Transfer(address(this), _tokenHolder, _tokenAmount);
        emit Transfer(address(this), enterprise, fee);
        return true;
    }
}

contract RevSale is DevRev {
    // Structure of an offer
    struct RevSaleOffer {
        // basic ID for the offer
        uint256 ID;
        // address of the seller
        address seller;
        // amount of tokens that are being offered
        uint256 amount;
        // total price of the tokens that are being sold
        uint256 price;
        // the specific address that this offer is for
        // (if its a public offer this will be 0x0) 
        address receiver;
    }

    // array of all current offers
    RevSaleOffer[] public revSaleOffers;

    // adding a new offer
    function addOffer(uint256 _amount, uint256 _price, address _receiver) public {
        // only tokenholder is allowed to add offers
        require(balanceOf[msg.sender] > 0);
        uint256 ID = revSaleOffers.length;
        // add offer to the offers-array
        revSaleOffers.push(RevSaleOffer(ID, msg.sender, _amount, _price, _receiver));
    }

    // deleting an offer
    function deleteOffer(uint256 _id) public {
        // only the seller is able to delete the offer
        require(revSaleOffers[_id].seller == msg.sender);
        // delete the offer from the array
        delete revSaleOffers[_id];
    }

    // buying the tokens of a offer
    function buyOffer(uint256 _id) payable public {
        // token-balance of the seller has to suffice for the sale
        require(balanceOf[revSaleOffers[_id].seller] >= revSaleOffers[_id].amount);
        // buyer has to have enough ether for the current purchase
        require(msg.value == revSaleOffers[_id].price);
        // if the offer is not public and it's tailored towards a specific address..
        if(revSaleOffers[_id].receiver != 0x0) {
            // ..the receiver has to be correct
            require(revSaleOffers[_id].receiver == msg.sender);
        }

        // transfer the RevTokens from the seller to the receiver
        balanceOf[revSaleOffers[_id].seller] = balanceOf[revSaleOffers[_id].seller].sub(revSaleOffers[_id].amount);
        balanceOf[msg.sender] = balanceOf[msg.sender].add(revSaleOffers[_id].amount);
        emit Transfer(revSaleOffers[_id].seller, msg.sender, revSaleOffers[_id].amount);

        // transfer the funds from the receiver to the seller of the tokens
        revSaleOffers[_id].seller.transfer(revSaleOffers[_id].price);
        
        // remove the offer from the array
        delete revSaleOffers[_id];
    }
}

contract RevToken is RevSale {
    // constructor
    function RevToken(string _name, string _symbol, address _DevTokenAddress) public {
        // name of the RevToken
        name = _name;
        // symbol of the RevToken
        symbol = _symbol;
        // decimals of the RevToken, fixed to 18
        decimals = 18;

        // set address of DevContract in constructor
        require(_DevTokenAddress != 0x0);
        DevTokenAddress = _DevTokenAddress;
    }
}