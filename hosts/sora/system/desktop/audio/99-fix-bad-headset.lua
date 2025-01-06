local rule = {
    matches = {
        {
            { "device.name", "equals", "alsa_card.usb-C-Media_Electronics_Inc._USB_Audio_Device-00" },
        },
    },
    apply_properties = {
        ["api.alsa.ignore-dB"] = true,
        ["api.alsa.volume"] = "ignore",
        ["api.alsa.volume-limit"] = 0.01,
    }
}

table.insert(alsa_monitor.rules, rule)