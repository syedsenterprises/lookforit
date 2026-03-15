param(
  [switch]$RebuildCatalogIndex,
  [switch]$BuildCuratedBatch,
  [int]$CuratedTargetCount = 200,
  [string]$CuratedOutputFile = 'tools/catalog/catalog-data.curated-200.csv'
)

$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

$hasFailures = $false

function Invoke-Step {
  param(
    [string]$Name,
    [scriptblock]$Action
  )

  Write-Host "===== STEP: $Name =====" -ForegroundColor Cyan
  try {
    & $Action
    Write-Host "STEP_OK: $Name" -ForegroundColor Green
  }
  catch {
    Write-Host "STEP_FAILED: $Name" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    $script:hasFailures = $true
  }
  Write-Host ""
}

if ($BuildCuratedBatch) {
  Invoke-Step -Name 'Build Curated Import Batch' -Action {
    ./build-curated-import-batch.ps1 -OutputFile $CuratedOutputFile -TargetCount $CuratedTargetCount
  }
}

if ($RebuildCatalogIndex) {
  Invoke-Step -Name 'Rebuild Catalog Index' -Action {
    ./upgrade-catalog-quality.ps1 -RebuildIndexOnly
  }
}

Invoke-Step -Name 'Generate Sitemap' -Action {
  ./generate-sitemap.ps1
}

Invoke-Step -Name 'Run Site Quality Gate' -Action {
  ./qa-site.ps1
}

Invoke-Step -Name 'Run Hardening Audit' -Action {
  ./_final_hardening_audit.ps1
}

if ($hasFailures) {
  Write-Host 'FULL_AUDIT_STATUS=FAILED' -ForegroundColor Red
  exit 1
}

Write-Host 'FULL_AUDIT_STATUS=OK' -ForegroundColor Green
exit 0
