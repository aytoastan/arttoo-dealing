module contracts::ml_token {
    use sui::sui::{Self, SUI};
    use sui::coin::{Self, Coin, TreasuryCap};
    use sui::balance::{Self, Balance};

    // === Errors ===

    const EInsufficientMintFee:u64 = 11;
    const EMintLimitExceed:u64 = 22;

    // === Constants ===

    const PULIC_MINT_FEE:u64 = 10_000_000_000;

    // === OTW ===

    public struct ML_TOKEN has drop {}

    // === Structs ===

    public struct ConfigurationCap has key {
        id: UID,
    }

    public struct MintConfiguration has key {
        id: UID,
        max_mint_amount: u64,
        mint_price: u64,
    }

    public struct ContractTreasury has key {
        id: UID,
        sales_balance: Balance<SUI>,
        treasury_cap: TreasuryCap<ML_TOKEN>,
    }

    // === Init Function ===

    fun init(witness: ML_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency(witness, 9, b"ML_TOKEN", b"MONALISA TOKEN", b"This is a token of Monalisa NFT.", option::none(), ctx);
        transfer::public_freeze_object(metadata);

        transfer::transfer(ConfigurationCap {
            id: object::new(ctx)
        }, ctx.sender());

        transfer::share_object(ContractTreasury {
            id: object::new(ctx),
            sales_balance: balance::zero(),
            treasury_cap: treasury_cap
        });
    }

    // === Admin Functions ===

    // configuration cap owner whitelists new users by sending MintConfiguration object
    public fun whitelist_users (
        _: &ConfigurationCap,
        users: &mut vector<address>,
        max_mint_amount: u64,
        mint_price: u64,
        ctx: &mut TxContext
    ) {
        while (!users.is_empty()) {
            let user = users.pop_back();
            let mint_config = MintConfiguration {
                id: object::new(ctx),
                max_mint_amount: max_mint_amount,
                mint_price: mint_price
            };

            transfer::transfer(mint_config, user);
        }
    }

    // === Public Functions ===

    // this is a function to buy tokens for whitelisted (with MintConfiguration) users
    public fun wl_purchase_token (
        contract_treasury: &mut ContractTreasury,
        mint_config: &mut MintConfiguration,
        token_amount: u64,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        assert!(token_amount <= mint_config.max_mint_amount, EMintLimitExceed);
        assert!(payment.value() >= (mint_config.mint_price * token_amount), EInsufficientMintFee);

        coin::put(&mut contract_treasury.sales_balance, payment);

        coin::mint_and_transfer(&mut contract_treasury.treasury_cap, token_amount, ctx.sender(), ctx);
    }

    // this is a function to buy token for public users
    public fun public_purchase_token (
        contract_treasury: &mut ContractTreasury,
        token_amount: u64,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ) {
        assert!(payment.value() >= (PULIC_MINT_FEE * token_amount), EInsufficientMintFee);

        coin::put(&mut contract_treasury.sales_balance, payment);

        coin::mint_and_transfer(&mut contract_treasury.treasury_cap, token_amount, ctx.sender(), ctx);
    }

    public fun redeem_token (
        contract_treasury: &mut ContractTreasury,
        token: Coin<ML_TOKEN>,
        ctx: &mut TxContext
    ) {
        // take the value equivalent to token amount from contract sales balance and transfer it to tx sender
        let redeem_amount = coin::take(&mut contract_treasury.sales_balance, token.value(), ctx);
        sui::transfer(redeem_amount, ctx.sender());

        // burn the token sent by the tx sender
        coin::burn(&mut contract_treasury.treasury_cap, token);
    }
}

