#[starknet::contract]
mod PredifiToken {
    use starknet::ContractAddress;
    // Import OpenZeppelin ERC20 components
    use openzeppelin::token::erc20::ERC20Component;
    
    // Include the ERC20 component
    component!(path: ERC20Component, storage: erc20, event: ERC20Event);
    
    // Implement the ERC20 interfaces
    #[abi(embed_v0)]
    impl ERC20Impl = ERC20Component::ERC20Impl<ContractState>;
    #[abi(embed_v0)]
    impl ERC20MetadataImpl = ERC20Component::ERC20MetadataImpl<ContractState>;
    // Internal implementation for minting
    impl InternalImpl = ERC20Component::InternalImpl<ContractState>;
    
    #[storage]
    struct Storage {
        #[substorage(v0)]
        erc20: ERC20Component::Storage
    }
    
    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }
    
    #[constructor]
    fn constructor(
        ref self: ContractState,
        initial_supply: u256,
        recipient: ContractAddress
    ) {
        let name = 'Predifi';
        let symbol = 'PDFI';
        let decimals = 18_u8;
        
        // Initialize the ERC20 token
        self.erc20.initializer(name, symbol, decimals);
        
        // Mint the initial supply to the recipient
        self.erc20._mint(recipient, initial_supply);
    }

    //
    // External functions
    //

    #[external(v0)]
    fn name(self: @ContractState) -> felt252 {
        self.erc20.name()
    }

    #[external(v0)]
    fn symbol(self: @ContractState) -> felt252 {
        self.erc20.symbol()
    }

    #[external(v0)]
    fn decimals(self: @ContractState) -> u8 {
        self.erc20.decimals()
    }

    #[external(v0)]
    fn total_supply(self: @ContractState) -> u256 {
        self.erc20.total_supply()
    }

    #[external(v0)]
    fn balance_of(self: @ContractState, account: ContractAddress) -> u256 {
        self.erc20.balance_of(account)
    }

    #[external(v0)]
    fn allowance(self: @ContractState, owner: ContractAddress, spender: ContractAddress) -> u256 {
        self.erc20.allowance(owner, spender)
    }

    #[external(v0)]
    fn transfer(ref self: ContractState, recipient: ContractAddress, amount: u256) -> bool {
        self.erc20.transfer(recipient, amount)
    }

    #[external(v0)]
    fn transfer_from(
        ref self: ContractState, sender: ContractAddress, recipient: ContractAddress, amount: u256
    ) -> bool {
        self.erc20.transfer_from(sender, recipient, amount)
    }

    #[external(v0)]
    fn approve(ref self: ContractState, spender: ContractAddress, amount: u256) -> bool {
        self.erc20.approve(spender, amount)
    }

    //
    // Additional functions (optional)
    //
    
    #[external(v0)]
    fn increase_allowance(
        ref self: ContractState, spender: ContractAddress, added_value: u256
    ) -> bool {
        self.erc20.increase_allowance(spender, added_value)
    }

    #[external(v0)]
    fn decrease_allowance(
        ref self: ContractState, spender: ContractAddress, subtracted_value: u256
    ) -> bool {
        self.erc20.decrease_allowance(spender, subtracted_value)
    }
} 