---@param _p table palette (unused, all groups are links)
---@return table
local function lsp(_p)
  local groups = {
    -- LSP semantic token type links
    ['@lsp.type.class'] = { link = '@type' },
    ['@lsp.type.comment'] = { link = '@comment' },
    ['@lsp.type.decorator'] = { link = '@attribute' },
    ['@lsp.type.enum'] = { link = '@type' },
    ['@lsp.type.enumMember'] = { link = '@constant' },
    ['@lsp.type.event'] = { link = '@type' },
    -- Function and method references keep the call style; the declaration and
    -- definition modifier groups below carry the definition style.
    ['@lsp.type.function'] = { link = '@function.call' },
    ['@lsp.type.interface'] = { link = '@type' },
    ['@lsp.type.keyword'] = { link = '@keyword' },
    ['@lsp.type.macro'] = { link = '@function.macro' },
    ['@lsp.type.method'] = { link = '@function.method.call' },
    ['@lsp.type.modifier'] = { link = '@keyword.modifier' },
    ['@lsp.type.namespace'] = { link = '@module' },
    ['@lsp.type.number'] = { link = '@number' },
    ['@lsp.type.operator'] = { link = '@operator' },
    ['@lsp.type.parameter'] = { link = '@variable.parameter' },
    ['@lsp.type.property'] = { link = '@property' },
    ['@lsp.type.regexp'] = { link = '@string.regexp' },
    ['@lsp.type.string'] = { link = '@string' },
    ['@lsp.type.struct'] = { link = '@type' },
    ['@lsp.type.type'] = { link = '@type' },
    ['@lsp.type.typeParameter'] = { link = '@type' },
    ['@lsp.type.variable'] = { link = '@variable' },

    -- BasedPyright Python extensions
    ['@lsp.type.selfParameter.python'] = { link = '@variable.parameter.builtin' },
    ['@lsp.type.clsParameter.python'] = { link = '@variable.parameter.builtin' },

    -- Pyrefly sends self and cls as parameters with a selfParameter modifier.
    ['@lsp.typemod.parameter.selfParameter'] = { link = '@variable.parameter.builtin' },

    -- Built-ins keep their Treesitter colors once a server attaches.
    ['@lsp.typemod.function.defaultLibrary'] = { link = '@function.builtin' },
    ['@lsp.typemod.class.defaultLibrary'] = { link = '@type.builtin' },

    -- Some servers, such as emmylua_ls, mark every name that is never
    -- reassigned as readonly. Parameters are never constants, and Lua
    -- locals would otherwise mostly render in the constant color.
    ['@lsp.typemod.parameter.readonly'] = { link = '@variable.parameter' },
    ['@lsp.typemod.variable.readonly.lua'] = { link = '@variable' },

    -- Tombi TOML extensions
    ['@lsp.type.table.toml'] = { link = '@property' },
    ['@lsp.type.key.toml'] = { link = '@property' },
    ['@lsp.type.boolean.toml'] = { link = '@boolean' },
    ['@lsp.type.offsetDateTime.toml'] = { link = '@string.special' },
    ['@lsp.type.localDateTime.toml'] = { link = '@string.special' },
    ['@lsp.type.localDate.toml'] = { link = '@string.special' },
    ['@lsp.type.localTime.toml'] = { link = '@string.special' },

    -- LSP semantic token modifier overrides
    ['@lsp.mod.deprecated'] = { strikethrough = true },
    ['@lsp.mod.readonly'] = { link = '@constant' },
    ['@lsp.mod.async'] = { italic = true },
    ['@lsp.mod.static'] = { italic = true },
    ['@lsp.mod.abstract'] = { italic = true },
    ['@lsp.mod.documentation'] = { italic = true },
  }

  local definition_targets = {
    ['function'] = '@function',
    method = '@function.method',
    class = '@type.definition',
    enum = '@type.definition',
    interface = '@type.definition',
    struct = '@type.definition',
    type = '@type.definition',
  }
  for token_type, target in pairs(definition_targets) do
    for _, modifier in ipairs({ 'declaration', 'definition' }) do
      groups['@lsp.typemod.' .. token_type .. '.' .. modifier] = { link = target }
    end
  end

  return groups
end

return lsp
