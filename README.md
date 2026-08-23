# dddd

Structured, pass-by-value data for [Pure Data](https://puredata.info/) objects written in Lua.

Pure Data messages are deliberately small: a selector followed by flat atoms. That works well for control and signal processing, but becomes cumbersome when an object needs to send a chord, rhythm tree, SVG element, or another nested value. `dddd` lets a Pd patch carry those values as single messages while the implementation remains a recursive Lua table.

```text
Lua table                      Pd patch cord
{ 60, 64, 67 }   ─────────▶   dddd <12-hex-character-id>
```

The ID is temporary. A receiving Lua object resolves it immediately and gets a deep copy of the table. If an outlet fans out to several objects, every receiver therefore works on an independent value.

## Requirements

- Pure Data
- A working [`pdlua`](https://github.com/agraef/pd-lua) installation
- `dddd.lua` somewhere Lua can resolve `require("dddd")`

`dddd` is a developer library: patch users normally interact with domain objects built on it, not with a `[dddd]` Pd object.

## Quick start

Put this producer in a `.pd_lua` file on Pd's search path:

```lua
local dddd = require("dddd")

local chord_source = pd.Class:new():register("chord.source")

function chord_source:initialize()
    self.inlets = 1
    self.outlets = 1
    return true
end

function chord_source:in_1_bang()
    local chord = dddd:new_from_table(self, { 60, 64, 67 })
    chord:output(1)
end
```

A compatible receiver implements an `in_<inlet>_dddd` method:

```lua
local dddd = require("dddd")

local chord_print = pd.Class:new():register("chord.print")

function chord_print:initialize()
    self.inlets = 1
    self.outlets = 0
    return true
end

function chord_print:in_1_dddd(atoms)
    local chord = dddd:new_from_atoms(self, atoms)
    local notes = chord:get_table()
    pd.post(table.concat(notes, " "))
end
```

Connect `[chord.source]` to `[chord.print]` and send a bang. The connection carries a normal Pd message with the selector `dddd`; the receiver reconstructs `{ 60, 64, 67 }` before the sender clears the temporary registry entry.

## Nested-list syntax

`dddd` can parse parenthesized or bracketed lists:

```text
(1 (2 3) four)
[1 [2 3] four]
```

Both represent:

```lua
{ 1, { 2, 3 }, "four" }
```

Do not mix `()` and `[]` in the same expression. Tokens accepted by Lua's `tonumber` become numbers; all other tokens become strings. The format has no quoting or escaping syntax, so strings containing whitespace or delimiter characters need a different representation.

## Documentation

- [Getting started](docs/getting-started.md) — installation, first sender/receiver, and examples
- [Data model and syntax](docs/data-model.md) — tables, textual lists, lifetime, copying, and limitations
- [Writing dddd-aware Pd objects](docs/writing-objects.md) — practical patterns for library authors
- [Lua API reference](docs/api.md) — public methods and their contracts
- [Architecture](docs/architecture.md) — registry protocol, deterministic fan-out, and performance
- [Troubleshooting](docs/troubleshooting.md) — common errors and likely causes

Open [`dddd-help.pd`](dddd-help.pd) inside Pure Data for the same reference organized as six embedded subpatches.

The repository also contains [`examples/dddd.ex1.pd_lua`](examples/dddd.ex1.pd_lua), a small round trip between two objects, and [`examples/dddd.random-chords.pd_lua`](examples/dddd.random-chords.pd_lua), a structured chord-list producer.

## Scope

`dddd` is intended for message-rate structured data, not audio-rate samples. It supplies common infrastructure on which notation, computer-aided composition, graphical composition, analysis, and research tools can define their own domain objects. Current projects motivating the design include symbolic structures such as chords and rhythm trees, and graphical structures such as SVG elements with parent-child relationships.

The implementation favors Pd-like value semantics over shared mutable references. That costs a recursive copy for every receiver, but makes the result of a fan-out independent of connection order.

## Status

This repository is an early developer-facing implementation. Read [Data model and syntax](docs/data-model.md#current-boundaries) before choosing a payload format, especially if you need type metadata, associative tables, persistence, or delayed delivery.

## License

[MIT](LICENSE) © 2026 EL LOCUS SOLUS.
