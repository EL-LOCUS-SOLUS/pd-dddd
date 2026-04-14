# dddd: High-Level Data Abstraction for Pure Data

## Overview

`dddd` is a data abstraction framework for Pure Data (Pd) implemented via `pdlua`. It introduces complex, encapsulated data structures into Pd's visual programming environment. By abstracting data representation, `dddd` allows composers and software engineers to operate directly on high-dimensional concepts—such as musical chords, formal measures, spatial trajectories, and graphical DOM nodes—rather than manually managing low-level data routing.

## Theoretical Motivation: Essential vs. Accidental Complexity

Pure Data natively processes information through flat, atomic data primitives (floats, symbols, and lists). While highly efficient for real-time digital signal processing, mapping the high essential complexity of musical composition onto these low-level primitives generates severe accidental complexity (Brooks, 1986). Composers are frequently forced to perform mechanical list packing, unpacking, and string manipulation merely to simulate higher-order structures.

`dddd` mitigates this accidental complexity by providing a computational syntax congruent with the operational logic of formal composition. It brings object-oriented encapsulation to Pd, allowing users to manipulate the essential behavior of a musical object without dealing with the underlying memory allocation or data formatting.

## Architecture and Dataflow Integrity

To bypass Pd's data type limitations without compromising its deterministic dataflow paradigm, `dddd` implements a synchronous pass-by-value architecture.

1. **Encapsulation:** Complex data structures are encapsulated as Lua tables within instances of the `dddd` class.
2. **Transmission:** When an object outputs data, `dddd` stores the table in a temporary global Lua registry under a randomly generated, hashed ID. This ID is passed through the Pd patch cord as a standard message (e.g., `dddd <RANDOM_ID>`).
3. **Reception and Isolation:** Upon receiving the ID, the downstream object extracts the payload and performs a mandatory deep copy. This guarantees state isolation. If a single outlet is connected to multiple inlets (fan-out), each receiving object operates on its own independent memory space, preventing cross-mutation and race conditions.
4. **Synchronous Garbage Collection:** Because Pd's message passing evaluates depth-first and synchronously, the temporary global state is immediately destroyed by the sending object once the downstream execution branch resolves. This natively prevents memory leaks without the need for a complex external garbage collector.

## Requirements

* Pure Data (Vanilla)
* `pdlua` external (required to instantiate and manage the Lua runtime within Pd)

## Implementation Notes

While the strict deep-copy mechanism introduces a minor computational overhead, this trade-off is required to ensure pure dataflow determinism and state safety. Operations utilizing `dddd` are designed to run at the control rate (message domain), meaning this overhead should not not impact real-time audio (DSP) processing.

