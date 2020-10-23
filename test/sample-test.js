const { expect } = require("chai");

describe("Bid", function() {
  it("Should return the new greeting once it's changed", async function() {
    const Greeter = await ethers.getContractFactory("Bid");
    const greeter = await Greeter.deploy();
    
    var deploy = await greeter.deployed();

    const accounts = await ethers.getSigners()
    var acc1 = await accounts[0].getAddress()
    var acc2 = await accounts[1].getAddress()
    var acc3 = await accounts[2].getAddress()

    // await Array(2).fill().map(() => {
    //   deploy.bid("red", acc, 1234, "qwerty")
    // })
    // BID ON COLOR
    await deploy.bid("red", acc1, 12340, "qwerty")
    // await deploy.bid("green", acc2, 1234, "qwerty")
    await deploy.bid("red", acc3, 12340, "qwerty")
    // GET LAST 10 USERS
    var all_users = await deploy.get_all_users();
    // console.log('all users :::::', all_users);
    // GET RED AND GREEN USERS COUNT
    var red_users = await deploy.get_color_users_count();
    console.log('color_users :::::', red_users);
  });
});
