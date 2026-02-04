{
  llm-agents,
  system,
  ...
}: {
  home.packages = with llm-agents.packages.${system}; [
    claude-code
    codex
    pi
  ];
}
