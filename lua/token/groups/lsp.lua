---@param _p table palette (unused, all groups are links)
---@return table
local function lsp(_p)
  return {
    -- LSP semantic token type links
    ['@lsp.type.class'] = { link = '@type' },
    ['@lsp.type.comment'] = { link = '@comment' },
    ['@lsp.type.decorator'] = { link = '@attribute' },
    ['@lsp.type.enum'] = { link = '@type' },
    ['@lsp.type.enumMember'] = { link = '@constant' },
    ['@lsp.type.event'] = { link = '@type' },
    ['@lsp.type.function'] = { link = '@function' },
    ['@lsp.type.interface'] = { link = '@type' },
    ['@lsp.type.keyword'] = { link = '@keyword' },
    ['@lsp.type.macro'] = { link = '@function.macro' },
    ['@lsp.type.method'] = { link = '@function.method' },
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

    -- LSP semantic token modifier overrides
    ['@lsp.mod.deprecated'] = { strikethrough = true },
    ['@lsp.mod.readonly'] = { link = '@constant' },
    ['@lsp.mod.async'] = { italic = true },
    ['@lsp.mod.static'] = { italic = true },
    ['@lsp.mod.abstract'] = { italic = true },
    ['@lsp.mod.declaration'] = { bold = true },
    ['@lsp.mod.definition'] = { bold = true },
    ['@lsp.mod.defaultLibrary'] = { italic = true },
    ['@lsp.mod.documentation'] = { italic = true },
    ['@lsp.mod.modification'] = { bold = true },
  }
end

return lsp
