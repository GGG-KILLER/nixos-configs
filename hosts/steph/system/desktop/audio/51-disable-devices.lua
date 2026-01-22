-- wpctl status
-- wpctl inspect <device id>
-- Put in device.name here
local names = {
    -- "alsa_card.pci-0000_08_00.4", -- Aux ports
}

for _, name in ipairs(names)  do
    local rule = {
        matches = {
            {
                { "device.name", "equals", name },
            },
        },
        apply_properties = {
            ["device.disabled"] = true,
        }
    }

    table.insert(alsa_monitor.rules, rule)
end
