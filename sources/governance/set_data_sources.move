module oracle::set_data_sources {
    use cedra_message::cursor;
    use oracle::deserialize;
    use cedra_message::external_address::{Self};
    use oracle::data_source::{Self, DataSource};
    use oracle::state;
    use std::vector;

    friend oracle::governance;

    struct SetDataSources {
        sources: vector<DataSource>,
    }

    public(friend) fun execute(payload: vector<u8>) {
        let SetDataSources { sources } = from_byte_vec(payload);
        state::set_data_sources(sources);
    }

    fun from_byte_vec(bytes: vector<u8>): SetDataSources {
        let cursor = cursor::init(bytes);
        let data_sources_count = deserialize::deserialize_u8(&mut cursor);

        let sources = vector::empty();

        let i = 0;
        while (i < data_sources_count) {
            let emitter_chain_id = deserialize::deserialize_u16(&mut cursor);
            let emitter_address = external_address::from_bytes(deserialize::deserialize_vector(&mut cursor, 32));
            vector::push_back(&mut sources, data_source::new(emitter_chain_id, emitter_address));

            i = i + 1;
        };

        cursor::destroy_empty(cursor);

        SetDataSources {
            sources
        }
    }

}
