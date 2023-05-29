-- wpctl status
-- wpctl inspect <device id>
-- Put in device.name here
local names = {
    "alsa_card.usb-Sonix_Technology_Co.__Ltd._USB_2.0_Camera_SN0001-02", -- Webcam
    "alsa_card.pci-0000_06_00.1", -- NVIDIA HDMI Output
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