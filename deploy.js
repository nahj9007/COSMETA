// migrations/2_deploy.js
const CRI = artifacts.require('cri');

module.exports = async function (deployer) {
  await deployer.deploy('CryptoInternational', 'CRI', 2e27, 86400);
};
