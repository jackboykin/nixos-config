{
  pkgs,
  theme,
  ...
}: let
  colors = theme.colors;
  ui = theme.ui;
in {
  programs.bat = {
    enable = true;
    config = {
      theme = "bellatrix";
    };
  };

  xdg.configFile."bat/themes/bellatrix.tmTheme".text = ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
      <dict>
        <key>name</key>
        <string>bellatrix</string>
        <key>semanticClass</key>
        <string>theme.dark.bellatrix</string>
        <key>uuid</key>
        <string>627ce890-fabb-4d39-9819-7be71f4bdca7</string>
        <key>author</key>
        <string>Tnixc</string>
        <key>colorSpaceName</key>
        <string>sRGB</string>
        <key>settings</key>
        <array>
          <dict>
            <key>settings</key>
            <dict>
              <key>background</key>
              <string>${colors.base}</string>
              <key>foreground</key>
              <string>${colors.text}</string>
              <key>caret</key>
              <string>${colors.purple}</string>
              <key>lineHighlight</key>
              <string>${colors.surface1}</string>
              <key>misspelling</key>
              <string>${colors.red}</string>
              <key>accent</key>
              <string>${colors.purple}</string>
              <key>selection</key>
              <string>${colors.overlay1}40</string>
              <key>activeGuide</key>
              <string>${colors.surface2}</string>
              <key>findHighlight</key>
              <string>${ui.findHighlight}</string>
              <key>gutterForeground</key>
              <string>${colors.subtext1}</string>
            </dict>
          </dict>
          <dict>
            <key>name</key>
            <string>Basic text &amp; variable names</string>
            <key>scope</key>
            <string>text, source, variable.other.readwrite, punctuation.definition.variable</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.text}</string>
            </dict>
          </dict>
          <dict>
            <key>name</key>
            <string>Parentheses, Brackets, Braces</string>
            <key>scope</key>
            <string>punctuation</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.subtext0}</string>
            </dict>
          </dict>
          <dict>
            <key>name</key>
            <string>Comments</string>
            <key>scope</key>
            <string>comment, punctuation.definition.comment</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.overlay0}</string>
              <key>fontStyle</key>
              <string>italic</string>
            </dict>
          </dict>
          <dict>
            <key>scope</key>
            <string>string, punctuation.definition.string</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.green}</string>
            </dict>
          </dict>
          <dict>
            <key>scope</key>
            <string>constant.character.escape</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.purple}</string>
            </dict>
          </dict>
          <dict>
            <key>name</key>
            <string>Booleans, constants, numbers</string>
            <key>scope</key>
            <string>constant.numeric, variable.other.constant, entity.name.constant, constant.language.boolean</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.orange}</string>
            </dict>
          </dict>
          <dict>
            <key>scope</key>
            <string>keyword, keyword.operator.word, storage.type, storage.modifier</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.purple}</string>
            </dict>
          </dict>
          <dict>
            <key>name</key>
            <string>Operators</string>
            <key>scope</key>
            <string>keyword.operator, punctuation.accessor</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.cyan}</string>
            </dict>
          </dict>
          <dict>
            <key>scope</key>
            <string>entity.name.function, support.function, variable.function</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.blue}</string>
              <key>fontStyle</key>
              <string>italic</string>
            </dict>
          </dict>
          <dict>
            <key>name</key>
            <string>Classes</string>
            <key>scope</key>
            <string>entity.name.class, entity.other.inherited-class, support.class, entity.name.type</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.yellow}</string>
              <key>fontStyle</key>
              <string>italic</string>
            </dict>
          </dict>
          <dict>
            <key>scope</key>
            <string>variable.parameter</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.red}</string>
              <key>fontStyle</key>
              <string>italic</string>
            </dict>
          </dict>
          <dict>
            <key>name</key>
            <string>Built-ins</string>
            <key>scope</key>
            <string>constant.language, support.function.builtin</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.red}</string>
            </dict>
          </dict>
          <dict>
            <key>name</key>
            <string>Nix attribute names</string>
            <key>scope</key>
            <string>entity.other.attribute-name.multipart.nix, entity.other.attribute-name.single.nix</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.blue}</string>
            </dict>
          </dict>
          <dict>
            <key>name</key>
            <string>JSON/YAML keys</string>
            <key>scope</key>
            <string>support.type.property-name.json, support.type.property-name.toml, entity.name.tag.yaml</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.blue}</string>
            </dict>
          </dict>
          <dict>
            <key>name</key>
            <string>Markdown headings</string>
            <key>scope</key>
            <string>markup.heading</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.yellow}</string>
            </dict>
          </dict>
          <dict>
            <key>scope</key>
            <string>markup.bold</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.red}</string>
              <key>fontStyle</key>
              <string>bold</string>
            </dict>
          </dict>
          <dict>
            <key>scope</key>
            <string>markup.italic</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.red}</string>
              <key>fontStyle</key>
              <string>italic</string>
            </dict>
          </dict>
          <dict>
            <key>name</key>
            <string>Diff Inserted</string>
            <key>scope</key>
            <string>markup.inserted.diff</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.green}</string>
            </dict>
          </dict>
          <dict>
            <key>name</key>
            <string>Diff Deleted</string>
            <key>scope</key>
            <string>markup.deleted.diff</string>
            <key>settings</key>
            <dict>
              <key>foreground</key>
              <string>${colors.red}</string>
            </dict>
          </dict>
        </array>
      </dict>
    </plist>
  '';
}
