# Contributing

Thanks for considering contributions to light! Your help is appreciated.

## Questions

If you have a question regarding an official implementation of holy-light, there are three places you can reach me, in
order of most to least preferred. Please only use my discord for critical bug reports or important issues:

- [Github Issues](https://light.ardi.gg/github_issues)

- [The Roblox OSS Server](https://discord.com/invite/5KjV64PA3d)

- [My Discord](https://discord.com/users/331399684415553538/)

## API Documentation

The documentation is primarily available through a site built with [Mkdocs](https://www.mkdocs.org/), and
[Material For Mkdocs](https://squidfunk.github.io/mkdocs-material/). Changes to the documentation site will be built
automatically when a PR is merged.

## Setup

Light can be set up locally by installing [Rokit](https://github.com/rojo-rbx/rokit) and running the following commands
in the project's root directory:

```none
rokit install
rojo sourcemap -o sourcemap.json
```

See [Tools](#tools) for more info.

## Style

For preferred inline documentation rules, general practices, etc., see [STYLE.md](./STYLE.md).

## Bugs & Feature Requests

If something isn't right (Unprecedented warnings, errors, etc.), please check if it's reported before opening a
[Github Issue](https://light.ardi.gg/github_issues). You're also always welcome to
[Pull Request](https://light.ardi.gg/github_pull_request) a bugfix or feature request after an issue has been opened for
it.

## Performance Enhancements

Performance enhancements are always welcome as an [Issue](https://light.ardi.gg/github_issues), or
[Pull Request](https://light.ardi.gg/github_pull_request). You will be expected to provide an explanation as to why the
optimization is worthwhile, and / or why it will yield better performance for most users. I.e.,:

- Logical Explanation of what is being optimized <small>(In the motivation of an RFC)</small>

- Benchmarks <small>(For pull requests)</small>

## Tools

Light requires a minimal set of external tools to make contributing smooth:

[NPM](https://www.npmjs.com/) (For authoring roblox-ts modifications)

[Luau LSP](https://github.com/JohnnyMorganz/luau-lsp) For luau autocomplete & editor typechecking

[MarkdownLint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint) (VSCode Plugin for linting .md files if working on docs)

[Rokit](https://github.com/rojo-rbx/rokit) For installing and using the folloiwng CLI tools:

- [Lune](https://github.com/lune-org/lune) (For running a test environment)

- [Rojo](https://rojo.space/) (For testing runtime-specific features on Roblox)

- [Stylua](https://github.com/JohnnyMorganz/StyLua) (For styling luau code)

## Testing

Testing for most changes to the library is done through a set of
[Lune](https://github.com/lune-org/lune) scripts found in `tests/cases/*`, and will be run on a pull request or with the
command `lune run tests`. However, for some runtime-specific features of light
(such as changes to the impl_roblox folder), tests are run in Roblox Studio with [Rojo](https://rojo.space/). Make sure
you've followed the steps in [Setup](#setup), and run the following command in the project's root directory:

```none
lune run test_roblox
```

In the Roblox Studio window that is opened, make sure to sync with Rojo before testing the development place with 2-8
connected clients.

## Licensing

By contributing changes to this repository, you license your contribution under the MIT License, and you agree that you
have the right to license your contribution under those terms.
