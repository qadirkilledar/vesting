1. Overview of the Solidity Smart Contract
Let's start with the core of my project—the Solidity smart contract designed to manage token vesting:
Explanation of the Smart Contract
•	Design Choices: I've structured the contract to accommodate multiple roles (User, Partner, Team) with distinct vesting schedules.
•	Security Measures: Leveraged OpenZeppelin's ERC20 interface for token interactions and Ownable for access control to ensure contract security.
•	Lifecycle Management: Implemented functions like startVesting to initialize vesting periods and claimTokens to facilitate token distribution upon vesting.

2. Test Suite Using Hardhat

3. Overview of Testing Approach
•	Setup: Initialized test environment with Hardhat, deploying both the VestingContract and a mock ERC20 token for testing purposes.
•	Validation: Ensured correct ownership assignment, vesting initiation, beneficiary addition, vested amount calculation, and token claiming functionalities through comprehensive test cases.
 
4. Test Results
Here's a summary of the test results:
•	Total Tests: 5
•	Passed: 4
•	Failed: 1 (due to a setup issue)

While I have not achieved full completion as per the specified criteria, I remain committed to further demonstrating my capabilities in the upcoming technical round.
I appreciate your understanding and consideration during this period. I look forward to the possibility of discussing my application further and exploring how I can contribute to the innovative work at SoluLab.


Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js
```
# vesting
