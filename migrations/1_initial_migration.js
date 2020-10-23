var Token = artifacts.require("./Bid.sol");

module.exports = function(deployer) {
  deployer.deploy(Token);
};