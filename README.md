# 🖥️ CodeMonitor

**CodeMonitor** is a powerful Ruby gem that collects code quality metrics, dependency information, test coverage, and other important statistics from your repository. It aggregates data from multiple analysis tools (linters, type checkers, test frameworks, etc.) and sends them to time series databases or monitoring providers like Datadog for tracking trends over time.

## 📊 What Does It Do?

CodeMonitor acts as a centralized metrics collection hub for your codebase. It:

- **Collects metrics** from various development tools and analysis extractors
- **Aggregates data** from linters (ESLint, Rubocop, Semgrep), type checkers (Sorbet), test coverage tools (Jest, SimpleCov), dependency analyzers (npm, Knip, Packwerk), and more
- **Normalizes metrics** into a consistent format
- **Pushes data** to monitoring providers (Datadog, Console output)
- **Tracks trends** over time to help you monitor code quality, technical debt, and project health

## 🚀 Installation

Add this line to your application's Gemfile:

```ruby
gem 'codemonitor'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install codemonitor
```

## 💻 Usage

### Basic Usage

Run CodeMonitor in your project directory:

```bash
codemonitor
```

By default, it will:
1. Auto-detect which extractors are available (based on configuration files)
2. Collect metrics from all detected extractors
3. Output results to the console

### Configuration

Configure CodeMonitor using environment variables:

- **`CODEMONITOR_PROVIDER`**: Choose where to send metrics (`console` or `datadog`). Default: `console`
- **`CODEMONITOR_EXTRACTORS`**: Comma-separated list of specific extractors to run (e.g., `git,eslint,npm`). If not set, all available extractors run.

Example:

```bash
# Send metrics to Datadog
CODEMONITOR_PROVIDER=datadog DATADOG_API_KEY=your_key codemonitor

# Run only specific extractors
CODEMONITOR_EXTRACTORS=git,npm,eslint codemonitor
```

# Extractors

Extractors are the data collectors that extract metrics from various tools and sources. Each extractor automatically activates when its requirements are met.

## Git

Collects repository statistics including commits, branches, tags, contributors, and file metrics.

**Requirements**:

- A `.git` folder in the current directory

**Options**:

- `CODEMONITOR_GIT_FILES_THRESHOLD`: Filter out file extension metrics below this count (Default: `0`)

**Metrics**:

| Metric | Description |
|--------|-------------|
| `git_number_of_commits` | Total number of commits in the repository |
| `git_number_of_branches` | Total number of branches |
| `git_number_of_tags` | Total number of tags |
| `git_number_of_contributors` | Total number of unique contributors |
| `git_number_of_files` | Total number of tracked files |
| `git_number_of_ignores_files` | Number of ignored files |
| `git_number_of_lines` | Total lines of code across all files |
| `git_file_extensions_*` | File count per extension (e.g., `git_file_extensions_rb`, `git_file_extensions_js`) |

## ESLint

Collects JavaScript/TypeScript linting metrics including violations by severity and rule.

**Requirements**:

- `eslint.output.json` file in the current directory

Generate the required file:

```bash
eslint -f json -o eslint.output.json
```

**Options**:

- `CODEMONITOR_ESLINT_THRESHOLD`: Only report rules with violations >= this threshold (Default: `10`)

**Metrics**:

| Metric | Description |
|--------|-------------|
| `eslint_number_of_offended_files` | Number of files with ESLint violations |
| `eslint_number_of_offenses` | Total number of ESLint violations |
| `eslint_number_of_correctable` | Number of auto-fixable violations |
| `eslint_severity_warning` | Number of warnings |
| `eslint_severity_error` | Number of errors |
| `eslint_rule_*` | Violation count per rule (e.g., `eslint_rule_no_console`) |


## npm

Collects Node.js dependency information including counts, computed dependencies, and vulnerability data from npm audit.

**Requirements**:

- `package.json` file in the current directory
- `package-lock.json` file in the current directory

**Metrics**:

| Metric | Description |
|--------|-------------|
| `npm_number_of_prod_dependencies` | Number of production dependencies |
| `npm_number_of_dev_dependencies` | Number of development dependencies |
| `npm_number_of_scripts` | Number of npm scripts defined |
| `npm_number_of_computed_prod_dependencies` | Total production dependencies (including transitive) |
| `npm_number_of_computed_dev_dependencies` | Total dev dependencies (including transitive) |
| `npm_number_of_computed_optional_dependencies` | Total optional dependencies |
| `npm_number_of_computed_peer_dependencies` | Total peer dependencies |
| `npm_number_of_computed_peer_optional_dependencies` | Total optional peer dependencies |
| `npm_number_of_computed_total_dependencies` | Grand total of all dependencies |
| `npm_number_of_vulnerable_dependencies_info` | Vulnerabilities: info severity |
| `npm_number_of_vulnerable_dependencies_low` | Vulnerabilities: low severity |
| `npm_number_of_vulnerable_dependencies_moderate` | Vulnerabilities: moderate severity |
| `npm_number_of_vulnerable_dependencies_high` | Vulnerabilities: high severity |
| `npm_number_of_vulnerable_dependencies_critical` | Vulnerabilities: critical severity |
| `npm_number_of_vulnerable_dependencies_total` | Total number of vulnerabilities |

## Packwerk

Collects metrics from Shopify's [Packwerk](https://github.com/Shopify/packwerk) package system for Ruby, tracking dependency and privacy violations.

**Requirements**:

- `package_todo.yml` files present in the project (in any subdirectory)

**Metrics**:

| Metric | Description |
|--------|-------------|
| `packwerk_number_of_dependency_violations` | Number of package dependency violations |
| `packwerk_number_of_privacy_violations` | Number of package privacy violations |

## Rubocop

Collects Ruby linting metrics from [Rubocop](https://github.com/rubocop/rubocop), including violations by severity and cop.

**Requirements**:

- `rubocop.output.json` file in the current directory

Generate the required file:

```bash
bundle exec rubocop -f json -o rubocop.output.json
```

**Options**:

- `CODEMONITOR_RUBOCOP_THRESHOLD`: Only report cops with violations >= this threshold (Default: `50`)

**Metrics**:

| Metric | Description |
|--------|-------------|
| `rubocop_number_of_offenses` | Total number of Rubocop violations |
| `rubocop_number_of_correctable` | Number of auto-correctable violations |
| `rubocop_severity_*` | Violations by severity (e.g., `rubocop_severity_warning`) |
| `rubocop_cop_*` | Violations per cop (e.g., `rubocop_cop_style_frozen_string_literal_comment`) |


## Semgrep

Collects security and code quality findings from [Semgrep](https://semgrep.dev/).

**Requirements**:

- `semgrep.output.json` file in the current directory

Generate the required file:

```bash
semgrep --json -o semgrep.output.json
```

**Options**:

- `CODEMONITOR_SEMGREP_THRESHOLD`: Only report check IDs with findings >= this threshold (Default: `50`)

**Metrics**:

| Metric | Description |
|--------|-------------|
| `semgrep_number_of_offenses` | Total number of Semgrep findings |
| `semgrep_number_of_errors` | Number of Semgrep errors during analysis |
| `semgrep_check_*` | Findings per check ID |

## Knip

Collects unused code metrics from [Knip](https://knip.dev/), identifying unused dependencies, exports, and types.

**Requirements**:

- `knip.output.json` file in the current directory

Generate the required file:

```bash
knip --reporter json > knip.output.json
```

**Metrics**:

| Metric | Description |
|--------|-------------|
| `knip_number_of_dependecies` | Unused dependencies |
| `knip_number_of_devDependencies` | Unused dev dependencies |
| `knip_number_of_optionalPeerDependencies` | Unused optional peer dependencies |
| `knip_number_of_unlisted` | Unlisted dependencies |
| `knip_number_of_binaries` | Unused binaries |
| `knip_number_of_unresolved` | Unresolved imports |
| `knip_number_of_exports` | Unused exports |
| `knip_number_of_types` | Unused types |
| `knip_number_of_enumMembers` | Unused enum members |
| `knip_number_of_duplicates` | Duplicate exports |

## Sorbet

Collects type coverage metrics from [Sorbet](https://sorbet.org/), Stripe's type checker for Ruby.

**Requirements**:

- `sorbet.output.json` file in the current directory

Generate the required file:

```bash
bundle exec srb tc --metrics-prefix 'codemetrics' --metrics-file sorbet.output.json
```

**Metrics**:

| Metric | Description |
|--------|-------------|
| `sorbet_number_of_sig_count` | Number of type signatures |
| `sorbet_number_of_input_classes_total` | Total number of classes |
| `sorbet_number_of_input_sends_total` | Total number of method calls |
| `sorbet_number_of_input_files` | Number of Ruby files analyzed |
| `sorbet_number_of_input_methods_total` | Total number of methods |
| `sorbet_number_of_input_modules_total` | Total number of modules |
| `sorbet_number_of_sigil_true` | Files with `typed: true` |
| `sorbet_number_of_sigil_false` | Files with `typed: false` |
| `sorbet_number_of_sigil_autogenerated` | Files with `typed: autogenerated` |
| `sorbet_number_of_sigil_strong` | Files with `typed: strong` |
| `sorbet_number_of_sigil_strict` | Files with `typed: strict` |
| `sorbet_number_of_sigil_ignore` | Files with `typed: ignore` |

## SCC (Sloc Cloc and Code)

Collects code statistics from [SCC](https://github.com/boyter/scc), including lines of code, complexity, and language breakdowns.

**Requirements**:

- `scc.output.json` file in the current directory

Generate the required file:

```bash
scc -f json > scc.output.json
```

**Metrics**:

| Metric | Description |
|--------|-------------|
| `scc_total_bytes` | Total bytes across all files |
| `scc_total_lines` | Total lines across all files |
| `scc_total_code` | Total lines of code |
| `scc_total_comment` | Total comment lines |
| `scc_total_blank` | Total blank lines |
| `scc_total_complexity` | Total cyclomatic complexity |
| `scc_total_count` | Total number of files |
| `scc_total_weightedcomplexity` | Weighted complexity score |
| `scc_type_*_*` | Per-language metrics (e.g., `scc_type_ruby_code`, `scc_type_javascript_lines`) |

## Jest

Collects JavaScript/TypeScript test coverage metrics from Jest's JSON summary reporter.

**Requirements**:

- `jest_json_summary.output.json` file in the current directory

Configure Jest to generate this file using the `json-summary` reporter in your `jest.config.js`.

**Metrics**:

| Metric | Description |
|--------|-------------|
| `jest_json_summary_lines_total` | Total lines in test coverage |
| `jest_json_summary_lines_covered` | Covered lines |
| `jest_json_summary_lines_skipped` | Skipped lines |
| `jest_json_summary_lines_pct` | Line coverage percentage |
| `jest_json_summary_statements_*` | Statement coverage metrics |
| `jest_json_summary_functions_*` | Function coverage metrics |
| `jest_json_summary_branches_*` | Branch coverage metrics |

## SimpleCov

Collects Ruby test coverage metrics from [SimpleCov](https://github.com/simplecov-ruby/simplecov).

**Requirements**:

- `simplecov_json_coverage.output.json` file in the current directory

Configure SimpleCov to use the JSON formatter in your test setup.

**Metrics**:

| Metric | Description |
|--------|-------------|
| `simplecov_json_coverage_metrics_covered_percent` | Code coverage percentage |
| `simplecov_json_coverage_metrics_covered_strength` | Coverage strength score |
| `simplecov_json_coverage_metrics_covered_lines` | Number of covered lines |
| `simplecov_json_coverage_metrics_total_lines` | Total number of lines |

## GitHub

Collects pull request metrics directly from GitHub, including open PRs and lead time.

**Requirements**:

- `GITHUB_TOKEN` environment variable with a GitHub personal access token
- `GITHUB_REPOSITORY` environment variable (format: `owner/repo`)

**Options**:

- `GITHUB_SINCE_DAYS`: Number of days to look back for lead time calculation (Default: `30`)

Example:

```bash
GITHUB_TOKEN=ghp_xxx GITHUB_REPOSITORY=owner/repo codemonitor
```

**Metrics**:

| Metric | Description |
|--------|-------------|
| `github_number_of_open_pull_requests` | Number of open pull requests |
| `github_number_of_lead_time_in_days` | Average lead time for merged PRs (in days) |

# Providers

Providers determine where the collected metrics are sent. CodeMonitor supports multiple output destinations.

## Console

Outputs all metrics to standard output in a simple text format.

**Usage**:

```bash
codemonitor  # Console is the default provider
# OR
CODEMONITOR_PROVIDER=console codemonitor
```

**Output Format**:

The console provider prints metrics in the format `metric_name: value`. If metrics include tags (using the `#` delimiter), they are displayed as-is:

```
requests: 100
errors: 5  
requests#production: 200
latency#backend,region:us-east-1,env:prod: 150
```

## Datadog

Sends metrics to [Datadog](https://www.datadoghq.com/) using the Datadog API for monitoring and visualization over time.

**Usage**:

```bash
CODEMONITOR_PROVIDER=datadog DATADOG_API_KEY=your_api_key codemonitor
```

**Environment Variables**:

- `DATADOG_API_KEY` (required): Your Datadog API key
- `DATADOG_PREFIX` (optional): Prefix added to all metric names (default: `'codemonitor.'`)

**Metric Tagging**:

The Datadog provider supports adding tags to metrics for better organization and filtering. Include tags in the metric name using the `#` delimiter:

- **Format**: `metric_name#tag1,tag2:value,tag3`
- **Example**: `requests#frontend,app:webserver` → sends metric `requests` with tags `['frontend', 'app:webserver']`
- Tags follow Datadog's standard format: simple tags (`tag`) or key-value pairs (`key:value`)

More about Datadog tagging: [Datadog Tagging Documentation](https://docs.datadoghq.com/getting_started/tagging/)

## 🔧 Advanced Usage

### Running Specific Extractors

To run only specific extractors, use the `CODEMONITOR_EXTRACTORS` environment variable:

```bash
# Run only Git and ESLint extractors
CODEMONITOR_EXTRACTORS=git,eslint codemonitor

# Run npm and Rubocop with Datadog output
CODEMONITOR_PROVIDER=datadog DATADOG_API_KEY=xxx CODEMONITOR_EXTRACTORS=npm,rubocop codemonitor
```

### CI/CD Integration

CodeMonitor is designed to run in CI/CD pipelines. Here's an example GitHub Actions workflow:

```yaml
name: Code Metrics
on: [push]

jobs:
  metrics:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      # Generate output files for various tools
      - name: Run ESLint
        run: eslint -f json -o eslint.output.json || true
      
      - name: Run Rubocop
        run: bundle exec rubocop -f json -o rubocop.output.json || true
      
      # Collect and send metrics
      - name: Run CodeMonitor
        env:
          CODEMONITOR_PROVIDER: datadog
          DATADOG_API_KEY: ${{ secrets.DATADOG_API_KEY }}
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GITHUB_REPOSITORY: ${{ github.repository }}
        run: codemonitor
```

### Best Practices

1. **Generate tool outputs before running CodeMonitor**: Most extractors require JSON output files from their respective tools
2. **Use thresholds wisely**: Adjust threshold values to focus on significant metrics and reduce noise
3. **Track trends over time**: Send metrics to Datadog or similar to visualize trends and set up alerts
4. **Run in CI/CD**: Automate metric collection on every commit or pull request
5. **Combine multiple extractors**: Use Git + linters + test coverage for a comprehensive health overview

## 🤝 Contribute

This project started as a side project, so there's always room for improvement! If you have ideas for new extractors, better metrics, or code improvements, pull requests are very welcome. 😊

## 📝 License

This project is available under the MIT License. See the LICENSE file for details.
