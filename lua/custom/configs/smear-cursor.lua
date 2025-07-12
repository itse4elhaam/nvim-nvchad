return {
  smear_between_buffers = true,
  smear_between_neighbor_lines = true,
  smear_horizontally = true,
  smear_vertically = true,
  smear_diagonally = true,

  smear_to_cmd = true,
  smear_insert_mode = true,
  smear_replace_mode = false,
  smear_terminal_mode = false,

  vertical_bar_cursor = true,
  vertical_bar_cursor_insert_mode = true,
  horizontal_bar_cursor_replace_mode = true,

  never_draw_over_target = true,
  hide_target_hack = false,

  time_interval = 16, -- ~60FPS
  delay_event_to_smear = 2,
  delay_after_key = 4,

  stiffness = 0.8,                -- Snappy cursor
  trailing_stiffness = 0.45,      -- A bit of trailing effect
  trailing_exponent = 2,          -- Curve favors the head
  distance_stop_animating = 0.15, -- Stops early for crispness

  stiffness_insert_mode = 0.55,
  trailing_stiffness_insert_mode = 0.35,
  trailing_exponent_insert_mode = 1.2,
  distance_stop_animating_vertical_bar = 0.6,

  -- Smear limits
  max_length = 20,
  max_length_insert_mode = 1,
}
