param(
  [Parameter(Mandatory = $true)]
  [string]$StateBucket,

  [string]$LockTable = "terraform-locks"
)

$files = Get-ChildItem -Path $PSScriptRoot\.. -Recurse -Filter versions.tf

foreach ($file in $files) {
  $content = Get-Content -LiteralPath $file.FullName -Raw
  $content = $content.Replace("REPLACE_WITH_STATE_BUCKET", $StateBucket)
  $content = $content.Replace("terraform-locks", $LockTable)
  Set-Content -LiteralPath $file.FullName -Value $content -NoNewline
}

Write-Host "Updated backend configuration in $($files.Count) versions.tf files."
