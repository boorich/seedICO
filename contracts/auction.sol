pragma solidity ^0.4.0;

contract Auction {
  //Who gets the money at the auction end
  address public beneficiary;
  uint public auctionStart; //Time in seconds from 1970
  uint public biddingTime; //Time in seconds for the duration of the auction

  address public highestBidder;
  uint public highestBid;

  // adresses that may withdraw their bids (i.e., losers)
  mapping(address => uint) pendingReturns;

  // bool flag to mark auction end
  bool ended;

  // Events that will be fired on changes.
  event HighestBidIncreased(address bidder, uint amount);
  event AuctionEnded(address winner, uint amount);

  /// Create a simple auction with `_biddingTime`
  /// seconds bidding time on behalf of the
  /// beneficiary address `_beneficiary`.
  function Auction(
      uint _biddingTime,
      address _beneficiary
  ) public {
    beneficiary = _beneficiary;
    auctionStart = now;
    biddingTime = _biddingTime;
  }

  function getWinner() public constant returns(address){
    require(ended);
    return highestBidder;
  }


  /// Bid on the auction with the value sent
  /// together with this transaction.
  /// The value will only be refunded if the
  /// auction is not won.
  function bid() payable public{
    //Check if auction is still running, else return eth
    require(now > auctionStart + biddingTime);

    //Check whether bid is high enough, else return eth
    require(msg.value <= highestBid);
    if (highestBidder != 0) {
      //For security reasons: Don't send the eth back to the former highest bidder
      //(Callstack 1023 exploit)
      //Let him withdraw instead
      pendingReturns[highestBidder] += highestBid;
    }
    highestBidder = msg.sender;
    highestBid = msg.value;
    emit HighestBidIncreased(msg.sender, msg.value);
  }

  /// Withdraw a bid that was overbid.
  function withdraw() public returns (bool) {
    uint256 amount = pendingReturns[msg.sender];
    if (amount > 0) {
      // Set it to zero
      pendingReturns[msg.sender] = 0;

      if (!msg.sender.send(amount)) {
        // No throw, just reset amount
        pendingReturns[msg.sender] = amount;
        return false;
      }
    }
    return true;
  }

  /// End the auction and send the highest bid
  /// to the beneficiary.
  function auctionEnd() public{

    require(now <= auctionStart + biddingTime);
    require(ended);

    ended = true;
    emit AuctionEnded(highestBidder, highestBid);

    require(!beneficiary.send(highestBid));
  }
}
