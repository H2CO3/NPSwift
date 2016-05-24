struct KeyValue<Key, Value> {
    let key: Key
    var value: Value
}

class HashTable<Key: Hashable, Value> {
    var slots: [KeyValue<Key, Value>?]
    var count: Int
    var max_hash_offset: Int

    init() {
        slots = []
        count = 0
        max_hash_offset = 0
    }

    func mask() -> Int {
        assert(
            slots.count > 0 && (slots.count & (slots.count - 1)) == 0,
            "slot array size must be a power of 2"
        )
        return slots.count - 1
    }

    func key_index(key: Key) -> Int {
        return key.hashValue & mask()
    }

    func should_rehash() -> Bool {
        return slots.count == 0 || count > slots.count * 3 / 4
    }

    func get_slot_idx(key: Key) -> Int? {
		    // do not try to modulo by 0. An empty table has no values.
		    if slots.count == 0 {
			      return nil
		    }

		    var i = key_index(key)
		    var hash_offset = 0

		    // linear probing using a cached maximal probe sequence length.
		    // This avoids the need to mark deleted slots as special and
		    // fixes the performance problem whereby searching for a key after
		    // having performed lots of deletions results in O(n) running time.
		    // (max_hash_offset is one less than the length of the longest sequence.)
		    repeat {
			      if slots[i]?.key == key {
				        return i
			      }

			      i = (i + 1) & mask()
			      hash_offset += 1
		    } while hash_offset <= max_hash_offset

		    return nil
    }

    func rehash_if_needed() {
        if should_rehash() {
            rehash()
        }
    }

    func rehash() {
        let new_size = slots.count == 0 ? 8 : slots.count * 2
        let old_slots = slots

        clear()
        
        slots = [KeyValue<Key, Value>?](count: new_size, repeatedValue: nil)

        for slot in old_slots {
            if let slot = slot {
                insert_norehash(slot.key, slot.value)
            }
        }
    }

    func insert(key: Key, _ value: Value) {
        rehash_if_needed()
        insert_norehash(key, value)
    }

    func insert_norehash(key: Key, _ value: Value) {
        var i = key_index(key)
        var hash_offset = 0

        assert(!should_rehash())
        assert(get_slot_idx(key) == nil)

        // first, find an empty (unused) slot
		    while slots[i] != nil {
			      i = (i + 1) & mask()
			      hash_offset += 1
        }

        // Then, perform the actual insertion
        slots[i] = KeyValue<Key, Value>(key: key, value: value)

        // unconditionally increment the size because
		    // we know that the key didn't exist before.
		    count += 1

        // finally, update maximal length of probe sequences (minus one)
		    if hash_offset > max_hash_offset {
			      max_hash_offset = hash_offset
		    }
		}

    func clear() {
        slots.removeAll()
        count = 0
        max_hash_offset = 0
    }

    subscript(key: Key) -> Value? {
        get {
            if let slot_idx = get_slot_idx(key) {
                return slots[slot_idx]!.value
            }
            return nil
        }
        set (value) {
            let slot_idx = get_slot_idx(key)
            if let value = value {
                if let slot_idx = slot_idx {
                    // only replace value of existing key (don't touch count)
                    slots[slot_idx]!.value = value
                } else {
                    // insert nonexistent key-value pair. 'insert()' takes care of the count.
                    insert(key, value)
                }
            } else if let slot_idx = slot_idx {
                // remove
                slots[slot_idx] = nil
                count -= 1
            }
            // otherwise, set non-existent entry to nil -> no-op, count is unaffected
        }
    }
}
