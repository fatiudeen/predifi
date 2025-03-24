#[cfg(test)]
mod predifi_token_tests {
    use starknet::ContractAddress;
    use starknet::contract_address_const;
    use starknet::testing::set_caller_address;
    // Import OpenZeppelin ERC20 interfaces
    use openzeppelin::token::erc20::interface::{IERC20, IERC20Metadata};
    use snforge_std::declare;
    use snforge_std::start_prank;
    use snforge_std::stop_prank;
    use snforge_std::ContractClassTrait;
    use assert_macros::{assert_eq, assert_ne};

    // Helper function to deploy the token contract
    fn deploy_predifi_token() -> (ContractAddress, u256) {
        let recipient = contract_address_const::<0x123>();
        let initial_supply = 1000000000000000000000000_u256; // 1 million tokens with 18 decimals

        // Declare the contract
        let contract = declare("PredifiToken");
        
        // Deploy with constructor arguments
        let contract_address = contract.deploy(@array![
            initial_supply.low.into(),
            initial_supply.high.into(),
            recipient.into()
        ]).unwrap();

        (contract_address, initial_supply)
    }

    #[test]
    fn test_token_basic_info() {
        let (contract_address, _) = deploy_predifi_token();
        
        // Using the OpenZeppelin interfaces
        let metadata = IERC20MetadataDispatcher { contract_address };
        
        // Check basic token info
        assert_eq(metadata.name(), 'Predifi', 'Wrong name');
        assert_eq(metadata.symbol(), 'PDFI', 'Wrong symbol');
        assert_eq(metadata.decimals(), 18_u8, 'Wrong decimals');
    }

    #[test]
    fn test_initial_supply() {
        let (contract_address, initial_supply) = deploy_predifi_token();
        let recipient = contract_address_const::<0x123>();
        
        let erc20 = IERC20Dispatcher { contract_address };
        
        // Check total supply
        assert_eq(erc20.total_supply(), initial_supply, 'Wrong supply');
        
        // Check recipient balance
        assert_eq(erc20.balance_of(recipient), initial_supply, 'Wrong balance');
    }

    #[test]
    fn test_transfer() {
        let (contract_address, _) = deploy_predifi_token();
        let owner = contract_address_const::<0x123>();
        let recipient = contract_address_const::<0x456>();
        let transfer_amount = 1000_u256;
        
        let erc20 = IERC20Dispatcher { contract_address };
        
        // Start prank to set caller as the owner
        start_prank(contract_address, owner);
        
        // Transfer tokens to recipient
        let success = erc20.transfer(recipient, transfer_amount);
        assert_eq(success, true, 'Transfer failed');
        
        // Check balances after transfer
        assert_eq(erc20.balance_of(recipient), transfer_amount, 'Wrong recipient balance');
        
        // Stop prank
        stop_prank(contract_address);
    }

    #[test]
    fn test_approve_and_transfer_from() {
        let (contract_address, _) = deploy_predifi_token();
        let owner = contract_address_const::<0x123>();
        let spender = contract_address_const::<0x456>();
        let recipient = contract_address_const::<0x789>();
        let approval_amount = 5000_u256;
        let transfer_amount = 1000_u256;
        
        let erc20 = IERC20Dispatcher { contract_address };
        
        // Start prank to set caller as the owner
        start_prank(contract_address, owner);
        
        // Approve spender
        let success = erc20.approve(spender, approval_amount);
        assert_eq(success, true, 'Approval failed');
        assert_eq(erc20.allowance(owner, spender), approval_amount, 'Wrong allowance');
        
        // Stop owner prank
        stop_prank(contract_address);
        
        // Start prank to set caller as the spender
        start_prank(contract_address, spender);
        
        // Transfer tokens from owner to recipient
        let success = erc20.transfer_from(owner, recipient, transfer_amount);
        assert_eq(success, true, 'Transfer from failed');
        
        // Check balances and allowance after transfer
        assert_eq(erc20.balance_of(recipient), transfer_amount, 'Wrong recipient balance');
        assert_eq(
            erc20.allowance(owner, spender), 
            approval_amount - transfer_amount, 
            'Wrong allowance after transfer'
        );
        
        // Stop spender prank
        stop_prank(contract_address);
    }
} 