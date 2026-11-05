{
  lib,
  pkgs,
  ...
}: let
  inherit (import ../theme.nix) colors diff ui;

  toml = pkgs.formats.toml {};

  paint = color: scopes: lib.genAttrs scopes (_: color);
in {
  users.users.jack.packages = [pkgs.hunk];

  castle.links.".config/hunk/config.toml" = toml.generate "config.toml" {
    theme = "bellatrix";
    wheel_scroll_lines = 4;
    cursor_line = "number";

    themes.bellatrix = {
      base = "vitesse-black";
      label = "Bellatrix";

      inherit (colors) background text;
      panel = colors.base;
      panelAlt = colors.surface0;
      border = colors.surface1;
      accent = colors.purple;
      accentMuted = ui.selection;
      muted = colors.subtext1;

      addedBg = diff.added;
      removedBg = diff.removed;
      movedAddedBg = diff.moved;
      movedRemovedBg = diff.moved;
      contextBg = colors.base;
      addedContentBg = diff.addedEmph;
      removedContentBg = diff.removedEmph;
      contextContentBg = colors.base;
      addedSignColor = colors.gitAdded;
      removedSignColor = colors.gitDeleted;
      lineNumberBg = colors.base;
      lineNumberFg = colors.surface2;
      selectedHunk = colors.surface1;

      badgeAdded = colors.gitAdded;
      badgeRemoved = colors.gitDeleted;
      badgeNeutral = colors.subtext1;
      fileNew = colors.gitAdded;
      fileDeleted = colors.gitDeleted;
      fileRenamed = colors.cyan;
      fileModified = colors.gitModified;
      fileUntracked = colors.subtext1;

      noteBorder = colors.purple;
      noteBackground = colors.surface0;
      noteTitleBackground = colors.surface1;
      noteTitleText = colors.text;

      syntax_scopes = lib.mergeAttrsList [
        (paint colors.text [
          "source"
          "variable"
          "identifier"
          "meta.definition.variable"
          "punctuation"
          "meta.brace"
          "delimiter"
          "keyword.operator"
          "keyword.operator.assignment"
          "keyword.operator.assignment.compound"
          "keyword.operator.relational"
          "keyword.operator.spread"
          "keyword.operator.rest"
          "keyword.operator.type"
          "keyword.operator.type.annotation"
          "meta.type.annotation"
        ])
        (paint colors.surface2 [
          "comment"
          "punctuation.definition.comment"
          "string.comment"
        ])
        (paint colors.purple [
          "keyword"
          "storage"
          "storage.type"
        ])
        (paint colors.green [
          "string"
          "string variable"
          "punctuation.definition.string"
        ])
        (paint colors.orange [
          "constant"
          "constant.language"
          "constant.language.boolean"
          "constant.language.null"
          "constant.language.undefined"
          "constant.numeric"
          "number"
          "support.constant"
          "entity.name.constant"
        ])
        (paint colors.blue [
          "entity"
          "entity.name"
          "entity.name.function"
          "support.function"
          "variable.function"
        ])
        (paint colors.yellow [
          "entity.name.type"
          "entity.name.class"
          "entity.name.namespace"
          "namespace"
          "meta.module-reference"
          "type.identifier"
          "keyword.type"
          "support"
          "support.type"
          "support.type.builtin"
          "support.type.primitive"
          "support.class"
        ])
        (paint colors.red [
          "variable.parameter"
          "variable.parameter.function"
        ])
        (paint colors.cyan [
          "property"
          "attribute.name"
          "entity.other.attribute-name"
          "entity.name.tag.yaml"
          "meta.object-literal.key"
          "meta.property-name"
          "support.variable.property"
          "variable.other.member"
          "variable.other.property"
        ])
      ];
    };
  };
}
