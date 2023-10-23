function get_base_style()
    return {
        path = res_path .. "windows-10-atlas.png",
        background_color = BreitbandGraphics.repeated_to_color(240),
        item_height = 15,
        font_size = 12,
        font_name = 'MS Sans Serif',
        button = {
            text_colors = {
                [1] = BreitbandGraphics.colors.black,
                [2] = BreitbandGraphics.colors.black,
                [3] = BreitbandGraphics.colors.black,
                [0] = BreitbandGraphics.repeated_to_color(131),
            },
            states = {
                [1] = {
                    source = expand_rect({ 1, 1, 11, 9 }),
                    center = expand_rect({ 6, 5, 1, 1 }),
                },
                [2] = {
                    source = expand_rect({ 1, 12, 11, 9 }),
                    center = expand_rect({ 6, 16, 1, 1 }),
                },
                [3] = {
                    source = expand_rect({ 1, 23, 11, 9 }),
                    center = expand_rect({ 6, 27, 1, 1 }),
                },
                [0] = {
                    source = expand_rect({ 1, 34, 11, 9 }),
                    center = expand_rect({ 6, 38, 1, 1 }),
                }
            }
        },
        textbox = {
            text_colors = {
                [1] = BreitbandGraphics.colors.black,
                [2] = BreitbandGraphics.colors.black,
                [3] = BreitbandGraphics.colors.black,
                [0] = BreitbandGraphics.repeated_to_color(109),
            },
            states = {
                [1] = {
                    source = expand_rect({ 74, 1, 5, 5 }),
                    center = expand_rect({ 76, 3, 1, 1 }),
                },
                [2] = {
                    source = expand_rect({ 74, 6, 5, 5 }),
                    center = expand_rect({ 76, 8, 1, 1 }),
                },
                [3] = {
                    source = expand_rect({ 74, 11, 5, 5 }),
                    center = expand_rect({ 76, 13, 1, 1 }),
                },
                [0] = {
                    source = expand_rect({ 74, 16, 5, 5 }),
                    center = expand_rect({ 76, 18, 1, 1 }),
                }
            }
        },
        listbox = {
            text_colors = {
                [1] = BreitbandGraphics.colors.black,
                [2] = BreitbandGraphics.colors.black,
                [3] = BreitbandGraphics.colors.white,
                [0] = BreitbandGraphics.repeated_to_color(204),
            },
            states = {
                [1] = {
                    source = expand_rect({ 80, 1, 3, 3 }),
                    center = expand_rect({ 81, 2, 1, 1 }),
                },
                [2] = {
                    source = expand_rect({ 80, 1, 3, 3 }),
                    center = expand_rect({ 81, 2, 1, 1 }),
                },
                [3] = {
                    source = expand_rect({ 80, 1, 3, 3 }),
                    center = expand_rect({ 81, 2, 1, 1 }),
                },
                [0] = {
                    source = expand_rect({ 80, 10, 3, 3 }),
                    center = expand_rect({ 81, 11, 1, 1 }),
                }
            }
        },
        listbox_item = {
            states = {
                [1] = {
                    source = expand_rect({ 83, 5, 3, 4 }),
                    center = expand_rect({ 84, 6, 1, 2 }),
                },
                [2] = {
                    source = expand_rect({ 83, 5, 3, 4 }),
                    center = expand_rect({ 84, 6, 1, 2 }),
                },
                [3] = {
                    source = expand_rect({ 83, 1, 3, 4 }),
                    center = expand_rect({ 84, 2, 1, 2 }),
                },
                [0] = {
                    source = expand_rect({ 83, 5, 3, 4 }),
                    center = expand_rect({ 84, 6, 1, 2 }),
                }
            }
        },
        scrollbar_thumb = {
            states = {
                [1] = {
                    source = expand_rect({ 30, 66, 17, 11 }),
                    center = expand_rect({ 38, 70, 2, 3 }),
                },
                [2] = {
                    source = expand_rect({ 30, 77, 17, 11 }),
                    center = expand_rect({ 38, 81, 2, 3 }),
                },
                [3] = {
                    source = expand_rect({ 30, 88, 17, 11 }),
                    center = expand_rect({ 38, 92, 2, 3 }),
                },
                [0] = {
                    source = expand_rect({ 30, 110, 17, 11 }),
                    center = expand_rect({ 38, 114, 2, 3 }),
                }
            }
        },
        scrollbar_rail = expand_rect({ 30, 99, 17, 11 })
    }
end
