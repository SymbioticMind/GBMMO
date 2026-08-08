# GBA MMO Engine Architecture

## 1. Overview

The GBA MMO Engine is designed around a separation between the original game and the multiplayer framework.

The original game is not treated as the MMO engine.

Instead, the project observes and interacts with the running game through a game-specific adapter.

The architecture is:

    Original ROM
        ↓
    Emulator
        ↓
    Emulator Integration
        ↓
    Game Adapter
        ↓
    Universal Game State
        ↓
    MMO Runtime
        ↓
    Network Client
        ↓
    MMO Server

## 2. Core Principle

Game-specific knowledge should remain inside adapters whenever possible.

The MMO runtime should not contain Pokémon-specific, Zelda-specific, or other game-specific logic.

For example, the MMO runtime should work with concepts such as:

- Player
- Position
- Map
- Entity
- Inventory
- Interaction
- World state
- Game state

The GBA adapter translates the original game's internal representation into those concepts.

## 3. Major Components

### Emulator Integration

Responsible for communicating with the emulator or emulator core.

Responsibilities may include:

- Starting a game
- Reading memory
- Writing memory when permitted
- Accessing CPU state
- Accessing emulator state
- Runtime hooks
- Debugging

### Game Adapter

Responsible for understanding one specific game.

Example:

    adapters/
        gba/
            pokemon-emerald/

The adapter identifies important game state such as:

- Player position
- Current map
- Player state
- Relevant entities
- Inventory
- Progression
- Interaction state

### Universal Game State

Provides a normalized representation of game information.

Example:

    Player
        id
        position
        direction
        state

    World
        map
        entities

The exact structure will evolve as development progresses.

### MMO Runtime

Responsible for multiplayer behavior independent of the specific game.

Responsibilities include:

- Entity tracking
- Interest management
- Synchronization
- Player sessions
- Social systems
- MMO events

### Network Client

Communicates between the local game runtime and the MMO server.

### MMO Server

Responsible for authoritative multiplayer state.

Potential responsibilities include:

- Authentication
- Sessions
- Players
- World state
- Persistence
- Chat
- Parties
- Trading
- Security
- Server administration

## 4. Server Authority

The server should eventually be authoritative over multiplayer state.

The original game remains authoritative over its own gameplay whenever practical.

This creates a hybrid model:

    Original Game
         ↓
    Local Game State
         ↓
    Adapter
         ↓
    MMO Server
         ↓
    Other Players

## 5. Adapter Independence

The system should eventually support multiple adapters:

    MMO Runtime
         │
         ├── GBA Adapter
         │
         ├── Future GBA Game Adapter
         │
         ├── Future N64 Adapter
         │
         └── Other Platforms

The MMO runtime should not need to know which game is running.

## 6. Development Strategy

Development will proceed incrementally.

### Phase 0

Project foundation.

### Phase 1

Establish the GBA emulator/runtime environment.

### Phase 2

Inspect and expose GBA memory.

### Phase 3

Create the first game adapter.

### Phase 4

Read player state.

### Phase 5

Create a local multiplayer server.

### Phase 6

Synchronize two clients.

### Phase 7

Render or inject remote player state.

### Phase 8

Add persistence.

### Phase 9

Generalize the adapter system.

### Phase 10

Investigate automated adapter generation.

## 7. Important Constraint

The project does not distribute copyrighted game ROMs.

Users provide their own legally obtained game files for testing.