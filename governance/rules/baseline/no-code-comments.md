# No Code Comments

Clear identifiers, small functions, and commit messages carry all intent. Comments rot, mislead, and signal that the code itself is not self-explanatory.

## Don't

- Use `//`, `/* */`, `<!-- -->`, or `#` in shell/YAML/`.env`
- Add JSDoc / TSDoc blocks
- Leave `TODO`, `FIXME`, `NOTE`, `HACK`, `XXX` markers
- Commit commented-out dead code
- Add section-divider comments to organize long files
- Write comments that paraphrase what the code does
- Add `// eslint-disable-*` or `// @ts-ignore` — see `problem-solving`
- Restore comments that scaffolding tools left behind

## Do

- Rename the identifier so intent is obvious
- Extract a small function whose name describes what it does
- Put the why in the commit message body
- Strip pre-existing comments when editing the file
- Ask the user if context genuinely cannot live anywhere else

## Exceptions

- Shebang lines (`#!/usr/bin/env ...`)
- Tool directives required by the toolchain (`// @ts-check`, generated file headers)
- Markdown frontmatter (`---`) and prose in `README.md`, `CLAUDE.md`, `.claude/rules/*.md`, and `.agents/skills/**/*.md`
- Narrow, stack-specific exceptions documented in the stack overlay rule for the repository
