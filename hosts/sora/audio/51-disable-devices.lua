local names = {
    "alsa_card.usb-Sonix_Technology_Co.__Ltd._USB_2.0_Camera_SN0001-02",
    "alsa_card.pci-0000_06_00.1",
    "alsa_card.pci-0000_08_00.4",
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