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
    minVotes: 50,                           // minumum vote participation in percent to end a vote
    ratio_Task: 60                          // ratio of the votes on a proposal that are neccessary to be accepted
};
*/

pragma solidity 0.4.21;

/// @title Interface for Revenue Token
/// @author chainge.network
/// @notice Interaction with the respective counterpart token - the Revenue Token
interface RevToken {
    /// @notice Exchanges a certain amount of DevCoins to RevTokens
    /// @param _tokenAmount The amount of DevTokens that will be converted to RevTokens
    /// @param _tokenHolder The address that will receive the RevTokens
    /// @return true if the swap was successful
    function swap(uint256 _tokenAmount, address _tokenHolder) external returns(bool success);
}

// SafeMath library that automatically checks for overflows and underflows
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

/// @title Basic ERC20 Token
/// @author chainge.network
/// @notice Basic ERC20 functionality, minus the ability to transfer/trade tokens
/// @dev Contains no ERC-20 functions, just the mapping and general variables
contract Token {
    using SafeMath for uint256;

    event Transfer(address indexed from, address indexed to, uint256 value);

    // mapping of all token-balances
    mapping (address => uint256) public balanceOf;

    // the amount of token already issued
    uint256 public totalSupply;

    // variables for nice wallet integration
    string public name;     // name of the token
    string public symbol;   // symbol of the token
    uint8 public decimals;  // decimals of the token
}


/// @title Basic Owned contract
/// @author chainge.network
/// @notice You can use this contract for only the most basic simulation
/// @dev Contains no ERC-20 functions, just the mapping and general variables
contract Owned is Token {
    // address of the owner/developer who deployed the contract
    address public owner;

    // only allow owner to call certain functions
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    // only allow a user with a tokenbalance > 0 to call certain functions
    modifier onlyTokenHolder {
        require(balanceOf[msg.sender] > 0);
        _;
    }
}

/// @title Funding contract for the DevToken
/// @author chainge.network
/// @notice Provides the user with the ability to buy DevCoins for ETH during the funding phase
/// @dev Contains a payable function
contract Funding is Owned {
    // maximum supply of the token
    uint256 public maxSupply;
    // maximum share of all tokens anyone is allowed to hold
    uint256 public maxStake;
    // number of tokens being sold per ETH
    uint256 public tokensPerEth;

    /// @notice Provides the user with `tokensPerEth` per ETH being sent, up to the limit of `maxSupply * maxStake / 100`
    function () public payable {
        // function call needs to send a non-zero amount of ETH
        require(msg.value > 0);

        // adds the amount of bought DevTokens (sent ETH multiplied with tokensPerEth) to the balance of the calling address
        balanceOf[msg.sender] = balanceOf[msg.sender].add(msg.value.mul(tokensPerEth));

        // adds the same amount of DevTokens to the total supply
        totalSupply = totalSupply.add(msg.value.mul(tokensPerEth));

        // the calling address is not allowed to hold more than maxStake (in percent) of the maximum amount of tokens
        require(balanceOf[msg.sender] <= maxSupply.mul(maxStake)/100);

        // the amount of tokens already issued has to be less or equal than the maximum number of tokens  
        require(totalSupply <= maxSupply);

        // emitting the ERC20 Transfer event
        emit Transfer(address(this), msg.sender, msg.value.mul(tokensPerEth));
    }

    /// @notice `totalSupply * maxStake / 100` is currently the maximum amount any address can hold
    /// @return maxStake (in percent) of the current amount of tokens already issued
    function maxInvestment() public view returns(uint256) {
        return totalSupply.mul(maxStake)/100;
    }
}

/// @title Allowance of the owner
/// @author chainge.network
/// @notice Allows the owner to withdraw a certain amount of ETH in each specified timeframe
contract OwnerAllowance is Funding {
    // time of last use of the allowance
    uint256 public allowanceTimeCounter;

    // reset interval of the allowance
    uint256 public allowanceInterval;

    // allowance amount per interval
    uint256 public allowanceValue;

    // remaining balance of the total allowance value in the current interval
    uint256 public allowanceBalance;

    /// @notice The owner is able to withdraw `allowanceValue` every `allowanceInterval` seconds
    /// @param _value The amount of ETH that the owner wishes to withdraw
    function allowanceWithdrawal(uint256 _value) public onlyOwner {
        uint256 value = _value * 10 ** 18;
        // If the time that has passed since the last use of the allowance exceeds the interval
        if (now.sub(allowanceTimeCounter) > allowanceInterval) {
            // resetting the balance to the allowance amount per interval
            allowanceBalance = allowanceValue;

            // resetting the time of the last use to now
            allowanceTimeCounter = now;
        }
        // subtracting the desired amount of ETH from the current balance
        allowanceBalance = allowanceBalance.sub(value);

        // transferring the desired amount of ETH to the owners address
        owner.transfer(value);
    }
}

/// @title Voting contract for tasks
/// @author chainge.network
/// @notice Allows all token-holders to propose and vote on tasks
contract Voting_Task is OwnerAllowance {
    // mapping of an address to the time of its last proposal (only one proposal at a time per address)
    mapping(address => uint256) lastProposal_Task;

    // duration of a proposal in seconds
    uint256 proposalDuration_Task;

    // percentage of minimum votes for proposal to get accepted
    uint256 minVotes_Task;

    // threshold (in percent) of votes for a proposal to be accepted
    uint256 ratio_Task;

    // event: a new task was proposed to be voted on (contains the ID of the porposal and its description)
    event ProposalCreation_Task(uint256 indexed ID, string description);
    // event: a user voted on a proposed task (contains the ID of the porposal, the address of the user, his vote and his balance)
    event UserVote_Task(uint256 indexed ID, address user, bool vote, uint256 balance);
    // event: a task proposal was successful (contains the ID of the porposal, its description and the value in ETH)
    event SuccessfulProposal_Task(uint256 indexed ID, string description, uint256 value);
    // event: a task proposal was rejected (contains the ID of the porposal, its description and the reason of the rejection)
    event RejectedProposal_Task(uint256 indexed ID, string description, string reason);

    struct Proposal_Task {
        uint256 ID;                     // id of the proposed task
        string name;                    // name of the proposed task
        string description;             // description of the proposed task
        uint256 value;                  // (optional) amount of ETH-reward for the proposed tasks
        uint256 start;                  // starting timestamp of the proposal
        uint256 yes;                    // yes-votes (in tokens) of the proposal
        uint256 no;                     // no-votes (in tokens) of the proposal
        mapping(address => bool) voted; // mapping to check whether an address has already voted or not
        bool active;                    // true if the proposal is still active, otherwise false
        bool accepted;                  // true if the proposal has been accepted, otherwise false
        bool rewarded;                  // (optional) true if proposal was rewarded, otherwise false
    }

    // array of all proposals
    Proposal_Task[] public proposals_Task;

    /// @notice Propose a new task as a token-holder 
    /// @param _name The name of the proposed task
    /// @param _description The description of the proposed task
    /// @param _value The value of the proposed task in ETH
    function propose_Task(string _name, string _description, uint256 _value) external onlyTokenHolder {
        uint256 value = _value * 10 ** 18;
        // the ETH balance of the contract has to be at least the same as the value of the proposed task 
        require(value <= address(this).balance);

        // allows one proposal per interval for each token-holder
        require(now.sub(lastProposal_Task[msg.sender]) > proposalDuration_Task);

        // sets the time of the last proposal for the caller to now
        lastProposal_Task[msg.sender] = now;

        // saves the ID of a proposal which is equal to the current array length
        uint256 ID = proposals_Task.length;

        // initializes new proposal as a struct and pushes it into the proposal array
        proposals_Task.push(Proposal_Task({ID: ID, name: _name, description: _description, value: value, start: now, yes: 0, no: 0, active: true, accepted: false, rewarded: false}));

        // event emitted for proposal creation
        emit ProposalCreation_Task(ID, _description);

    }

    /// @notice Vote on an active proposal for a development task 
    /// @param _ID The ID of the proposal
    /// @param _vote The decision of the caller regarding the proposed task 
    function vote_Task(uint256 _ID, bool _vote) external onlyTokenHolder {
        // proposal has to be active
        require(proposals_Task[_ID].active);

        // if the proposal has been active for a longer time than the allowed duration of a task-proposal
        if (now.sub(proposals_Task[_ID].start) >= proposalDuration_Task) {
            // ending of the proposal
            end_Task(_ID);
        }

        // checks if tokenholder has already voted
        require(!proposals_Task[_ID].voted[msg.sender]);

        // registers vote
        proposals_Task[_ID].voted[msg.sender] = true;

        // if the value of _vote is false it's considered no
        if (_vote) {
            // registers the balance of msg.sender as a yes vote
            proposals_Task[_ID].yes = proposals_Task[_ID].yes.add(balanceOf[msg.sender]);
        } else {
            // registers the balance of msg.sender as a no vote
            proposals_Task[_ID].no = proposals_Task[_ID].no.add(balanceOf[msg.sender]);
        }
        // event emitted for token-holder vote
        emit UserVote_Task(_ID, msg.sender, _vote, balanceOf[msg.sender]);

    }


    /// @notice Ending an active proposal for a development task 
    /// @param _ID The ID of the proposal
    function end_Task(uint256 _ID) public onlyTokenHolder {
        // the proposal has been active for a longer time than the allowed duration of a task-proposal
        require(now.sub(proposals_Task[_ID].start) >= proposalDuration_Task);

        // requires proposal to be active
        require(proposals_Task[_ID].active);

        // sets the proposal to be inactive
        proposals_Task[_ID].active = false;

        // rejects proposal if not enough people voted on it
        // (sum of all balances that voted need is smaller than the percentage of minimum votes of the currently issued token count)
        if (proposals_Task[_ID].no.add(proposals_Task[_ID].yes) < (minVotes_Task.mul(totalSupply))/100) {
            // event emitted for a rejected proposal
            emit RejectedProposal_Task(_ID, proposals_Task[_ID].description, "Participation too low");
        } else {
            // 100 percent (for calculation purposes)
            uint256 max = 100;

            // compares yes and no votes
            if (proposals_Task[_ID].yes.mul(max.sub(ratio_Task)) >= proposals_Task[_ID].no.mul(ratio_Task)) {
                // vote has been accepted
                proposals_Task[_ID].accepted = true;
                // event emitted for a successfull proposal
                emit SuccessfulProposal_Task(_ID, proposals_Task[_ID].description, proposals_Task[_ID].value);
                // value of the proposed task will be paid to the owner
                payReward_Task(_ID);
            } else {
                 // event emitted for a rejected proposal
                emit RejectedProposal_Task(_ID, proposals_Task[_ID].description, "Proposal rejected by vote");
            }
        }
    }

    /// @notice Sending the amount of ETH of an accepted proposal to the owner 
    /// @param _ID The ID of the proposal
    function payReward_Task(uint256 _ID) public {
        // proposal has to be accepted and not been rewarded
        require(proposals_Task[_ID].accepted && !proposals_Task[_ID].rewarded);
        // set proposal to be rewarded
        proposals_Task[_ID].rewarded = true;
        // send the value of the proposal to the owners address
        owner.transfer(proposals_Task[_ID].value);
    }

    /// @return The amount of proposals (past and current)
    function getProposalLength_Task() public view returns(uint256 length) {
        return proposals_Task.length;
    }

    /// @param _ID The ID of the proposal
    /// @return The name of a proposal
    function getProposalName_Task(uint256 _ID) public view returns(string name) {
        return proposals_Task[_ID].name;
    }

    /// @param _ID The ID of the proposal
    /// @return The description of a proposal
    function getProposalDescription_Task(uint256 _ID) public view returns(string description) {
        return proposals_Task[_ID].description;
    }

    /// @param _ID The ID of the proposal
    /// @return The value (in ETH) of a proposal
    function getProposalValue_Task(uint256 _ID) public view returns(uint256 value) {
        return proposals_Task[_ID].value;
    }

    /// @param _ID The ID of the proposal
    /// @return The starting timestamp of a proposal
    function getProposalStart_Task(uint256 _ID) public view returns(uint256 start) {
        return proposals_Task[_ID].start;
    }

    /// @param _ID The ID of the proposal
    /// @return The amount of tokens that voted for yes on a proposal
    function getProposalYes_Task(uint256 _ID) public view returns(uint256 yes) {
        return proposals_Task[_ID].yes;
    }

    /// @param _ID The ID of the proposal
    /// @return The amount of tokens that voted for no on a proposal
    function getProposalNo_Task(uint256 _ID) public view returns(uint256 no) {
        return proposals_Task[_ID].no;
    }

    /// @param _ID The ID of the proposal
    /// @return True if the proposal is still active (can be voted on), otherwise false
    function getProposalActive_Task(uint256 _ID) public view returns(bool active) {
        return proposals_Task[_ID].active;
    }

    /// @param _ID The ID of the proposal
    /// @return True if the proposal has been accepted through voting, otherwise false
    function getProposalAccepted_Task(uint256 _ID) public view returns(bool accepted) {
        return proposals_Task[_ID].accepted;
    }

    /// @param _ID The ID of the proposal
    /// @return True if the proposed value (in ETH) has been rewarded to the owner active, otherwise false
    function getProposalRewarded_Task(uint256 _ID) public view returns(bool rewarded) {
        return proposals_Task[_ID].rewarded;
    }
}

/// @title Contract to interact between Dev- and RevTokens
/// @author chainge.network
/// @notice Allows DevToken-holders to swap to RevTokens
contract DevRev is Voting_Task {
    // bool to see if RevToken contract address was already set
    bool private set = false;

    // the address of the RevToken contract
    address public RevTokenAddress;

    /// @notice Allows the owner of the DevToken contract to set the address of the RevToken contract once
    /// @param _contractAddress The address of the RevToken contract
    function setRevContract(address _contractAddress) public onlyOwner {
        // check whether the RevToken address has already been set and the address is not 0x0
        require(!set && _contractAddress != 0x0);
        
        // address has been set now
        set = true;
        
        // setting the address of the 
        RevTokenAddress = _contractAddress;
    }

    /// @notice Allows the DevToken holders to swap their tokens to RevTokens
    /// @param _tokenAmount The amount of DevTokens that will be swapped to RevTokens
    function swap(uint256 _tokenAmount) public onlyTokenHolder {
        // the address of the RevToken contract has to be set
        require(set);

        // subtracting the amount of swapped tokens from the DevToken balance
        balanceOf[msg.sender] = balanceOf[msg.sender].sub(_tokenAmount);

        // subtracting the amount of swapped tokens from the total issued DevTokens
        totalSupply = totalSupply.sub(_tokenAmount);

        // subtracting the amount of swapped tokens from the maximum amount of DevTokens
        maxSupply = maxSupply.sub(_tokenAmount);

        // requires the call of the corresponding swap function in the RevToken contract to execute successfully
        require(RevToken(RevTokenAddress).swap(_tokenAmount, msg.sender));

        // emitting the ERC20 Transfer event
        emit Transfer(msg.sender, RevTokenAddress, _tokenAmount);
    }

}

/// @title TO BE DONE
/// @author chainge.network
/// @notice TO BE DONE
contract KYC is DevRev {
    /// @return the amount of tokens that are already issued
    function shareCap() public view returns (uint256 currentShareCap) {
        return totalSupply;
    }

}

/// @title Constructing contract of the DevToken and the RevToken
/// @author chainge.network
/// @notice Connects the DevToken and the RevToken
/// @dev This is the contract to be deployed; all constructur values are mandatory
contract DevToken is KYC {
    /// @notice Constructor of the DevToken that is being deployed
    /// @dev All constructur values are mandatory
    /// @param _name Name of the token
    /// @param _symbol Symbol of the token
    /// @param _maxSupply Maximum number of tokens
    /// @param _maxStake Percentage of tokens anyone can hold
    /// @param _tokensPerEth Tokens bought per ether
    /// @param _owners Array of owner/founder accounts
    /// @param _balances Array of balances of the indiviual owners/founders
    /// @param _allowanceInterval Interval of the owner allowance in seconds
    /// @param _allowanceValue Value of the owner allowance
    /// @param _proposalDuration_Task Duration of a proposal/vote
    /// @param _minVotes_Task Minumum vote participation in percent to end a vote
    /// @param _ratio_Task Ratio of the votes on a proposal that are neccessary to be accepted
    function DevToken(
        // arguments of the DevToken
        string _name, string _symbol,
        // arguments Funding
        uint256 _maxSupply, uint256 _maxStake, uint256 _tokensPerEth, address[] _owners, uint256[] _balances,
        // arguments OwnerAllowance
        uint256 _allowanceInterval, uint256 _allowanceValue,
        // arguments TaskVoting
        uint256 _proposalDuration_Task, uint256 _minVotes_Task, uint256 _ratio_Task
        ) public {

        // constructor: Token
        name = _name;
        symbol = _symbol;
        decimals = 18;

        // constructor: Additional Token-Variables
        owner = msg.sender;
        uint256 maxvalue = _maxSupply * 10 ** 18;
        maxSupply = maxvalue;

        // at least 1 Token should be received per ETH/Wei
        require(_tokensPerEth > 0);
        tokensPerEth = _tokensPerEth;

        // the length of the owners array needs to be the same as their balances-array
        require(_owners.length == _balances.length);

        // loop over said arrays
        for (uint256 i = 0; i < _owners.length; i++) {
            uint256 value = _balances[i] * 10 ** 18;
            // Adding the specified amount of tokens to their balances
            balanceOf[_owners[i]] = balanceOf[_owners[i]].add(value);
            // Increasing the count of issued tokes accordingly
            totalSupply = totalSupply.add(value);
            // emitting the ERC20-Transfer event
            emit Transfer(address(this), _owners[i], value);
        }

        // maximum number of tokens has to be greater than or equal to the currently issued token count
        require(maxSupply >= totalSupply);

        // percentage of tokens anyone can hold needs to be a value from 1 to 100
        require(_maxStake > 0 && _maxStake <= 100);        
        maxStake = _maxStake;

        // constructor: OwnerAllowance
        allowanceTimeCounter = now;
        allowanceInterval = _allowanceInterval;
        uint256 avalue = _allowanceValue * 10 ** 18;
        allowanceValue = avalue;
        allowanceBalance = avalue;

        // constructor: TaskVoting
        proposalDuration_Task = _proposalDuration_Task;
        minVotes_Task = _minVotes_Task;
        // percentage of votes neccessary to succeed with a proposal needs to be a value from 1 to 100 
        require(_ratio_Task > 0 && _ratio_Task <= 100);
        ratio_Task = _ratio_Task;
    }
}
