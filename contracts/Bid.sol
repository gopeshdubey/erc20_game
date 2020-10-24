// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;
pragma experimental ABIEncoderV2;

contract Bid {

    using SafeMath for uint256;

    address public owner;
    uint256 public user_id;
    uint256 public timer_for_bid;
    uint256 public timer_for_view;
    uint256 public total_amount;
    uint256 public owner_profit;
    uint256 public users_profit;

    struct Player {
        uint256 user_id;
        string color;
        address user_address;
        uint256 bid_amount;
        string profile_pic;
        bool is_winner;
        uint256 withdrawable_amount;
    }

    event Player_event(
        uint256 user_id,
        string color,
        address user_address,
        uint256 bid_amount,
        string profile_pic,
        bool is_winner,
        uint256 withdrawable_amount
    );

    struct PlayersToken {
        address user_address;
        uint256 tokens;
    }

    event PlayersToken_event (
        address user_address,
        uint256 tokens
    );

    event Started(
        string status
    );

    event Transfer_profit(
        uint256 total_amount
    );

    Player[] player;

    constructor() public {
        owner = msg.sender;
    }

    mapping(uint256 => Player) public players;
    mapping(address => PlayersToken) public player_token;

    function start_game() public {
        require(msg.sender == owner, "Must be admin");
        timer_for_bid = block.timestamp + 60;
        timer_for_view = block.timestamp + 120;

        emit Started("Success");
    }

    function check_user_exist(address _user_address) internal view returns(bool) {
        for (uint256 i = 0; i < user_id; i++) {
            Player storage trrip = players[i + 1];
            if(trrip.user_address == _user_address){
                return true;
            }
        }
        return false;
    }

    function check_user_amount(address _user_address, uint256 _amount) internal view returns(bool) {
        PlayersToken storage player_tok = player_token[_user_address];
        if (player_tok.tokens >= _amount) {
            return true;
        } else {
            return false;
        }
    }

    function bid(
        string memory _color,
        address _user_address,
        uint256 _bid_amount,
        string memory _profile_pic
    ) public {
        require(!check_user_exist(_user_address), "Already a user");
        require(timer_for_bid >= block.timestamp, "Times up");
        require(_bid_amount.mod(10) == 0, "Must be multiple of 10");
        require(check_user_amount(_user_address, _bid_amount), "Must have enough token");
        user_id++;
        players[user_id] = Player(
            user_id,
            _color,
            _user_address,
            _bid_amount,
            _profile_pic,
            false,
            0
        );
        total_amount = total_amount + _bid_amount;
        emit Player_event(
            user_id,
            _color,
            _user_address,
            _bid_amount,
            _profile_pic,
            false,
            0
        );
    }

    function get_all_users() external view returns (Player[] memory) {
        require(timer_for_view >= block.timestamp, "Times up");
        Player[] memory trrips = new Player[](user_id > 10 ? 10 : user_id);
        uint256 limit = 0;
        if (user_id > 10) {
            limit = user_id.sub(10);
        } else {
            limit = 0;
        }
        uint256 j = 0;
        for (uint256 i = limit; i < user_id; i++) {
            Player storage trrip = players[i + 1];
            trrips[j] = trrip;
            j++;
        }
        return (trrips);
    }

    function get_color_users_count() external view returns(uint256, uint256) {
        uint256 red_length;
        uint256 green_length;
        for (uint256 i = 0; i < user_id; i++) {
            Player storage trrip = players[i + 1];
            if(keccak256(abi.encodePacked(trrip.color)) == keccak256(abi.encodePacked('red'))) {
                red_length++;
            }
            if(keccak256(abi.encodePacked(trrip.color)) == keccak256(abi.encodePacked('green'))) {
                green_length++;
            }
        }
        return (red_length, green_length);
    }

    function winner(string memory _winner_color) public {
        require(owner == msg.sender, "Must be owner");
        owner_profit = total_amount.mul(20).div(100);
        for (uint256 i = 0; i < user_id; i++) {
            Player storage trrip = players[i + 1];
            if(keccak256(abi.encodePacked(trrip.color)) == keccak256(abi.encodePacked(_winner_color))) {
                trrip.is_winner = true;
            } else {
                trrip.is_winner = false;
            }
        }
        emit Started("Success");
    }

    function transfer_profit_of_users(uint256 _uid) public {
        uint256 bets = players[_uid].bid_amount;
        uint256 player_share = total_amount.mul(80).div(100);
        uint256 amount = bets.div(player_share).mul(bets);
        Player storage trrip = players[_uid];
        require(trrip.is_winner == true, "You are not eligible");
        trrip.withdrawable_amount = trrip.withdrawable_amount + amount;
        trrip.is_winner = false;
        emit owner_profit(amount);
    }

    function check_withdrawable_amount(uint256 _uid) view returns (uint256) {
        Player storage trrip = players[_uid];
        return trrip.withdrawable_amount;
    }
    
}

// truffle console
// Bid.deployed().then(i => token = i)
// token.players(1)
// web3.eth.getAccounts().then(i => acc = i)
// token.bid("red", acc[0], 1234, "qwerty").then(s => totalSupply = s)
// token.get_all_users().then(s => totalSupply = s)

// library for maths calculations
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a % b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
}
