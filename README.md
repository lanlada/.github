# .github

GitHub-native defaults for the **lanlada** organization: the organization profile, the default issue and pull request templates, and the reusable workflows shared across the organization's repositories.

## Reusable workflows

Consumer repositories invoke these through a thin caller workflow with `uses: lanlada/.github/.github/workflows/<name>@main`.

- `reusable-pr-validate.yml` — pull request title, pairing, and reference checks.
- `reusable-issue-validate.yml` — issue title convention checks.
- `reusable-sca.yml` — software composition analysis.
- `reusable-security-audit.yml` — dependency security audit.
- `reusable-secret-scan.yml` — gitleaks secret scanning. Input `mode`: `pr` scans the pull-request commit range; `full` scans complete git history. Fails the check on any finding and uploads a redacted JSON report artifact.
- `reusable-stale.yml` — stale issue and pull request management.

Visit the organization at https://github.com/lanlada.
