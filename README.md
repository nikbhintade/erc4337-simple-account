# ERC4337 Simple Account

This project implements a Solidity smart contract that follows the ERC4337 standard for account abstraction. It includes both unit and integration tests, with 100% test coverage.

If you're new to ERC4337, I recommend reading its specification: [ERC-4337 Specification](https://eips.ethereum.org/EIPS/eip-4337). Having some background on this will help you understand the key terms and the account abstraction flow.

I've also written a detailed series on Medium covering multiple aspects of ERC4337. If you're interested, you can check it out [here](https://medium.com/@nikbhintade/list/developers-guide-to-erc4337-d34102dd0c5a).

## Installation and Testing

To run this project locally, follow these steps:

First, clone the repository:

```bash
git clone https://github.com/nikbhintade/erc4337-simple-account.git
cd erc4337-simple-account
```

Next, install dependencies using `soldeer` (I opted for this package manager instead of Foundry’s default Git submodule approach):

```bash
forge soldeer init
```

This command will install all dependencies listed in `foundry.toml` under the `[dependencies]` section:

```toml
[dependencies]
forge-std = "1.9.6"
"@openzeppelin-contracts" = "5.2.0"
eth-infinitism-account-abstraction = "0.7"
```

Finally, to run all tests:

```bash
forge test
```

## Understanding the Simple Account

ERC4337 defines an interface for account contracts. Instead of implementing it directly, this contract inherits from `BaseAccount` (developed by the `eth-infinitism`), which already provides the required functions. This allows us to focus on modifying key functionalities, such as signature verification and executing external calls.

In this implementation:

-   The contract verifies signatures using ECDSA, ensuring they match the account owner's address (set during deployment via constructor).
-   The `execute` function allows the owner to interact with contracts and other accounts through this account contract.
    -   Only the `EntryPoint` contract is permitted to call `execute`.

For a better understanding, you can check the code and read the comments.

## Contributions

If you have suggestions for improving the code or explanations, feel free to reach out!

---

## Notes

### Using `soldeer` Instead of Git Submodules

Instead of relying on Git submodules for dependency management, I’ve decided to start using `soldeer`. To initialize the project with `soldeer`, run:

```bash
forge soldeer init
```

### Installing Dependencies

To install specific dependencies, use:

```bash
forge soldeer install @openzeppelin-contracts~5.2.0
forge soldeer install eth-infinitism-account-abstraction~0.7
```

### Updating `foundry.toml` for `soldeer` Configurations

I modified the `foundry.toml` file to include `soldeer` settings:

```toml
[soldeer]
remappings_generate = true
remappings_regenerate = false
remappings_version = false
remappings_location = "config"
```

-   `remappings_generate = true`: Automatically generates remappings.
-   `remappings_regenerate = false`: Prevents overwriting custom remappings when running `soldeer` commands.
-   `remappings_version = false`: Disables version-based remapping generation.
-   `remappings_location = "config"`: Stores remappings in a specific folder instead of the default location.

Since I manually adjusted remappings for known dependencies, I set `remappings_regenerate = false` to prevent `soldeer` from modifying them when executing commands.
