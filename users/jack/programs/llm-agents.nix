{
  llm-agents,
  system,
  ...
}: {
  home.packages = with llm-agents.packages.${system}; [
    amp
    claude-code
    opencode
    pi
  ];
}
