-- Nix-specific treesitter node types for hlchunk
-- Covers: let expressions, attribute sets, lambda functions, with expressions, etc.
-- Format: node_type = true (table with keys, not array)
return {
    let_expression = true,          -- let ... in ...
    attrset_expression = true,      -- { ... }
    rec_attrset_expression = true,  -- rec { ... }
    list_expression = true,         -- [ ... ]
    lambda_expression = true,       -- arg: body
    function_expression = true,     -- { args }: body  
    with_expression = true,         -- with ...; ...
    if_expression = true,           -- if ... then ... else ...
    assert_expression = true,       -- assert ...; ...
    binding = true,                 -- name = value;
    inherit = true,                 -- inherit ...;
    inherit_from = true,            -- inherit (...) ...;
}
