# IndexedDB commands

The `indexed_db` package exposes managed Rabbita commands for a browser
IndexedDB object store whose application records use string keys and string
values. The provider owns database connections, creates queued transactions in
command-invocation order per `Config`, and reports each transaction's completion
independently through the Rabbita update loop. It does not wait for one
transaction's completion callback before admitting the next transaction;
IndexedDB schedules transactions whose scopes overlap.

```moonbit nocheck
///|
let documents = @indexed_db.Config::Config("loomark", 1, "documents")
```

## Read and replace one record

`get` distinguishes a missing record from an unsupported stored value. `put`
replaces one string record and reports `Stored` only after the read-write
transaction completes.

```moonbit nocheck
@indexed_db.get(documents, "source/v1/document-1", result=emit.map(Loaded))

@indexed_db.put(
  documents,
  "source/v1/document-1",
  encoded_source,
  result=emit.map(Saved),
)
```

The optional `migrate_legacy` argument to `get` retains its existing
localStorage-to-IndexedDB migration behavior.

## Scan every record

`scan` opens an unbounded cursor and returns entries in IndexedDB key order.
Each entry is classified independently, so an unsupported key or value does
not hide later valid string records.

```moonbit nocheck
@indexed_db.scan(documents, result=emit.map(StoreScanned))
```

A successful scan returns `ScanResult::Scanned(entries)`. Entries are:

- `StringRecord(key, value)` for a string key and string value;
- `UnsupportedValue(key)` for a string key with a non-string value;
- `UnsupportedKey(position)` when the key is not a string. `position` is the
  entry's zero-based position in the cursor result, so separate unsupported
  records remain distinguishable without exposing JavaScript values or adding
  repository policy to the DOM binding.

Cursor invocation, continuation, request, or transaction failures fail the
scan closed. `Scanned` is emitted only after cursor exhaustion and transaction
completion.

## Apply atomic mutations

`mutate` applies every `Put` and `Delete` in one read-write transaction.
Either all mutations commit or none do.

```moonbit nocheck
@indexed_db.mutate(
  documents,
  [
    @indexed_db.Mutation::Put("source/v1/document-1", encoded_source),
    @indexed_db.Mutation::Delete("active"),
  ],
  result=emit.map(MigrationCompleted),
)
```

The mutation list is defensively copied before asynchronous execution. An
empty list is an immediate successful no-op and does not open a database or
create a transaction. `put` reuses the same mutation provider with one `Put`.

`WriteResult` classifies unavailable storage, quota exhaustion, and other
failures. A request success is never treated as durable completion; callers
receive `Stored` only from that transaction's completion event. Transaction
admission order is not an application-level callback-order guarantee: callers
must correlate acknowledgments with their own operations.
