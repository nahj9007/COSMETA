// contracts/SimpleToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.6.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title CRI
 * @dev CRI is the token for Crypto International
 * All rights reserved by Crypto International Inc.
 */
contract CRI is ERC20 {
    address private _owner;
    uint256 private _reward;
    uint256 private _reward_period;

    mapping (address => uint256) private _balances;
    mapping (address => uint256) private _restricted_ts;
    mapping (address => uint256) private _restricted_units;
    mapping (address => uint256) private _stakes;
    mapping (address => uint256) private _stake_ts;

    /**
     * @dev Constructor that gives _msgSender() all of existing tokens.
     *
     * - `initialSupply` and `initialReward` should have the unit of 1e-18.
     *
     */
    constructor(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        uint256 initialReward,
        uint32 rewardPeriod
    ) ERC20(name, symbol) {
        _owner = _msgSender();
        _reward = initialReward;
        _reward_period = rewardPeriod;
        _mint(_msgSender(), initialSupply);
    }

    /**
     * @dev adjusts the per-day reward value per token.
     *
     * - `reward` should have the unit of 1e-18
     *
     */
    function setReward(uint256 reward) public {
      require(_msgSender() == _owner);
      _reward = reward;
    }

    /**
     * @dev mints new tokens.
     *
     * - `amount` specifies amount of tokens to be minted (in 1e-18).
     *
     */
    function mint(uint256 amount) public {
      require(_msgSender() == _owner);
      _mint(_msgSender(), amount);
    }

    /**
     * @dev rewards sender rewards for holding their tokens.
     *
     * CRI wallets can choose to obtain daily reward for tokens they are
     * currently holding. Wallet holders can specify any amount equals to or
     * below their balance to get reward for. Please note that by getting
     * reward, the specified portion of their balance will be locked.
     *
     */
    function getReward() public {
      require(_stake_ts[_msgSender()] <= block.timestamp - _reward_period, "CRI: need to keep stake for at least a day.");

      uint256 unit_reward = _stakes[_msgSender()] * _reward / 1e6;
      uint256 units = (block.timestamp - _stake_ts[_msgSender()]) / _reward_period;

      _stake_ts[_msgSender()] += units * _reward_period;
      _mint(_msgSender(), unit_reward * units);
    }

    /**
     * @dev put tokens into staking.
     *
     * CRI allows user to obtain reward by participating in staking. Users need
     * to explicitly add their tokens for staking to be able to receive reward.
     *
     * - `amount` specifies amount of tokens to add stake for.
     *
     */
    function putStake(uint256 amount) public {
      require(_balances[_msgSender()] >= amount, "CRI: Not enough balance");
      require(_stakes[_msgSender()] == 0, "CRI: Must empty stake first");
      _stakes[_msgSender()] = amount;
      _stake_ts[_msgSender()] = block.timestamp;
      _balances[_msgSender()] -= amount;
    }

    /**
     * @dev retrieve tokens from staking.
     *
     * CRI allows user to obtain reward by participating in staking. Users need
     * to explicitly add their tokens for staking to be able to receive reward.
     *
     */
    function retrieveStake() public {
      require(_stakes[_msgSender()] >= 0, "CRI: Empty stake");
      _balances[_msgSender()] += _stakes[_msgSender()];
      _stakes[_msgSender()] = 0;
    }

    /**
     * @dev view the amount of stake that the sender currently has.
     *
     */
    function viewStake() public
      view
      returns(uint256) {
      return _stakes[_msgSender()];
    }

    /**
     * @dev view the current reward period.
     *
     */
    function viewRewardPeriod() public
      view
      returns(uint256) {
      return _reward_period;
    }

    /**
     * @dev view the currenct reward per 1M tokens.
     *
     */
    function viewReward() public
      view
      returns(uint256) {
      return _reward;
    }

}
