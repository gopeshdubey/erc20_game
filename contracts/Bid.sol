// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.8.0;
pragma experimental ABIEncoderV2;

interface Information {
    struct Player {
        uint256 user_id;
        string color;
        address user_address;
        uint256 bid_amount;
        string profile_pic;
    }

    event Player_event(
        uint256 user_id,
        string color,
        address user_address,
        uint256 bid_amount,
        string profile_pic
    );

    function bid(
        string calldata _color,
        address _user_address,
        uint256 _bid_amount,
        string calldata _profile_pic
    ) external;

    function get_all_users() external view returns (Player[] memory);
}

contract Bid is Information {

    using SafeMath for uint256;

    address public owner;
    uint256 public user_id;
    uint256 public timer_for_bid;
    uint256 public timer_for_view;
    Player[] player;

    constructor() public {
        owner = msg.sender;
        timer_for_bid = block.timestamp + 60;
        timer_for_view = block.timestamp + 120;
    }

    mapping(uint256 => Player) public players;

    function check_user_exist(address _user_address) internal view returns(bool) {
        for (uint256 i = 0; i < user_id; i++) {
            Player storage trrip = players[i + 1];
            if(trrip.user_address == _user_address){
                return true;
            }
        }
        return false;
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
        user_id++;
        players[user_id] = Player(
            user_id,
            _color,
            _user_address,
            _bid_amount,
            _profile_pic
        );

        emit Player_event(
            user_id,
            _color,
            _user_address,
            _bid_amount,
            _profile_pic
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
