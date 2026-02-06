# Claude GitHub Actions Workflows

This repository uses two Claude-powered workflows for AI-assisted development.

## Workflows

### 1. `claude.yml` - Interactive Development Assistant

**Purpose**: Human-in-the-loop AI assistant for feature development, bug fixes, and code changes.

**Triggers**:
- Label `claude` added to issue (by authorized users)
- `@claude` mentioned in issue comments, PR reviews, or PR comments
- Only activated by repository OWNERS, MEMBERS, or COLLABORATORS

**Key Features**:
- Uses Claude Opus 4.6 (most capable model)
- Max 100 conversation turns
- 30-minute timeout for cost protection
- Reads CI/CD results to help debug failures
- Automatic PR creation from issues
- Clean commit messages (no co-author attributions)

**Allowed Tools**:
- Git operations (commit, branch, merge)
- GitHub CLI (issues, PRs, API)
- Flutter/Dart commands
- npm/npx for Node.js
- File operations (read, write, edit, search)
- Web search and fetch
- Task delegation to sub-agents

**Configuration**:
```yaml
env:
  AUTHORIZED_LABEL_USERS: "mlr,pitabwire"  # Users who can use 'claude' label
  MAX_RUNTIME_MINUTES: 30                  # Timeout for cost control
```

**Required Secrets**:
- `CLAUDE_CODE_OAUTH_TOKEN` - Anthropic OAuth token
- `GH_PAT` - GitHub Personal Access Token (for comment cleanup)

---

### 2. `claude-code-review.yml` - Automated Code Reviewer

**Purpose**: Automatic code review on pull requests from contributors.

**Triggers**:
- PR opened, synchronized, or marked ready for review
- Only for contributors (skips OWNER/MEMBER PRs)
- Skips draft PRs
- Only runs on code file changes (not docs/config)

**Key Features**:
- Uses Claude Sonnet 4.5 (cost-effective for reviews)
- Max 50 conversation turns
- 15-minute timeout
- Skips very large PRs (>1000 lines) with helpful message
- Reviews with CI context
- Focuses on security, bugs, and performance

**Review Priorities**:
1. **Security vulnerabilities** - XSS, SQL injection, auth issues
2. **Critical bugs** - Null pointers, race conditions, logic errors
3. **Performance issues** - N+1 queries, memory leaks
4. **Data integrity** - Validation, error handling
5. Code quality, best practices, tests, documentation

**File Filters**:
- ✅ Includes: `.dart`, `.ts`, `.js`, `.go`, `.py`, `.java`, `.kt`, `.swift`, `.rs`, `pubspec.yaml`, `package.json`
- ❌ Excludes: `.md`, `docs/`, `.github/`, `.yml`, `.yaml`, `LICENSE`, `.gitignore`

**Configuration**:
```yaml
env:
  MAX_RUNTIME_MINUTES: 15  # Timeout for cost control
```

**Required Secrets**:
- `CLAUDE_CODE_OAUTH_TOKEN` - Anthropic OAuth token

---

## Setup Instructions

### 1. Configure Secrets

In your repository settings, add:

```
Settings → Secrets and variables → Actions → New repository secret
```

**Required secrets**:
- `CLAUDE_CODE_OAUTH_TOKEN` - Get from [Claude.ai OAuth settings](https://claude.ai/settings/oauth)
- `GH_PAT` - Create a [GitHub Personal Access Token](https://github.com/settings/tokens) with `repo` scope

### 2. Authorize Users

Edit `claude.yml` to add authorized users:

```yaml
env:
  AUTHORIZED_LABEL_USERS: "username1,username2,username3"
```

### 3. Customize Review Behavior

**Skip automated reviews for all PRs**:
```yaml
# In claude-code-review.yml, change the if condition to:
if: false  # Disables automated reviews
```

**Review all PRs (including from owners)**:
```yaml
# Remove or modify the if condition in claude-code-review.yml
if: github.event.pull_request.draft == false
```

**Adjust file filters**:
```yaml
# Add or remove file patterns in the paths section
paths:
  - "src/**/*.ts"   # Only review TypeScript in src/
  - "!test/**"      # Exclude test files
```

---

## Usage Examples

### Using `claude.yml` for Feature Development

**Option 1: Label-based trigger** (authorized users only):
1. Create an issue describing the feature
2. Add the `claude` label
3. Claude will implement, commit, and create a PR

**Option 2: @claude mention** (owners/members/collaborators):
1. Create an issue
2. Comment: `@claude please implement user authentication with JWT`
3. Claude will respond and implement the feature

**Option 3: PR assistance**:
1. Create a PR
2. Comment: `@claude the tests are failing, can you help debug?`
3. Claude will read CI logs and fix issues

### Using `claude-code-review.yml`

**Automatic review**:
1. External contributor creates a PR
2. PR is automatically reviewed within a few minutes
3. Review comments appear inline on specific lines
4. Summary appears as a PR comment

**For large PRs**:
- PRs over 1000 lines get a comment suggesting to break them up
- This prevents incomplete or low-quality reviews

---

## Cost Optimization

### Current Configuration

| Workflow | Model | Max Turns | Timeout | Estimated Cost/Run |
|----------|-------|-----------|---------|-------------------|
| claude.yml | Opus 4.6 | 100 | 30 min | $1-5 (varies by complexity) |
| claude-code-review.yml | Sonnet 4.5 | 50 | 15 min | $0.10-0.50 |

### Cost Control Measures

1. **Timeouts**: Both workflows have runtime limits
2. **Concurrency**: Prevents multiple simultaneous runs
3. **File filters**: Reviews skip non-code files
4. **PR size limits**: Skips very large PRs
5. **Author filters**: Reviews skip owner/member PRs
6. **Model selection**: Uses Sonnet (cheaper) for reviews, Opus (better) for development

### Monthly Cost Estimates

**Light usage** (5 issues + 10 PR reviews/month):
- Issues: 5 × $2 = $10
- Reviews: 10 × $0.25 = $2.50
- **Total: ~$12.50/month**

**Heavy usage** (20 issues + 50 PR reviews/month):
- Issues: 20 × $3 = $60
- Reviews: 50 × $0.30 = $15
- **Total: ~$75/month**

---

## Troubleshooting

### Claude doesn't respond to @claude mentions

**Check**:
1. Is the commenter an OWNER, MEMBER, or COLLABORATOR?
2. Is `CLAUDE_CODE_OAUTH_TOKEN` configured?
3. Check workflow run logs in Actions tab

### Automated reviews not running

**Check**:
1. Is the PR author a contributor (not owner/member)?
2. Is the PR in draft mode?
3. Did the PR change any code files (not just docs)?
4. Is the PR under 1000 lines?

### Comment cleanup step fails

**Check**:
1. Is `GH_PAT` configured?
2. Does the PAT have `repo` scope?
3. Has the PAT expired?

### Workflow exceeds timeout

**Solutions**:
1. Break task into smaller issues
2. Increase `MAX_RUNTIME_MINUTES` (costs more)
3. Reduce `--max-turns` in claude_args

---

## Security Considerations

### What Claude Can Do

✅ **Allowed**:
- Read repository files
- Read issue/PR content and comments
- Create branches and commits
- Create and update PRs
- Run git, gh, npm, flutter, dart commands
- Search the web for documentation
- Read CI/CD results

❌ **Not Allowed**:
- Modify repository settings
- Add/remove collaborators
- Create releases or tags
- Publish packages
- Access secrets (except those explicitly provided)
- Run arbitrary shell commands
- Modify workflows

### Best Practices

1. **Review before merge**: Always review Claude's PRs before merging
2. **Limit authorized users**: Only add trusted users to `AUTHORIZED_LABEL_USERS`
3. **Rotate secrets**: Regularly rotate `CLAUDE_CODE_OAUTH_TOKEN` and `GH_PAT`
4. **Monitor usage**: Check Actions tab for unexpected runs
5. **Use branch protection**: Require reviews for main branch merges

---

## Advanced Configuration

### Use different models

```yaml
# In claude.yml or claude-code-review.yml
claude_args: |
  --model "claude-sonnet-4-5"  # Cheaper, faster
  # or
  --model "claude-opus-4-6"    # More capable, expensive
  # or
  --model "claude-haiku-4-5"   # Fastest, cheapest
```

### Add custom instructions

```yaml
# In claude.yml prompt section, add:
prompt: |
  ## Project-Specific Rules
  - Always use TypeScript strict mode
  - Follow the style guide in STYLE.md
  - Add JSDoc comments for all public APIs
  - Write unit tests for new features
```

### Conditional reviews

```yaml
# Review only specific files or authors
if: |
  github.event.pull_request.draft == false &&
  (
    contains(github.event.pull_request.changed_files, 'src/') ||
    github.event.pull_request.user.login == 'external-contractor'
  )
```

---

## References

- [Claude Code Action Documentation](https://github.com/anthropics/claude-code-action)
- [Claude Code CLI Reference](https://code.claude.com/docs/en/cli-reference)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Anthropic API Documentation](https://docs.anthropic.com/)
