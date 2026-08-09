--[[
    GBMMO
    GBA Memory Discovery Scanner

    Phase 2A
    Memory Snapshot and Comparison

    Commands:

        gbmmo_snapshot()

            Captures the current EWRAM and IWRAM.

        gbmmo_compare()

            Compares the two most recent snapshots.

        gbmmo_reset()

            Deletes all stored snapshots.

        gbmmo_status()

            Displays scanner status.

    IMPORTANT:

        This scanner ONLY READS emulator memory.

        It does NOT modify the game.
]]

local GBMMO = {
    name = "GBMMO",
    version = "0.2.2",
    phase = "Phase 2A - Memory Discovery",

    snapshots = {},

    snapshotCount = 0,

    scanDomains = {
        "wram",
        "iwram"
    },

    maxReportedChanges = 100
}

------------------------------------------------------------
-- Logging
------------------------------------------------------------

local function log(message)
    console:log("[GBMMO SCANNER] " .. message)
end

local function warn(message)
    console:warn("[GBMMO SCANNER] " .. message)
end

local function errorLog(message)
    console:error("[GBMMO SCANNER] " .. message)
end

local function separator()
    log("----------------------------------------")
end

------------------------------------------------------------
-- Utility
------------------------------------------------------------

local function formatHex(value)
    return string.format("0x%08X", value)
end

------------------------------------------------------------
-- Memory domain
------------------------------------------------------------

local function getDomain(name)

    if not emu then
        return nil
    end

    if not emu.memory then
        return nil
    end

    return emu.memory[name]
end

------------------------------------------------------------
-- Capture one memory domain
------------------------------------------------------------

local function captureDomain(name)

    local domain = getDomain(name)

    if not domain then

        warn(
            "Memory domain unavailable: "
            .. tostring(name)
        )

        return nil
    end

    local base = domain:base()
    local size = domain:size()

    local snapshot = {
        name = domain:name(),
        base = base,
        size = size,
        data = {}
    }

    log(
        string.format(
            "Reading %s (%d bytes)...",
            snapshot.name,
            size
        )
    )

    for offset = 0, size - 1 do

        snapshot.data[offset] =
            domain:read8(offset)

    end

    return snapshot
end

------------------------------------------------------------
-- Capture complete memory snapshot
------------------------------------------------------------

function gbmmo_snapshot()

    if not emu then

        errorLog(
            "No game is currently loaded."
        )

        return
    end

    local number =
        GBMMO.snapshotCount + 1

    separator()

    log(
        "CAPTURING SNAPSHOT #"
        .. tostring(number)
    )

    log(
        "Game Code: "
        .. tostring(emu:getGameCode())
    )

    log(
        "Frame: "
        .. tostring(emu:currentFrame())
    )

    local snapshot = {

        frame = emu:currentFrame(),

        domains = {}

    }

    for _, domainName in
        ipairs(GBMMO.scanDomains) do

        local domainSnapshot =
            captureDomain(domainName)

        if domainSnapshot then

            snapshot.domains[domainName] =
                domainSnapshot

        end

    end

    GBMMO.snapshotCount =
        number

    GBMMO.snapshots[number] =
        snapshot

    log(
        "Snapshot #"
        .. tostring(number)
        .. " COMPLETE."
    )

    separator()

end

------------------------------------------------------------
-- Read 16-bit little-endian value
------------------------------------------------------------

local function read16(data, offset)

    local b0 = data[offset]

    local b1 = data[offset + 1]

    if b0 == nil or b1 == nil then
        return nil
    end

    return b0 + (b1 * 256)

end

------------------------------------------------------------
-- Read 32-bit little-endian value
------------------------------------------------------------

local function read32(data, offset)

    local b0 = data[offset]
    local b1 = data[offset + 1]
    local b2 = data[offset + 2]
    local b3 = data[offset + 3]

    if b0 == nil or
       b1 == nil or
       b2 == nil or
       b3 == nil then

        return nil

    end

    return
        b0 +
        (b1 * 256) +
        (b2 * 65536) +
        (b3 * 16777216)

end

------------------------------------------------------------
-- Compare bytes
------------------------------------------------------------

local function compareBytes(first, second)

    local changes = {}

    for offset = 0, first.size - 1 do

        local oldValue =
            first.data[offset]

        local newValue =
            second.data[offset]

        if oldValue ~= newValue then

            changes[#changes + 1] = {

                address =
                    first.base + offset,

                oldValue =
                    oldValue,

                newValue =
                    newValue

            }

            if #changes >=
                GBMMO.maxReportedChanges then

                break

            end

        end

    end

    return changes

end

------------------------------------------------------------
-- Compare 16-bit values
------------------------------------------------------------

local function compare16(first, second)

    local changes = {}

    for offset = 0, first.size - 2, 2 do

        local oldValue =
            read16(
                first.data,
                offset
            )

        local newValue =
            read16(
                second.data,
                offset
            )

        if oldValue ~= newValue then

            changes[#changes + 1] = {

                address =
                    first.base + offset,

                oldValue =
                    oldValue,

                newValue =
                    newValue,

                delta =
                    newValue - oldValue

            }

            if #changes >=
                GBMMO.maxReportedChanges then

                break

            end

        end

    end

    return changes

end

------------------------------------------------------------
-- Compare 32-bit values
------------------------------------------------------------

local function compare32(first, second)

    local changes = {}

    for offset = 0, first.size - 4, 4 do

        local oldValue =
            read32(
                first.data,
                offset
            )

        local newValue =
            read32(
                second.data,
                offset
            )

        if oldValue ~= newValue then

            changes[#changes + 1] = {

                address =
                    first.base + offset,

                oldValue =
                    oldValue,

                newValue =
                    newValue,

                delta =
                    newValue - oldValue

            }

            if #changes >=
                GBMMO.maxReportedChanges then

                break

            end

        end

    end

    return changes

end

------------------------------------------------------------
-- Print byte changes
------------------------------------------------------------

local function printByteChanges(changes)

    log(
        "8-BIT CHANGES: "
        .. tostring(#changes)
    )

    for _, change in
        ipairs(changes) do

        log(
            string.format(
                "  %s : %3d -> %3d",
                formatHex(change.address),
                change.oldValue,
                change.newValue
            )
        )

    end

end

------------------------------------------------------------
-- Print 16-bit changes
------------------------------------------------------------

local function print16Changes(changes)

    log(
        "16-BIT CHANGES: "
        .. tostring(#changes)
    )

    for _, change in
        ipairs(changes) do

        log(
            string.format(
                "  %s : %5d -> %5d  Delta: %+d",
                formatHex(change.address),
                change.oldValue,
                change.newValue,
                change.delta
            )
        )

    end

end

------------------------------------------------------------
-- Print 32-bit changes
------------------------------------------------------------

local function print32Changes(changes)

    log(
        "32-BIT CHANGES: "
        .. tostring(#changes)
    )

    for _, change in
        ipairs(changes) do

        log(
            string.format(
                "  %s : %10d -> %10d  Delta: %+d",
                formatHex(change.address),
                change.oldValue,
                change.newValue,
                change.delta
            )
        )

    end

end

------------------------------------------------------------
-- Compare latest two snapshots
------------------------------------------------------------

function gbmmo_compare()

    if GBMMO.snapshotCount < 2 then

        warn(
            "At least TWO snapshots "
            .. "are required."
        )

        return

    end

    local first =
        GBMMO.snapshots[
            GBMMO.snapshotCount - 1
        ]

    local second =
        GBMMO.snapshots[
            GBMMO.snapshotCount
        ]

    separator()

    log("COMPARING SNAPSHOTS")

    log(
        "Snapshot A frame: "
        .. tostring(first.frame)
    )

    log(
        "Snapshot B frame: "
        .. tostring(second.frame)
    )

    log(
        "Frame difference: "
        .. tostring(
            second.frame - first.frame
        )
    )

    for _, domainName in
        ipairs(GBMMO.scanDomains) do

        local firstDomain =
            first.domains[domainName]

        local secondDomain =
            second.domains[domainName]

        if firstDomain and
           secondDomain then

            separator()

            log(
                "DOMAIN: "
                .. firstDomain.name
            )

            local bytes =
                compareBytes(
                    firstDomain,
                    secondDomain
                )

            local values16 =
                compare16(
                    firstDomain,
                    secondDomain
                )

            local values32 =
                compare32(
                    firstDomain,
                    secondDomain
                )

            printByteChanges(bytes)

            log("")

            print16Changes(values16)

            log("")

            print32Changes(values32)

        end

    end

    separator()

    log("COMPARISON COMPLETE.")

    separator()

end

------------------------------------------------------------
-- Reset
------------------------------------------------------------

function gbmmo_reset()

    GBMMO.snapshots = {}

    GBMMO.snapshotCount = 0

    separator()

    log("Scanner reset.")

    separator()

end

------------------------------------------------------------
-- Status
------------------------------------------------------------

function gbmmo_status()

    separator()

    log("GBMMO MEMORY SCANNER")

    log(
        "Version: "
        .. GBMMO.version
    )

    log(
        "Phase: "
        .. GBMMO.phase
    )

    if emu then

        log(
            "Game Code: "
            .. tostring(
                emu:getGameCode()
            )
        )

        log(
            "ROM Size: "
            .. tostring(
                emu:romSize()
            )
        )

        log(
            "Current Frame: "
            .. tostring(
                emu:currentFrame()
            )
        )

    end

    log(
        "Snapshots stored: "
        .. tostring(
            GBMMO.snapshotCount
        )
    )

    separator()

end

------------------------------------------------------------
-- Initialization
------------------------------------------------------------

separator()

log("GBMMO Memory Discovery Scanner")

log(
    "Version: "
    .. GBMMO.version
)

log(
    "Phase: "
    .. GBMMO.phase
)

separator()

log(
    "This scanner ONLY READS memory."
)

log(
    "No game memory will be modified."
)

separator()

if emu then

    log(
        "Game Code: "
        .. tostring(
            emu:getGameCode()
        )
    )

end

separator()

log("Available commands:")

log(
    "  gbmmo_snapshot()"
)

log(
    "  gbmmo_compare()"
)

log(
    "  gbmmo_reset()"
)

log(
    "  gbmmo_status()"
)

separator()

log("Scanner ready.")

separator()