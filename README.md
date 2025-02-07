# ERC-4337 Simple Account Implementation  

> [!WARNING]  
> 🚧 **Work in Progress** 🚧  

## To-Do List  

- [ ] Finalize unit tests  
- [ ] Complete integration tests  
- [ ] Update README documentation  

## Notes  

The following sections contain my personal notes, which may not be fully structured or easy to understand yet. In the meantime, feel free to check out [my Medium profile](https://medium.com/@nikbhintade) for well-organized articles on related topics.

-----------
Following commands are only for me & not for person who is checking the project

create project

```bash
forge init simple_account
```

soldeer init, instead of using git submodules, I want to start using

```bash
forge soldeer init
```

install dependencies

```bash
forge soldeer install @openzeppelin-contracts~5.2.0
forge soldeer install eth-infinitism-account-abstraction~0.7
```

Modified the `foundry.toml` to add some `soldeer` configs

```toml

[soldeer]
remappings_generate = true
remappings_regenerate = false
remappings_version = false
remappings_location = "config"

```

I have modified the remappings for names I know and that's why regenerate remappings option is not set to `true` as it will change those remappings in case a soldeer command is executed.
