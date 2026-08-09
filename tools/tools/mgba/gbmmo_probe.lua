--[[
    GBMMO
    mGBA Integration Probe

    Phase 1 - mGBA Integration

    Purpose:
        Verify that GBMMO can communicate with mGBA,
        identify the running GBA game, inspect memory
        domains, inspect CPU registers, and observe
        emulator frames.

    IMPORTANT:
        This probe does not modify game memory.
]]

local GBMMO = {
    name = "GBMMO",
    version = "0.1.0",
    phase = "Phase 1 - mGBA Integration",

    initialized = false
}

------------------------------------------------------------
-- Logging
------------------------------------------------------------

local function log(message)
    console:log("[GBMMO] " .. message)
end

local function separator()
    log("----------------------------------------")
end

------------------------------------------------------------
-- Startup
------------------------------------------------------------

log("GBMMO probe loaded.")
log("Waiting for a GBA game...")

------------------------------------------------------------
-- Emulator information
------------------------------------------------------------

local function printEmulatorInfo()

    separator()

    log("GBMMO")
    log("mGBA Integration Probe")
    log("Version: " .. GBMMO.version)
    log("Phase: " .. GBMMO.phase)

    separator()

    log("Checking emulator integration...")

    --------------------------------------------------------
    -- Platform
    --------------------------------------------------------

    log("Emulator")

    local platformId = emu:getPlatform()

    log(
        "  Platform: Game Boy Advance"
    )

    log(
        "  Platform ID: "
        .. tostring(platformId)
    )

    --------------------------------------------------------
    -- Game
    --------------------------------------------------------

    separator()

    log("Game")

    local gameCode = emu:getGameCode()
    local romSize = emu:romSize()

    log(
        "  Game Code: "
        .. tostring(gameCode)
    )

    log(
        "  ROM Size: "
        .. tostring(romSize)
        .. " bytes"
    )

    --------------------------------------------------------
    -- Emulation
    --------------------------------------------------------

    separator()

    log("Emulation")

    log(
        "  Frequency: "
        .. tostring(emu:getFrequency())
        .. " Hz"
    )

    log(
        "  Current Frame: "
        .. tostring(emu:currentFrame())
    )

    log("")

    log("Game information: OK")

end

------------------------------------------------------------
-- Memory domains
------------------------------------------------------------

local function printMemoryDomains()

    separator()

    log("GBA Memory Domains")

    --------------------------------------------------------
    -- EWRAM
    --------------------------------------------------------

    local wram = emu.memory.wram

    if wram then

        log(
            string.format(
                "  EWRAM   OK | Base: 0x%08X | Size: %d bytes",
                wram:base(),
                wram:size()
            )
        )

    else

        log("  EWRAM   ERROR")

    end

    --------------------------------------------------------
    -- IWRAM
    --------------------------------------------------------

    local iwram = emu.memory.iwram

    if iwram then

        log(
            string.format(
                "  IWRAM   OK | Base: 0x%08X | Size: %d bytes",
                iwram:base(),
                iwram:size()
            )
        )

    else

        log("  IWRAM   ERROR")

    end

    --------------------------------------------------------
    -- MMIO
    --------------------------------------------------------

    local io = emu.memory.io

    if io then

        log(
            string.format(
                "  MMIO    OK | Base: 0x%08X | Size: %d bytes",
                io:base(),
                io:size()
            )
        )

    else

        log("  MMIO    ERROR")

    end

    --------------------------------------------------------
    -- Palette
    --------------------------------------------------------

    local palette = emu.memory.palette

    if palette then

        log(
            string.format(
                "  Palette OK | Base: 0x%08X | Size: %d bytes",
                palette:base(),
                palette:size()
            )
        )

    else

        log("  Palette ERROR")

    end

    --------------------------------------------------------
    -- VRAM
    --------------------------------------------------------

    local vram = emu.memory.vram

    if vram then

        log(
            string.format(
                "  VRAM    OK | Base: 0x%08X | Size: %d bytes",
                vram:base(),
                vram:size()
            )
        )

    else

        log("  VRAM    ERROR")

    end

    --------------------------------------------------------
    -- OAM
    --------------------------------------------------------

    local oam = emu.memory.oam

    if oam then

        log(
            string.format(
                "  OAM     OK | Base: 0x%08X | Size: %d bytes",
                oam:base(),
                oam:size()
            )
        )

    else

        log("  OAM     ERROR")

    end

    --------------------------------------------------------
    -- ROM
    --------------------------------------------------------

    local rom = emu.memory.rom

    if rom then

        log(
            string.format(
                "  ROM     OK | Base: 0x%08X | Size: %d bytes",
                rom:base(),
                rom:size()
            )
        )

    else

        log("  ROM     ERROR")

    end

    --------------------------------------------------------
    -- Count available domains
    --------------------------------------------------------

    local domains = {
        wram,
        iwram,
        io,
        palette,
        vram,
        oam,
        rom
    }

    local available = 0

    for _, domain in ipairs(domains) do

        if domain then
            available = available + 1
        end

    end

    log("")

    log(
        "Memory domains available: "
        .. tostring(available)
        .. "/7"
    )

end

------------------------------------------------------------
-- CPU register inspection
------------------------------------------------------------

local function printCPURegisters()

    separator()

    log("CPU Registers")

    local r0 = emu.cpu.r[0]
    local r1 = emu.cpu.r[1]
    local r2 = emu.cpu.r[2]
    local r3 = emu.cpu.r[3]
    local r13 = emu.cpu.r[13]
    local r14 = emu.cpu.r[14]
    local r15 = emu.cpu.r[15]

    log(
        "  r0   = "
        .. tostring(r0)
    )

    log(
        "  r1   = "
        .. tostring(r1)
    )

    log(
        "  r2   = "
        .. tostring(r2)
    )

    log(
        "  r3   = "
        .. tostring(r3)
    )

    log(
        "  r13  = "
        .. tostring(r13)
    )

    log(
        "  r14  = "
        .. tostring(r14)
    )

    log(
        "  r15  = "
        .. tostring(r15)
    )

    log(
        "  cpsr = "
        .. tostring(emu.cpu.cpsr)
    )

end

------------------------------------------------------------
-- Initialization
------------------------------------------------------------

local function initialize()

    if not emu then
        return
    end

    printEmulatorInfo()

    printMemoryDomains()

    printCPURegisters()

    separator()

    log("GBMMO mGBA integration initialized.")
    log("Frame callbacks are active.")
    log("Memory observation is available.")
    log("Game-specific analysis has NOT begun.")

    separator()

    GBMMO.initialized = true

end

------------------------------------------------------------
-- Frame callback
------------------------------------------------------------

local function onFrame()

    if not GBMMO.initialized then
        initialize()
    end

end

------------------------------------------------------------
-- Register callback
------------------------------------------------------------

callbacks:add(
    "frame",
    onFrame
)