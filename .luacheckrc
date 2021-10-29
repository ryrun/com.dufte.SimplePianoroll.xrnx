--allow long lines :D
max_line_length = 200

--define needed globals of the piano roll tool for luacheck
globals = {
    "renoise",
    "keyClick",
    "noteClick",
    "pianoGridClick",
    "setPlaybackPos"
}

--define renoise special table function for luacheck
read_globals = {
  table = {
     fields = {
        copy = {},
        count = {}
     }
  }
}