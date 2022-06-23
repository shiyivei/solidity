const Auth = artifacts.require("Auth");
const Box = artifacts.require("Box");

module.exports = function (deployer) {
  deployer.then(async () => {
    await deployer.deploy(Auth);
    await deployer.deploy(Box, Auth.address);
  });
};
