pragma solidity 0.4.21;

/**
To Implement: DevTokens are non tradable and only for voting purposes. 
The user can always exchange his DevTokens for RevTokens which are tradable
RevTokens give the right to collect a dividend
 */

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


// Basic ERC20 functions
contract Token {

    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);

    // mapping of all balances
    mapping (address => uint256) public balanceOf;
    // The total supply of the token
    uint256 public totalSupply;

    // Some variables for nice wallet integration
    string public name;          // name of token
    string public symbol;        // symbol of token
    uint8 public decimals;       // decimals of token

    // constructor setting token variables
    function Token(string _name, string _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        require(decimals <= 18);
        decimals = _decimals;
    }
}

// DevToken functions which are active during development phase
contract Funding is Token {

    // address of the developers
    address public owner;
    // maximum supply of the token
    uint256 public maxSupply;
    // time since the last emergency withdrawal
    uint256 public emergencyWithdrawal;
    // maximum stake someone can have of all tokens (in percent)
    uint256 public maxStake;
    // tokens that are being sold per ether
    uint256 public tokensPerEther;

    // constructor setting contract variables
    function DevToken(uint256 _maxSupply, uint256 _maxStake, address _owner, uint256 _tokensPerEther, address[] _owners, uint256[] _balances) public {
        owner = msg.sender;
        emergencyWithdrawal = now;
        maxSupply = _maxSupply;
        // Adjust the token value to variable decimal-counts
        tokensPerEther = _tokensPerEther.div(10**(18 - decimals));
        require(_owners.length == _balances.length);
        for (uint256 i = 0; i < _owners.length; i++) {
            balanceOf[_owners[i]] = tokensPerEther.mul(balanceOf[_owners[i]].add(_balances[i]));
            totalSupply = totalSupply.add(tokensPerEther.mul(_balances[i]));
        }
        require(_maxStake >= totalSupply);
        maxStake = _maxStake;
    }

    // modifiers: only allows Owner/Pool/Contract to call certain functions
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier onlyTokenHolder {
        require(balanceOf[msg.sender] > 0 || msg.sender == address(this));
        // require(!banned[msg.sender]);
        _;
    }

    // lock ETH in contract and return DevTokens
    function () public payable {
        // adds the amount of ETH sent as DevToken value and increases total supply
        balanceOf[msg.sender].add(msg.value.mul(tokensPerEther));
        totalSupply = totalSupply.add(msg.value.mul(tokensPerEther));

        // fails if total supply surpasses maximum supply
        require(totalSupply <= maxSupply);
        // user cannot deposit more than "maxStake"% of the total supply
        require(balanceOf[msg.sender] < totalSupply.mul(maxStake)/100);

        // transfer event
        emit Transfer(address(this), msg.sender, msg.value.mul(tokensPerEther));
    }

    // allows owner to withdraw 1 ether per week in case of an emergency or a malicous attack that prevents developers to access ETH in the contract at all
    function emergencyWithdraw() public onlyOwner {
        if (now.sub(emergencyWithdrawal) > 7 days) {
            emergencyWithdrawal = now;
            owner.transfer(1 ether);
        }
    }
    // constant function: return maximum possible investment per person
    function maxInvestment() public view returns(uint256) {
        return totalSupply.mul(maxStake)/100;
    }


    // Get the number of DevTokens that will be sold for 1 ETH
    function getPrice() view public returns(uint _tokensPerEther) {
        // Adjust the token value to variable decimal-counts
        return tokensPerEther.mul(10**(18-decimals));
    }

}
// voting implementation of DevToken contract
contract Voting is Funding {
    // limits the amount of proposals that can be made at time (optimum 1 proposal at a time, depends on proposal Durations of )
    mapping(address => uint256) lastProposal;
}

contract TaskVoting is Voting {
    // duration of voting on a proposal
    uint256 proposalDuration;
    // percentage of minimum votes for proposal to get accepted
    uint256 minVotes;

    // Events
    // creation event
    event ProposalCreation(uint256 indexed ID, string indexed description);
    // vote event
    event UserVote(uint256 indexed ID, address indexed user, bool indexed value);
    // successful proposal event
    event SuccessfulProposal(uint256 indexed ID, string indexed description, uint256 indexed value);
    // rejected proposal event
    event RejectedProposal(uint256 indexed ID, string indexed description, string indexed reason);

    struct Proposal {
        // ID of proposal
        uint256 ID;
        // description of proposal
        string description;
        // amount of ETH-reward for development tasks
        uint256 value;
        // timestamp when poll started
        uint256 start;
        // collects votes
        uint256 yes;
        uint256 no;
        // mapping that saves if user voted
        mapping(address => bool) voted;
        // bool if poll is active
        bool active;
        //
        bool accepted;
        //
        bool rewarded;
    }

    // array of polls
    Proposal[] public proposals;

    // constructor
    function Voting(uint256 _proposalDuration, uint256 _minVotes) public {
        proposalDuration = _proposalDuration;
        minVotes = _minVotes;
    }

    // propose a new development task
    function propose(string _description, uint256 _value) public onlyTokenHolder {

        require(_value > address(this).balance);
        // allows one proposal per week and resets value after successful proposal
        require(now.sub(lastProposal[msg.sender]) > proposalDuration);
        lastProposal[msg.sender] = now;

        // saves ID of proposal which is equal to the array index
        uint256 ID = proposals.length;

        // initializes new proposal as a struct and pushes it into the proposal array
        proposals.push(Proposal({ID: ID, description: _description, value: _value, start: now, yes: 0, no: 0, active: true}));

        // event generated for proposal creation
        emit ProposalCreation(ID, _description);

    }

    // vote on a development task
    function vote(uint256 _ID, bool _vote) public onlyTokenHolder {

        // proposal has to be active
        require(proposals[_ID].active);

        // proposal has to be active less than one week
        if (now.sub(proposals[_ID].start) >= proposalDuration) {
            end(_ID);
        }

        // checks if tokenholder has already voted
        require(!proposals[_ID].voted[msg.sender]);
        // registers vote
        proposals[_ID].voted[msg.sender] = true;

        // if the value is 0 it's considered no
        if (_vote) {
            // registers the balance of msg.sender as a yes vote
            proposals[_ID].yes = proposals[_ID].yes.add(balanceOf[msg.sender]);
        } else {
            // registers the balance of msg.sender as a no vote
            proposals[_ID].no = proposals[_ID].no.add(balanceOf[msg.sender]);
        }
        // event generated for tokenholder vote
        emit UserVote(_ID, msg.sender, _vote);

    }


    // end voting for a development task
    function end(uint256 _ID) public onlyTokenHolder {

        // requires proposal to be running for a week
        require(now.sub(proposals[_ID].start) >= proposalDuration);

        // requires proposal to be active
        require(proposals[_ID].active);
        proposals[_ID].active = false;

        // rejects proposal if not enough people voted on it
        if (proposals[_ID].no.add(proposals[_ID].yes) < (minVotes.mul(totalSupply)).div(100)) {
            // event generation
            emit RejectedProposal(_ID, proposals[_ID].description, "Participation too low");

        // compares yes and no votes
        } else if (proposals[_ID].yes > proposals[_ID].no) {

            proposals[_ID].accepted = true;

            // event generation
            emit SuccessfulProposal(_ID, proposals[_ID].description, proposals[_ID].value);

        } else {
            // event generation
            emit RejectedProposal(_ID, proposals[_ID].description);
        }
    
    }

    // function returnProposals() view public returns(Proposal[]) {

    //     return proposals;

    // }

}

// DevRevToken combines DevToken and RevToken into one token
contract DevRevToken is TaskVoting {

}