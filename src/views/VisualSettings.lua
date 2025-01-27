local items = {
    {
        text = "Style",
        func = function(rect)
            local new_active_style_index = ugui.combobox({
                uid = 1,
                rectangle = rect,
                items = Styles.theme_names(),
                selected_index = Settings.active_style_index,
            })

            if new_active_style_index ~= Settings.active_style_index then
                Settings.active_style_index = new_active_style_index
                Styles.update_style()
            end
        end
    },
    {
        text = "Notifications",
        func = function(rect)
            local notification_styles = {
                "Bubble",
                "Console",
            }

            local index = ugui.carrousel_button({
                uid = 5,
                rectangle = rect,
                items = notification_styles,
                selected_index = Settings.notification_style,
            })

            Settings.notification_style = index
        end
    },
    {
        text = "Fast-forward frame skip",
        func = function(rect)
            Settings.repaint_throttle = math.max(1, math.abs(ugui.numberbox({
                uid = 20,
                rectangle = rect,
                tooltip = "Skips every nth frame when fast-forwarding to increase performance.",
                value = Settings.repaint_throttle,
                places = 1,
            })))
        end
    },
    {
        text = "Update every VI",
        func = function(rect)
            Settings.read_memory_every_vi = ugui.toggle_button({
                uid = 25,
                rectangle = rect,
                tooltip = "Updates the UI every VI, improving mupen capture sync. Reduces performance.",
                text = Settings.read_memory_every_vi and "On" or "Off",
                is_checked = Settings.read_memory_every_vi,
            })
        end
    },
}

return {
    name = "Visuals",
    draw = function()
        Drawing.setting_list(items, { x = 0, y = 0.1 })
    end
}
