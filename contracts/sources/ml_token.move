module contracts::ml_token {
    use sui::coin::{Self, TreasuryCap};

    public struct ML_TOKEN has drop {}

    // === Init Function ===

    fun init(witness: ML_TOKEN, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency(witness, 9, b"ML_TOKEN", b"MONALISA TOKEN", b"This is a token of Monalisa NFT.", option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(treasury_cap, ctx.sender());
    }

    // === Admin Functions ===

    // This function mints the token and sends it to the recipient. 
    // If recipient address is not provided it sends to tx sender
    public fun mint_tokens (
        tresury_cap: &mut TreasuryCap<ML_TOKEN>,
        amount: u64,
        recipient: Option<address>,
        ctx: &mut TxContext
    ) {
        coin::mint_and_transfer(tresury_cap, amount, recipient.get_with_default(ctx.sender()), ctx);
    }
}

