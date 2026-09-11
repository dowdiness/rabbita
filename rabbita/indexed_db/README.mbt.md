# IndexedDB managed stores

`indexed_db` exposes a JS-only managed IndexedDB store. A `Store` is an opaque
handle identified structurally by its database name, version, and object-store
name; handles with the same identity share one provider state.

```moonbit nocheck
let documents = @indexed_db.Store::Store("loomark", 1, "documents")
documents.get("source/v1/document-1", emit.map(HandleLookup))
documents.entries(emit.map(HandleEntries))
documents.set("source/v1/document-1", encoded, emit.map(WriteFinished))
documents.apply([
  @indexed_db.Mutation::Set("active", "document-1"),
  @indexed_db.Mutation::Delete("old"),
], emit.map(WriteFinished))
```

`get` returns `Ok(Lookup::Missing)`, `Found(value)`, or `Unsupported`.
`contains` uses IndexedDB `getKey` and does not read the value. `entries`
returns cursor-order `Entry` values, retaining unsupported keys and values.
Writes acknowledge transaction commit with `None`; failures are typed
`WriteError?`. Inputs to `apply` are copied when the command is constructed.
