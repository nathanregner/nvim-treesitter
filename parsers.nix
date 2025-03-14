{ vimPlugins, linkFarm }:
let
  plugin = vimPlugins.nvim-treesitter.withAllGrammars;
  grammars = plugin.passthru.dependencies;
in
linkFarm "nvim-treesitter-grammars" (
  builtins.map (
    grammar:
    let
      language = builtins.elemAt (builtins.match "vimplugin-treesitter-grammar-(.*)" grammar.name) 0;
    in
    {
      name = "parser/${language}.so";
      path = "${grammar}/parser/${language}.so";
    }
  ) grammars
)
