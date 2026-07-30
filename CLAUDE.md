# CLAUDE.md

- Use Dart dot-shorthands wherever possible, i.e. omit the type name when the
  context type is known: `.instance` instead of `EnumType.instance`.
- Prefer the dart MCP server whenever possible, especially `analyze_files` and
  `lsp` for source analysis and `read_package_uris`, `rip_grep_packages` and
  `pub_dev_search` for package introspection.
- When you're done, always format and analyze your changes: run `dart format .`
  from the workspace root (this is a pub workspace, so it covers all packages),
  then analyze via the dart MCP server's `analyze_files` — never the `dart
  analyze` CLI.
