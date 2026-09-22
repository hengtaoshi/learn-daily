# export.ps1 — 把 Markdown 导出成小字号 PDF（Chrome 无头模式）
# 用法（项目根目录执行）：
#   pwsh pdf\export.ps1 "面试题库\第 2 课 · 装工具 + Docker · 面试题库.md"
# 说明：默认单栏，只靠缩小字号省页；不用双栏。
#   pwsh pdf\export.ps1 "学习日志.md"            # 单栏（默认，推荐）
# 预设：pdf\print-9pt.css = 9pt（默认）｜pdf\print-8pt.css = 8pt 更小｜pdf\print.css = 9pt 宽松行距
param(
  [Parameter(Mandatory = $true)][string]$Md,
  [int]$Cols = 1,
  [string]$Preset = "pdf\print-9pt.css"
)
$ErrorActionPreference = "Stop"
$root = (Get-Location).Path
$name = [System.IO.Path]::GetFileNameWithoutExtension($Md)
$html = Join-Path $root "pdf\$name.html"
$outPdf = Join-Path $root "pdf\$name.pdf"
$chrome = @(
  "C:\Program Files\Google\Chrome\Application\chrome.exe",
  "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $chrome) { throw "找不到 Chrome 或 Edge" }
node "pdf\md2html.mjs" $Md $html "--cols=$Cols" "--css=$Preset"
$uri = "file:///" + ($html -replace '\\', '/')
& $chrome --headless=new --disable-gpu --no-pdf-header-footer --virtual-time-budget=3000 --print-to-pdf="$outPdf" "$uri" 2>$null | Out-Null
Remove-Item $html -ErrorAction SilentlyContinue
Write-Host "已生成: $outPdf"
