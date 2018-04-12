/*
DevToken - Documentation

Contract to deploy: DevToken

Arguments (with example-values):
{   name: "DevToken",                       // Name of the token
    symbol: "DVT",                          // Symbol of the token
    maxSupply: web3.toWei(100, 'ether'),    // max number of tokens
    maxStake: 25,                           // percentage of tokens anyone can hold
    tokensPerEther: 5,                      // tokens bought per ether
    owners: [                               // array of owner/founder accounts
        web3.eth.accounts[0],
    ],
    balances: [                             // balances of the indiviual owners/founders
        web3.toWei(20, 'ether'),
    ],
    allowanceInterval: 60,                  // interval of the owner allowance in seconds
    allowanceValue: web3.toWei(1, 'ether'), // value of the owner allowance
    proposalDuration: 60,                   // duration of a proposal/vote
    minVotes: 50                               // minumum vote participation in percent to end a vote
};
*/

pragma solidity 0.4.21;

interface RevToken {
    function swap(uint256 _tokenAmount, address _tokenHolder) external returns(bool success);
}

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
}

contract Owned is Token {
    // address of the developers
    address public owner;
    // modifiers: only allows Owner/Pool/Contract to call certain functions
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    modifier onlyTokenHolder {
        require(balanceOf[msg.sender] > 0);
        _;
    }
}

// DevToken functions which are active during development phase
contract Funding is Owned {

    // maximum supply of the token
    uint256 public maxSupply;
    // maximum stake someone can have of all tokens (in percent)
    uint256 public maxStake;
    // tokens that are being sold per ether
    uint256 public tokensPerEth;

    // lock ETH in contract and return DevTokens
    function () public payable {
        require(msg.value > 0);

        // adds the amount of ETH sent as DevToken value and increases total supply
        balanceOf[msg.sender] = balanceOf[msg.sender].add(msg.value.mul(tokensPerEth));
        totalSupply = totalSupply.add(msg.value.mul(tokensPerEth));

        // user cannot deposit more than "maxStake"% of the total supply
        require(balanceOf[msg.sender] <= maxSupply.mul(maxStake)/100);
        // fails if total supply surpasses maximum supply
        require(totalSupply <= maxSupply);

        // transfer event
        emit Transfer(address(this), msg.sender, msg.value.mul(tokensPerEth));
    }

    // constant function: return maximum possible investment per person
    function maxInvestment() public view returns(uint256) {
        return totalSupply.mul(maxStake)/100;
    }
}

contract OwnerAllowance is Funding {
    // time since last use of allowance
    uint256 public allowanceTimeCounter;
    // interval how often allowance is reset
    uint256 public allowanceInterval;
    // allowance amount per interval
    uint256 public allowanceValue;
    // current allowance balance
    uint256 public allowanceBalance;

    // allows owner to withdraw ether in an interval
    function allowanceWithdrawal(uint256 _value) public onlyOwner {
        if (now.sub(allowanceTimeCounter) > allowanceInterval) {
            allowanceBalance = allowanceValue;
            allowanceTimeCounter = now;
        }
        allowanceBalance = allowanceBalance.sub(_value);
        owner.transfer(_value);
    }
}

// task voting implementation
contract Voting_Task is OwnerAllowance {

    mapping(address => uint256) lastProposal_Task;
    uint256 proposalDuration_Task;
    uint256 minVotes_Task;
    uint256 ratio_Task;

    event ProposalCreation_Task(uint256 indexed ID, string description);
    event UserVote_Task(uint256 indexed ID, address user, bool value);
    event SuccessfulProposal_Task(uint256 indexed ID, string description, uint256 value);
    event RejectedProposal_Task(uint256 indexed ID, string description, string reason);

    struct Proposal_Task {
        uint256 ID;
        string name;
        string description;
        // (optional) amount of ETH-reward for development tasks
        uint256 value;
        uint256 start;
        uint256 yes;
        uint256 no;
        mapping(address => bool) voted;
        bool active;
        bool accepted;
        // (optional) bool if proposal was rewarded
        bool rewarded;
    }

    // array of polls
    Proposal_Task[] public proposals_Task;

    function propose_Task(string _name, string _description, uint256 _value) external onlyTokenHolder {

        require(_value <= address(this).balance);
        // allows one proposal per week and resets value after successful proposal
        require(now.sub(lastProposal_Task[msg.sender]) > proposalDuration_Task);
        lastProposal_Task[msg.sender] = now;

        // saves ID of proposal which is equal to the array index
        uint256 ID = proposals_Task.length;

        // initializes new proposal as a struct and pushes it into the proposal array
        proposals_Task.push(Proposal_Task({ID: ID, name: _name, description: _description, value: _value, start: now, yes: 0, no: 0, active: true, accepted: false, rewarded: false}));

        // event generated for proposal creation
        emit ProposalCreation_Task(ID, _description);

    }

    // vote on a development task
    function vote_Task(uint256 _ID, bool _vote) external onlyTokenHolder {

        // proposal has to be active
        require(proposals_Task[_ID].active);

        // proposal has to be active less than one week
        if (now.sub(proposals_Task[_ID].start) >= proposalDuration_Task) {
            end_Task(_ID);
        }

        // checks if tokenholder has already voted
        require(!proposals_Task[_ID].voted[msg.sender]);
        // registers vote
        proposals_Task[_ID].voted[msg.sender] = true;

        // if the value is 0 it's considered no
        if (_vote) {
            // registers the balance of msg.sender as a yes vote
            proposals_Task[_ID].yes = proposals_Task[_ID].yes.add(balanceOf[msg.sender]);
        } else {
            // registers the balance of msg.sender as a no vote
            proposals_Task[_ID].no = proposals_Task[_ID].no.add(balanceOf[msg.sender]);
        }
        // event generated for tokenholder vote
        emit UserVote_Task(_ID, msg.sender, _vote);

    }


    // end voting for a development task
    function end_Task(uint256 _ID) public onlyTokenHolder {

        // requires proposal to be running for a week
        require(now.sub(proposals_Task[_ID].start) >= proposalDuration_Task);

        // requires proposal to be active
        require(proposals_Task[_ID].active);
        proposals_Task[_ID].active = false;

        // rejects proposal if not enough people voted on it
        if (proposals_Task[_ID].no.add(proposals_Task[_ID].yes) < (minVotes_Task.mul(totalSupply))/100) {
            // event generation
            emit RejectedProposal_Task(_ID, proposals_Task[_ID].description, "Participation too low");
        } else {
            uint256 max = 100;
            // compares yes and no votes
            if (proposals_Task[_ID].yes.mul(max.sub(ratio_Task)) >= proposals_Task[_ID].no.mul(ratio_Task)) {
                proposals_Task[_ID].accepted = true;
                // event generation
                emit SuccessfulProposal_Task(_ID, proposals_Task[_ID].description, proposals_Task[_ID].value);
                payReward_Task(_ID);
            } else {
                // event generation
                emit RejectedProposal_Task(_ID, proposals_Task[_ID].description, "Proposal rejected by vote");
            }
        }
    }

    function payReward_Task(uint256 _ID) public {
        require(proposals_Task[_ID].accepted && !proposals_Task[_ID].rewarded);
        proposals_Task[_ID].rewarded = true;
        owner.send(proposals_Task[_ID].value);
    }

    function getProposalLength_Task() public view returns(uint256 length) {
        return proposals_Task.length;
    }

    function getProposalName_Task(uint256 _ID) public view returns(string name) {
        return proposals_Task[_ID].name;
    }

    function getProposalDescription_Task(uint256 _ID) public view returns(string description) {
        return proposals_Task[_ID].description;
    }

    function getProposalValue_Task(uint256 _ID) public view returns(uint256 value) {
        return proposals_Task[_ID].value;
    }

    function getProposalStart_Task(uint256 _ID) public view returns(uint256 start) {
        return proposals_Task[_ID].start;
    }

    function getProposalYes_Task(uint256 _ID) public view returns(uint256 yes) {
        return proposals_Task[_ID].yes;
    }

    function getProposalNo_Task(uint256 _ID) public view returns(uint256 no) {
        return proposals_Task[_ID].no;
    }

    function getProposalActive_Task(uint256 _ID) public view returns(bool active) {
        return proposals_Task[_ID].active;
    }

    function getProposalAccepted_Task(uint256 _ID) public view returns(bool accepted) {
        return proposals_Task[_ID].accepted;
    }

    function getProposalRewarded_Task(uint256 _ID) public view returns(bool rewarded) {
        return proposals_Task[_ID].rewarded;
    }
}

contract DevRev is Voting_Task {
    // bool to see if RevToken was set
    bool private set = false;
    address public RevTokenAddress;

    function setRevContract(address _contractAddress) public onlyOwner {
        require(!set && _contractAddress != 0x0);
        set = true;
        RevTokenAddress = _contractAddress;
    }

    function swap(uint256 _tokenAmount) public onlyTokenHolder {
        require(set);
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_tokenAmount);
        totalSupply = totalSupply.sub(_tokenAmount);
        maxSupply = maxSupply.sub(_tokenAmount);
        require(RevToken(RevTokenAddress).swap(_tokenAmount, msg.sender));
        emit Transfer(msg.sender, RevTokenAddress, _tokenAmount);
    }

}

// DevRevToken combines DevToken and RevToken into one token
contract DevToken is DevRev {
    function DevToken(
        // arguments Token
        string _name, string _symbol,
        // arguments Funding
        uint256 _maxSupply, uint256 _maxStake, uint256 _tokensPerEth, address[] _owners, uint256[] _balances,
        // arguments OwnerAllowance
        uint256 _allowanceInterval, uint256 _allowanceValue,
        // arguments TaskVoting
        uint256 _proposalDuration_Task, uint256 _minVotes_Task, uint256 _ratio_Task
        ) public {

        // constructor Token
        name = _name;
        symbol = _symbol;
        decimals = 18;
        // constructor Funding
        owner = msg.sender;
        maxSupply = _maxSupply;
        require(_tokensPerEth > 0);
        tokensPerEth = _tokensPerEth;
        require(_owners.length == _balances.length);
        for (uint256 i = 0; i < _owners.length; i++) {
            balanceOf[_owners[i]] = balanceOf[_owners[i]].add(_balances[i]);
            totalSupply = totalSupply.add(_balances[i]);
            emit Transfer(address(this), _owners[i], _balances[i]);
        }
        require(_maxSupply >= totalSupply);
        require(_maxStake > 0 && _maxStake <= 100);
        maxStake = _maxStake;
        // constructor OwnerAllowance
        allowanceTimeCounter = now;
        allowanceInterval = _allowanceInterval;
        allowanceValue = _allowanceValue;
        allowanceBalance = _allowanceValue;
        // constructor TaskVoting
        proposalDuration_Task = _proposalDuration_Task;
        minVotes_Task = _minVotes_Task;
        require(_ratio_Task > 0 && _ratio_Task <= 100);
        ratio_Task = _ratio_Task;
    }
}
