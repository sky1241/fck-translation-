# Security Cleanup Script
# Run this to remove APK files from git and prepare for new key

param(
    [string]$NewApiKey = "",
    [switch]$SkipKeyRotation,
    [switch]$DryRun
)

Write-Host "🔒 GitGuardian Alert - Security Cleanup" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

# Check if in git repository
$gitCheck = git rev-parse --is-inside-work-tree 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Not a git repository. Please run from repository root." -ForegroundColor Red
    Write-Host "   Current directory: $PWD" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Git repository detected`n" -ForegroundColor Green

# Step 1: List APK files that will be removed
Write-Host "📦 Step 1: Finding APK files in git..." -ForegroundColor Yellow
$apkFiles = git ls-files "*.apk"

if ($apkFiles) {
    Write-Host "Found $($apkFiles.Count) APK file(s) in git:" -ForegroundColor Yellow
    $apkFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor White }
    Write-Host ""
    
    if (-not $DryRun) {
        $confirm = Read-Host "Remove these files from git tracking? (y/N)"
        if ($confirm -eq 'y' -or $confirm -eq 'Y') {
            Write-Host "Removing APK files from git..." -ForegroundColor Cyan
            $apkFiles | ForEach-Object {
                git rm --cached $_ 2>$null
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "  ✅ Removed: $_" -ForegroundColor Green
                }
            }
        } else {
            Write-Host "❌ Cancelled by user" -ForegroundColor Red
            exit 0
        }
    }
} else {
    Write-Host "✅ No APK files found in git tracking" -ForegroundColor Green
}

# Step 2: Check .gitignore
Write-Host "`n📝 Step 2: Checking .gitignore..." -ForegroundColor Yellow
$gitignorePath = ".gitignore"

if (Test-Path $gitignorePath) {
    $gitignoreContent = Get-Content $gitignorePath -Raw
    
    if ($gitignoreContent -match '\*\.apk') {
        Write-Host "✅ .gitignore already excludes APK files" -ForegroundColor Green
    } else {
        Write-Host "⚠️  .gitignore does not exclude APK files" -ForegroundColor Yellow
        if (-not $DryRun) {
            $addIgnore = Read-Host "Add APK exclusion to .gitignore? (Y/n)"
            if ($addIgnore -ne 'n' -and $addIgnore -ne 'N') {
                Add-Content $gitignorePath "`n# APK files`n*.apk`ndist/*.apk`n"
                Write-Host "  ✅ Added APK exclusion to .gitignore" -ForegroundColor Green
            }
        }
    }
} else {
    Write-Host "⚠️  .gitignore not found" -ForegroundColor Yellow
}

# Step 3: API Key Rotation
Write-Host "`n🔑 Step 3: API Key Rotation..." -ForegroundColor Yellow

if ($SkipKeyRotation) {
    Write-Host "⏭️  Skipped (--SkipKeyRotation flag)" -ForegroundColor Gray
} else {
    Write-Host "Current API key in environment: " -NoNewline
    if ($env:OPENAI_API_KEY) {
        $maskedKey = $env:OPENAI_API_KEY.Substring(0, 12) + "..." + $env:OPENAI_API_KEY.Substring($env:OPENAI_API_KEY.Length - 4)
        Write-Host $maskedKey -ForegroundColor Yellow
    } else {
        Write-Host "(not set)" -ForegroundColor Gray
    }
    
    if (-not $DryRun) {
        Write-Host "`n⚠️  IMPORTANT: You must rotate your API key manually:" -ForegroundColor Red
        Write-Host "  1. Go to: https://platform.openai.com/api-keys" -ForegroundColor White
        Write-Host "  2. Revoke the current key" -ForegroundColor White
        Write-Host "  3. Generate a new key" -ForegroundColor White
        Write-Host "  4. Update `$env:OPENAI_API_KEY`n" -ForegroundColor White
        
        $openBrowser = Read-Host "Open OpenAI dashboard now? (Y/n)"
        if ($openBrowser -ne 'n' -and $openBrowser -ne 'N') {
            Start-Process "https://platform.openai.com/api-keys"
        }
        
        if ($NewApiKey) {
            $env:OPENAI_API_KEY = $NewApiKey
            Write-Host "  ✅ Updated `$env:OPENAI_API_KEY (session only)" -ForegroundColor Green
            Write-Host "  ⚠️  Add to your PowerShell profile for persistence" -ForegroundColor Yellow
        } else {
            Write-Host "`n  To set the new key, run:" -ForegroundColor Cyan
            Write-Host '  $env:OPENAI_API_KEY = "sk-proj-YOUR_NEW_KEY"' -ForegroundColor White
        }
    }
}

# Step 4: Commit changes
Write-Host "`n💾 Step 4: Commit changes..." -ForegroundColor Yellow

if ($DryRun) {
    Write-Host "⏭️  Dry run mode - no changes committed" -ForegroundColor Gray
} else {
    $hasChanges = git status --porcelain
    if ($hasChanges) {
        Write-Host "Changes to commit:" -ForegroundColor Yellow
        git status --short
        Write-Host ""
        
        $commitConfirm = Read-Host "Commit these changes? (Y/n)"
        if ($commitConfirm -ne 'n' -and $commitConfirm -ne 'N') {
            git add .gitignore
            git commit -m "security: Remove APK files and update .gitignore

- Remove APK files from git tracking
- Add *.apk to .gitignore to prevent future commits
- Response to GitGuardian alert: Base64 Generic High Entropy Secret
- APK files should be distributed via GitHub Releases instead"
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "  ✅ Changes committed" -ForegroundColor Green
                
                $pushConfirm = Read-Host "`nPush to remote? (Y/n)"
                if ($pushConfirm -ne 'n' -and $pushConfirm -ne 'N') {
                    $branch = git rev-parse --abbrev-ref HEAD
                    git push origin $branch
                    
                    if ($LASTEXITCODE -eq 0) {
                        Write-Host "  ✅ Pushed to origin/$branch" -ForegroundColor Green
                    } else {
                        Write-Host "  ❌ Push failed" -ForegroundColor Red
                    }
                }
            } else {
                Write-Host "  ❌ Commit failed" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "✅ No changes to commit" -ForegroundColor Green
    }
}

# Summary
Write-Host "`n📊 Summary" -ForegroundColor Cyan
Write-Host "=========================================`n" -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "🔍 Dry run completed - no changes made" -ForegroundColor Yellow
} else {
    Write-Host "✅ Cleanup completed" -ForegroundColor Green
}

Write-Host "`n📋 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. ✅ Remove APK files from git" -ForegroundColor $(if ($apkFiles -and -not $DryRun) { "Green" } else { "Gray" })
Write-Host "  2. ✅ Update .gitignore" -ForegroundColor Green
Write-Host "  3. ⚠️  Rotate API key (manual)" -ForegroundColor Yellow
Write-Host "  4. 🔨 Rebuild APK with new key" -ForegroundColor Yellow
Write-Host "  5. 📦 Distribute via GitHub Releases" -ForegroundColor Yellow

Write-Host "`n🔗 Useful Links:" -ForegroundColor Cyan
Write-Host "  - OpenAI Keys: https://platform.openai.com/api-keys" -ForegroundColor White
Write-Host "  - GitHub Releases: https://github.com/sky1241/fck-translation-/releases" -ForegroundColor White
Write-Host "  - Documentation: .\SECURITY_RESPONSE.md" -ForegroundColor White

Write-Host "`n✅ Done!" -ForegroundColor Green

