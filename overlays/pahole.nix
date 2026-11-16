_: prev: {
  # not upstream yet; drop once pahole keeps the c units of a module whose first unit is rust
  pahole = prev.pahole.overrideAttrs (old: {
    patches = (old.patches or []) ++ [./pahole-merged-cu-language.patch];
  });
}
