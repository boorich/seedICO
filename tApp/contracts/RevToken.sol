pragma solidity 0.4.23;

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

/// @title Basic Owned contract
/// @author chainge.network
/// @notice You can use this contract for only the most basic simulation
/// @dev Contains no ERC-20 functions, just the mapping and general variables
contract Owned {
    address public owner;
    address public enterprise = 0xDEB80077101d919b6ad1e004Cff36203A0F0CE60;

    modifier onlyOwner {
        require(msg.sender == owner, "Caller isn't owner");
        _;
    }
    function Owned() public {
        owner = msg.sender;
    }
}

/// @title Basic ERC20 Token
/// @author chainge.network
/// @notice Basic ERC20 functionality
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
        require(_to != address(this));
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_to != 0x0);
        require(_to != address(this));
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

/// @title Dev-Rev Token Swap
/// @author chainge.network
/// @notice Can be called by the Dev contract to swap Dev tokens for Rev Tokens
contract DevRev is Token {
    address public DevTokenAddress;

    /// @notice swap can be only called by the devtokencontract, adds tokenamount to tokenHolder and 5% to enterprise 
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

/// @title Dividend contract
/// @author chainge.network
/// @notice Gives tokenholders the ability to withdraw dividends and freezes their balances during that time period
contract Dividend is RevSale {

    bool withdrawalActive;
    uint256 withdrawalDuration;
    uint256 dividendBalance;
    uint256 withdrawalTimer;
    uint256 nonce;
    mapping(address => uint256) hasWithdrawn;

    /// @notice Starts a new withdrawal timeframe
    function startWithdrawal() external payable onlyOwner {
        require(!withdrawalActive, "Dividend withdrawal is currently active");
        dividendBalance = address(this).balance;
        withdrawalActive = true;
        withdrawalTimer = now;
        nonce = nonce.add(1);
    }

    /// @notice Allows the user to withdraw tokens
    function withdrawDividend() external {
        require(withdrawalActive, "Dividend withdrawal is currently not active");
        if (now.sub(withdrawalTimer) > withdrawalDuration) {
            endWithdrawal();
        } else {
            require(balanceOf[msg.sender] > 0, "Not a token holder");
            require(hasWithdrawn[msg.sender] < nonce, "User has already withdrawn in this withdrawal period");
            hasWithdrawn[msg.sender] = nonce;
            uint256 dividend = dividendBalance.mul(balanceOf[msg.sender])/totalSupply;
            msg.sender.transfer(dividend);
        }
    }

    /// @notice Ends a withdrawal timeframe
    function endWithdrawal() public {
        require(withdrawalActive, "Dividend withdrawal is currently not active");
        require(now.sub(withdrawalTimer) > withdrawalDuration, "Withdrawal is still running");
        dividendBalance = 0;
        withdrawalActive = false;
    }

    /// @notice overwriting transfer function to halt trading for tokenholders who withdrew
    function transfer(address _to, uint256 _value) public returns (bool success) {
        if (withdrawalActive) {
            if (now.sub(withdrawalTimer) > withdrawalDuration) {
                endWithdrawal();
            } else {
                require(hasWithdrawn[msg.sender] < nonce);
            }
        }
        require(_to != 0x0);
        require(_to != address(this));
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_value);
        balanceOf[_to] = balanceOf[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /// @notice overwriting transferFrom function to halt trading for tokenholders who withdrew
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        if (withdrawalActive) {
            if (now.sub(withdrawalTimer) > withdrawalDuration) {
                endWithdrawal();
            } else {
                require(hasWithdrawn[_from] < nonce);
            }
        }
        require(_to != 0x0);
        require(_to != address(this));
        balanceOf[_to] = balanceOf[_to].add(_value);
        balanceOf[_from] = balanceOf[_from].sub(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }
}

/// @title Constructing contract of the RevToken
/// @author chainge.network
/// @notice Connects the DevToken and the RevToken and initializes the RevToken
/// @dev This is the contract to be deployed; all constructur values are mandatory
contract RevToken is Dividend {
    // constructor
    function RevToken(
        string _name, string _symbol, address _DevTokenAddress,
        uint256 _withdrawalDuration
        ) public {
        // name of the RevToken
        name = _name;
        // symbol of the RevToken
        symbol = _symbol;
        // decimals of the RevToken, fixed to 18
        decimals = 18;

        // set address of DevContract in constructor
        require(_DevTokenAddress != 0x0);
        DevTokenAddress = _DevTokenAddress;

        withdrawalDuration = _withdrawalDuration;
    }
}