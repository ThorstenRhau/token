std = "luajit"
unused = true

globals = {
    "vim",
}

read_globals = {
    "MiniStatusline",
    "MiniIcons",
}

include_files = { "lua/**/*.lua", "init.lua" }
exclude_files = { "README.md" }
