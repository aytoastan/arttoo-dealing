module contracts::arttoo {
    use sui::url::{Self, Url};
    use std::string::{Self, String};
    use sui::coin::{TreasuryCap};
    use std::type_name::{Self, get};

    // === Structs ===

    /// AdminCap is the capability object that Admin holds
    public struct AdminCap has key {
        id: UID
    }

    // ArttooNFT stores the metadata of a NFT 
    public struct ArttooNft has key, store {
        id: UID,
        name: string::String,
        description: string::String,
        url: Url,
        attributes: vector<String>,
        token_associated: String,
    }

    // ArttooNftVault locks all the minted NFTs
    public struct ArttooNftVault has key, store {
        id: UID,
        nft_list: vector<ArttooNft>,
    }

    // === Init Function ===

    fun init(ctx: &mut TxContext) {
        let super_admin = AdminCap {
            id: object::new(ctx)
        };
        transfer::transfer(super_admin, ctx.sender());

        let nft_vault = ArttooNftVault {
            id: object::new(ctx),
            nft_list: vector::empty<ArttooNft>(),
        };
        transfer::share_object(nft_vault);
    }

    // === Admin Functions ===

    // This function can be called only by the address with Tresuary cap of the token that is being associated with the NFT.
    public entry fun mint_nft<T> (
        _: &TreasuryCap<T>,
        name: vector<u8>,
        description: vector<u8>,
        url: vector<u8>,
        token_associated: String,
        nft_vault: &mut ArttooNftVault,
        ctx: &mut TxContext
    ) {
        // assert the type of tokencap is same as the token associated
        assert!(string::from_ascii(type_name::into_string(get<TreasuryCap<T>>())) == token_associated, 0);
        let nft = ArttooNft {
            id: object::new(ctx),
            name: string::utf8(name),
            description: string::utf8(description),
            url: url::new_unsafe_from_bytes(url),
            attributes: vector::empty<String>(),
            token_associated: token_associated
        };

        vector::push_back(&mut nft_vault.nft_list, nft);
    }

    /// Update the `attributes` of `nft`
    public fun update_attribute (
        _: &AdminCap,
        nft: &mut ArttooNft,
        new_attribute: String,
    ) {
        assert!(vector::contains(&nft.attributes, &new_attribute) == false, 0);
        vector::push_back(&mut nft.attributes, new_attribute);
    }

    // Additional features to be added later on:
    // Add a redeem function for token holders to swap the token for USD
    // Add a update proofs function for admin to add artifacts 
}


