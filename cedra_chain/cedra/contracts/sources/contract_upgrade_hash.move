module pyth::contract_upgrade_hash {
    use std::vector;

    public struct Hash has drop, copy, store {
        external_address: vector<u8>,
    }
}