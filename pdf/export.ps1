# export.ps1 — 把单个 Markdown 导出成小字号 PDF（Chrome 无头模式）
# 用法（项目根目录）：  & .\pdf\export.ps1 "面试题库\第 3 课 · … · 面试题库.md"
# 预设： pdf\print-9pt.css（默认，单栏）｜ print-8pt.css 更小｜ print.css 9pt 宽松行距
# 注意： 必须带 --user-data-dir 独立配置目录，否则开着 Chrome 时无头实例会静默退出、不产出 PDF。
param(
  [Parameter(Mandatory = $true)][string]$Md,
  [int]$Cols = 1,
  [string]$Preset = "pdf\print-9pt.css",
  [string]$Out = ""
)
$ErrorActionPreference = "Continue"
$root = (Get-Location).Path
$name = [System.IO.Path]::GetFileNameWithoutExtension($Md)
$html = Join-Path $root "pdf\_tmp.html"
if ($Out -eq "") { $Out = Join-Path $root ("pdf\" + $name + ".pdf") }
$chrome = @(
  "C:\Program Files\Google\Chrome\Application\chrome.exe",
  "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $chrome) { throw "no chrome/edge found" }
$udd = Join-Path $env:TEMP "chrome-pdf-profile"
New-Item -ItemType Directory -Force -Path $udd | Out-Null
node "pdf\md2html.mjs" $Md $html "--cols=$Cols" "--css=$Preset"
$uri = "file:///" + ($html -replace "\\", "/")
& $chrome --headless=new --disable-gpu --no-sandbox --user-data-dir="$udd" --no-first-run --no-default-browser-check --no-pdf-header-footer --virtual-time-budget=10000 --print-to-pdf="$Out" "$uri" *> $null
Start-Sleep -Milliseconds 500
Remove-Item $html -ErrorAction SilentlyContinue
if (Test-Path $Out) { Write-Host ("已生成: " + $Out + "  " + [math]::Round((Get-Item $Out).Length/1KB) + " KB") } else { Write-Host ("失败: " + $Out) }