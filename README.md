# 🖥️ CodeMonitor

A engine to collect multiple metrics from your repository and push them to a
time series provider.


# Engines

## Git

Collect multiple metrics from the a Git repository.

**Requirements / Setup**:

You need a `.git` folder present in the current folder:

**Options**:

`CODEMONITOR_GIT_FILES_THRESHOLD`: Don't emit metrics about number of files, from those that are above of this threshold. (Default: `0`)

## Eslint

Collect multiple metrics from the a project with [Eslint](https://eslint.org/) configured.

**Requirements / Setup**:

You need a `.eslintrc.js` and a `eslint.output.json` file present in the current folder.

You can generate the `eslint.output.json` file with this example command:

```
eslint -f json -o eslint.output.json
```
**Options**:

`CODEMONITOR_ESLINT_THRESHOLD`: Don't emit metrics about eslint rules that are above of this threshold. (Default: `10`)


## Npm

Collect multiple metrics from the a NodeJS.

**Requirements / Setup**:

You need a `package.json` file present in the current folder.

## Packwerk

Collect multiple metrics from the a Ruby project with [Packwerk](https://github.com/Shopify/packwerk) configured.

**Requirements / Setup**:

You need a `deprecated_references.yml` files present in the current project.

## Rubocop

Collect multiple metrics from the a Ruby project with [Rubocop](https://github.com/rubocop/rubocop) configured.

**Requirements / Setup**:

You need a `.rubocop.yml` and a `rubocop.output.json` file present in the current folder.

You can generate the `rubocop.output.json` file with this example command:

```
bundle exec srb tc --metrics-prefix 'codemetrics' --metrics-file sorbet.output.json
```

**Options**:

`CODEMONITOR_RUBOCOP_THRESHOLD`: Don't emit metrics about rubocop cops that are above of this threshold. (Default: `50`)


## Semgrep

Collect multiple metrics from the a with [Semgrep](https://semgrep.dev/) configured.

**Requirements / Setup**:

You need a `.semgrep.yml` and a `semgrep.output.json` file present in the current folder.

You can generate the `semgrep.output.json` file with this example command:

```
semgrep --json -o semgrep.output.json
```

**Options**:

`CODEMONITOR_SEMGREP_THRESHOLD`: Don't emit metrics about rubocop cops that are above of this threshold. (Default: `50`)

## Knip

Collect multiple metrics from [Knip](https://knip.dev/)

**Requirements / Setup**:

You need a `knip.output.json` file present in the current folder.

You can generate the `knip.output.json` file with this example command:

```
knip --reporter json > knip.output.json
```

## Sorbet

Collect multiple metrics from [Sorbet](https://sorbet.org/) configured.

**Requirements / Setup**:

You need a `sorbet.output.json` file present in the current folder.

You can generate the `sorbet.output.json` file with this example command:

```
bundle exec srb tc --metrics-prefix 'codemetrics' --metrics-file sorbet.output.json
```

## SCC

Collect multiple metrics from [SCC](https://github.com/boyter/scc) configured.

**Requirements / Setup**:

You need a `scc.output.json` file present in the current folder.

You can generate the `scc.output.json` file with this example command:

```
scc -f json scc.output.json
```

# Providers

## Console

TODO

## Datadog

TODO

# Contribute

This project started as a side project, so I'm sure that is full
of mistakes and areas to be improve. If you think you can tweak the code to
make it better, I'll really appreciate a pull request. ;)
