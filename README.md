# GBMMO
# GBA MMO Engine

A universal multiplayer framework designed to transform compatible single-player GBA games into persistent multiplayer experiences.

## Project Vision

The long-term goal of this project is to create a game-agnostic MMO framework capable of connecting multiple players to games that were originally designed for single-player.

The original game remains responsible for its gameplay and presentation.

The MMO framework provides:

- Multiplayer synchronization
- Player networking
- Persistent online identities
- World state
- Chat
- Social systems
- Trading
- Parties
- Game-specific adapters
- Server infrastructure

## Initial Target

The first supported platform is the Game Boy Advance.

The first development target will be a single known GBA game.

Once the architecture has been proven, additional GBA games will be investigated.

## Architecture

The project is divided into several major layers:

1. Emulator integration
2. Game adapter
3. Universal game-state interface
4. MMO runtime
5. Network client
6. MMO server
7. Persistent data

See `docs/ARCHITECTURE.md` for the current architecture specification.

## Development Philosophy

The project is being developed incrementally.

Each phase must produce a working and testable milestone before the next phase begins.

The project should avoid unnecessary dependencies and favor free and open-source tooling wherever practical.

## ROMs

This project does not distribute copyrighted ROMs.

Testing requires the user to provide game files they are legally entitled to use.

## Current Status

### Phase 0 — Project Foundation

- [x] Repository created
- [x] Project structure defined
- [x] Architecture documented
- [ ] Development environment established
- [ ] Emulator integration
- [ ] GBA memory inspection
- [ ] First game adapter
- [ ] Multiplayer prototype
- [ ] Persistent server
- [ ] Universal adapter system

## Long-Term Goal

The ultimate goal is to make the MMO layer as independent from individual games as possible.

A future adapter should theoretically allow the same MMO infrastructure to support multiple games without rewriting the entire engine.