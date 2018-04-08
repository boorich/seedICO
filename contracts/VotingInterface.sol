contract Voting_X {
    // allows one proposal at a time per person
    mapping(address => uint256) lastProposal_X;
    // duration of voting on a proposal
    uint256 proposalDuration_X;
    // percentage of minimum votes for proposal to get accepted
    uint256 minVotes_X;
    // constructor
    function Voting_X(uint256 _proposalDuration_X, uint256 _minVotes_X) public {}
    // Events
    // creation event
    event ProposalCreation_X(uint256 indexed ID, string indexed description);
    // vote event
    event UserVote_X(uint256 indexed ID, address indexed user, bool indexed value);
    // successful proposal event
    event SuccessfulProposal_X(uint256 indexed ID, string indexed description, uint256 indexed value);
    // rejected proposal event
    event RejectedProposal_X(uint256 indexed ID, string indexed description, string indexed reason);
    // proposal structure
    struct Proposal_X {
        // ID of proposal
        uint256 ID;
        // short name
        string name;
        // description of proposal
        string description;
        // timestamp when poll started
        uint256 start;
        // collects votes
        uint256 yes;
        uint256 no;
        // mapping that saves if user voted
        mapping(address => bool) voted;
        // bool if poll is active
        bool active;
        // bool if proposal was accepted
        bool accepted;
    }
    // array of polls
    Proposal_X[] public proposals_X;
    // propose a new development task
    // appends proposal struct to array
    // emits ProposalCreation_X event
    function propose_X(string _name, string _description) public {}
    // vote on a development task
    // emits UserVote_X event
    function vote(uint256 _ID, bool _vote) public  {}
    // end voting for a development task
    // emits SuccessfulProposal_X or RejectedProposal_X Event
    function end(uint256 _ID) public {}
}