// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract VestingContract is Ownable {
    IERC20 public token;
    uint256 public vestingStartTime;
    bool public vestingStarted;

    enum Role { User, Partner, Team }

    struct VestingSchedule {
        uint256 totalAllocation;
        uint256 cliffDuration;
        uint256 vestingDuration;
        uint256 amountClaimed;
        uint256 lastClaimTime;
    }

    mapping(address => mapping(Role => VestingSchedule)) public vestingSchedules;

    event VestingStarted(uint256 startTime);
    event BeneficiaryAdded(address beneficiary, Role role, uint256 allocation);
    event TokensClaimed(address beneficiary, Role role, uint256 amount);

    constructor(address _tokenAddress) Ownable(msg.sender) {
        token = IERC20(_tokenAddress);
    }

    function startVesting() external onlyOwner {
        require(!vestingStarted, "Vesting has already started");
        vestingStartTime = block.timestamp;
        vestingStarted = true;
        emit VestingStarted(vestingStartTime);
    }

    function addBeneficiary(address _beneficiary, Role _role, uint256 _allocation) external onlyOwner {
        require(!vestingStarted, "Vesting has already started");
        require(_allocation > 0, "Allocation must be greater than 0");

        VestingSchedule storage schedule = vestingSchedules[_beneficiary][_role];
        require(schedule.totalAllocation == 0, "Beneficiary already exists for this role");

        schedule.totalAllocation = _allocation;
        schedule.cliffDuration = getCliffDuration(_role);
        schedule.vestingDuration = getVestingDuration(_role);

        emit BeneficiaryAdded(_beneficiary, _role, _allocation);
    }

    function claimTokens(Role _role) external {
        require(vestingStarted, "Vesting has not started yet");
        VestingSchedule storage schedule = vestingSchedules[msg.sender][_role];
        require(schedule.totalAllocation > 0, "No allocation found for this role");

        uint256 vestedAmount = calculateVestedAmount(msg.sender, _role);
        uint256 claimableAmount = vestedAmount - schedule.amountClaimed;
        require(claimableAmount > 0, "No tokens available to claim");

        schedule.amountClaimed += claimableAmount;
        schedule.lastClaimTime = block.timestamp;

        require(token.transfer(msg.sender, claimableAmount), "Token transfer failed");
        emit TokensClaimed(msg.sender, _role, claimableAmount);
    }

    function calculateVestedAmount(address _beneficiary, Role _role) public view returns (uint256) {
        VestingSchedule storage schedule = vestingSchedules[_beneficiary][_role];
        if (block.timestamp < vestingStartTime + schedule.cliffDuration) {
            return 0;
        }

        if (block.timestamp >= vestingStartTime + schedule.vestingDuration) {
            return schedule.totalAllocation;
        }

        uint256 timeVested = block.timestamp - vestingStartTime;
        return (schedule.totalAllocation * timeVested) / schedule.vestingDuration;
    }

    function getCliffDuration(Role _role) internal pure returns (uint256) {
        if (_role == Role.User) {
            return 300 days; // 10 months
        } else {
            return 60 days; // 2 months
        }
    }

    function getVestingDuration(Role _role) internal pure returns (uint256) {
        if (_role == Role.User) {
            return 730 days; // 2 years
        } else {
            return 365 days; // 1 year
        }
    }
}