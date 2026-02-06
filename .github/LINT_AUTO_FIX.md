# Automatic Lint Fixing with Claude

The lint workflows have been enhanced with **automatic fixing capability** using Claude Sonnet.

## 🚀 How It Works

```
Code pushed/PR created
  ↓
Lint workflow runs
  ↓
Lint issues detected
  ↓
Claude Sonnet analyzes errors
  ↓
Applies automatic fixes
  ↓
Commits: "Fix golangci-lint issues"
  ↓
Pushes to branch
  ↓
Re-runs lint
  ↓
✅ All checks pass
```

## ✨ Features

- ✅ **Integrated** - Built into existing lint workflows
- ✅ **Automatic** - No manual intervention needed
- ✅ **Fast** - Uses Sonnet for quick fixes
- ✅ **Cheap** - ~$0.10-0.20 per fix
- ✅ **Safe** - Only fixes formatting/style issues
- ✅ **Verified** - Re-runs lint after fixing

## 📊 What Gets Fixed

### ✅ Auto-Fixed (Go)
- **Formatting**: `gofmt` issues
- **Imports**: `goimports` organization
- **Simple lints**: unused variables, ineffassign
- **Code style**: naming conventions
- **Whitespace**: trailing spaces, empty lines

### ⚠️ Not Auto-Fixed
- Logic errors
- Complex refactoring
- Security issues
- Performance problems

## 📈 Impact

### Time Savings
- **Per fix**: ~5 minutes saved
- **Monthly** (10 fixes): 50 minutes saved
- **Monthly** (50 fixes): 4+ hours saved

### Cost
- **Per fix**: $0.10-0.20
- **Monthly** (10 fixes): $1.50
- **Monthly** (50 fixes): $7.50

**ROI**: Saves hours of developer time for dollars! 🎉

## 🎯 Deployment Status

| Repository Group | Enhanced | Status |
|-----------------|----------|--------|
| **antinvestor Go repos** | 13 | ✅ Live |
| **antinvestor (ant.build)** | 1 | 📋 [PR #43](https://github.com/antinvestor/builder/pull/43) |
| **pitabwire Go repos** | 4 | ✅ Live |
| **Non-Go repos** | - | N/A |
| **TOTAL** | **18/23** | ✅ Active |

## 📝 Enhanced Workflow

The `golangci-lint.yml` workflow now includes:

```yaml
Steps:
1. Run golangci-lint (with continue-on-error)
2. If failed → Trigger Claude to fix
3. Claude applies fixes (gofmt, goimports, etc.)
4. Commit and push fixes
5. Re-run lint to verify
6. Comment on PR if applicable
```

## 💡 Example

### Before Auto-Fix
```
Developer pushes code
  ↓
Lint fails: "File not formatted"
  ↓
Developer manually runs gofmt
  ↓
Developer commits fix
  ↓
Developer pushes
  ↓
CI re-runs
  ↓
Time: ~5 minutes
```

### After Auto-Fix
```
Developer pushes code
  ↓
Lint fails: "File not formatted"
  ↓
Claude auto-fixes with gofmt
  ↓
Claude commits and pushes
  ↓
CI re-runs and passes
  ↓
Time: ~30 seconds (automatic)
```

## 🔧 Configuration

### Current Settings

| Setting | Value |
|---------|-------|
| **Model** | Claude Sonnet 4.5 |
| **Max Turns** | 30 |
| **Timeout** | 10 minutes |
| **Tools** | git, go, gofmt, goimports, golangci-lint |

### Permissions Required

```yaml
permissions:
  contents: write        # To commit fixes
  pull-requests: write   # To comment on PRs
  checks: write         # To update check status
```

## 🎓 Best Practices

1. **Trust the automation** - Let it fix simple issues
2. **Review commits** - Check what was auto-fixed
3. **Don't disable checks** - Keep lint strict
4. **Update lint tools** - Keep golangci-lint current
5. **Monitor costs** - Track in Actions tab

## 🔍 Monitoring

### View Auto-Fix Activity

```bash
# List auto-fix commits
git log --author="claude-lint-fixer" --oneline

# View specific commit
git show <commit-hash>

# Check workflow runs
gh run list --workflow=golangci-lint.yml --limit 10
```

### Check Costs

In Actions tab:
- View workflow run duration
- Count auto-fix runs
- Estimate: runs × $0.15 average

## 🚨 Troubleshooting

### Fixes not being applied

**Check**:
1. `CLAUDE_CODE_OAUTH_TOKEN` is configured
2. Branch is not protected (or bot is exempt)
3. Workflow has `contents: write` permission

### Lint still failing after fix

**Possible reasons**:
- Issue requires manual review (expected)
- Complex logic error (not auto-fixable)
- Breaking change needed

**Action**: Review Claude's output in workflow logs

### Too many auto-fix runs

**Optimization**:
- Improve local pre-commit hooks
- Update lint tools to latest version
- Review team's code style practices

## 🔗 Related Workflows

### Works With

- **Claude Continuous** - Issues → PRs → Auto-fixed lint
- **Dependabot** - Dependency updates → Auto-fixed lint
- **Claude Code Review** - Reviews after auto-fix

### Complete Flow Example

```
1. Create issue with 'claude' label
2. Claude Continuous implements feature
3. Creates PR
4. Lint runs and detects issues
5. Auto-fix applies corrections
6. Claude Code Review reviews
7. Dependabot updates dependencies
8. Auto-merge merges PR
9. Complete automation!
```

## 📊 Total Automation Stack

With lint auto-fix, you now have:

| System | Status | Function |
|--------|--------|----------|
| Claude Interactive | ✅ | Manual AI assistance |
| Claude Code Review | ✅ | Automated PR reviews |
| Claude Continuous | ✅ | Issue → PR automation |
| Dependabot Auto-Merge | ✅ | Dependency automation |
| **Lint Auto-Fix** | ✅ | **Formatting automation** |

**Result**: Near-zero manual intervention development! 🚀

## 🎊 Summary

Lint auto-fix completes the automation stack:

✅ Automatically fixes formatting and style issues
✅ Uses Sonnet for fast, cheap fixes (~$0.10-0.20)
✅ Integrated into existing lint workflows
✅ Saves ~5 minutes per lint failure
✅ No manual intervention required
✅ Safe - only fixes simple issues

**Status**: 🟢 **LIVE** in 18 repositories

**Next**: Merge [PR #43](https://github.com/antinvestor/builder/pull/43) for complete coverage!
