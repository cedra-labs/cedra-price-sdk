module oracle::event {
    use std::event::{Self, EventHandle};
    use oracle::price_feed::{PriceFeed};
    use std::account;

    friend oracle::oracle;

    /// Signifies that a price feed has been updated
    struct PriceFeedUpdate has store, drop {
        /// Value of the price feed
        price_feed: PriceFeed,
        /// Timestamp of the update
        timestamp: u64,
    }

    struct PriceFeedUpdateHandle has key, store {
        event: EventHandle<PriceFeedUpdate>
    }

    public(friend) fun init(oracle: &signer) {
        move_to(
            oracle,
            PriceFeedUpdateHandle {
                event: account::new_event_handle<PriceFeedUpdate>(oracle)
            }
        );
    }

    public(friend) fun emit_price_feed_update(price_feed: PriceFeed, timestamp: u64) acquires PriceFeedUpdateHandle {
        let event_handle = borrow_global_mut<PriceFeedUpdateHandle>(@oracle);
        event::emit_event<PriceFeedUpdate>(
            &mut event_handle.event,
            PriceFeedUpdate {
                price_feed,
                timestamp,
            }
        );
    }
}
