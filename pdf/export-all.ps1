# export-all.ps1 — 批量把面试题库（+学习日志）导出成 PDF
# 用法（项目根目录）：  & .\pdf\export-all.ps1
# 约定： 面试题库/第 N 课 …· 面试题库.md  ->  pdf/第N课-面试题库.pdf
#         学习日志.md                     ->  pdf/学习日志.pdf
# 预设： 单栏 + pdf/print-9pt.css（与 pdf/ 下已有 PDF 同一套参数）
#
# 三条必须遵守的坑（都踩过）：
#  1) 本文件必须存成「UTF-8 带 BOM」，否则 Windows PowerShell 按 GBK 读，中文正则变乱码、脚本直接解析失败。
#  2) 必须带 --user-data-dir 独立配置目录，否则你开着 Chrome 时无头实例会静默退出、不产出 PDF。
#  3) 用 Start-Process -Wait -RedirectStandardError 调用 Chrome：直接 & 调用时 Chrome 往 stderr 写的那句
#     DEPRECATED_ENDPOINT 警告会变成 NativeCommandError，被 Stop 策略掐断（或让 *> $null 吞掉后不产出）。

$ErrorActionPreference = "Continue"
$root = (Get-Location).Path
$chrome = @(
  "C:\Program Files\Google\Chrome\Application\chrome.exe",
  "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $chrome) { throw "no chrome/edge found" }
$udd = Join-Path $env:TEMP "chrome-pdf-profile"
New-Item -ItemType Directory -Force -Path $udd | Out-Null
$errLog = Join-Path $env:TEMP "chrome-pdf-err.log"
$outLog = Join-Path $env:TEMP "chrome-pdf-out.log"

$jobs = @()
Get-ChildItem "面试题库\*面试题库.md" | Sort-Object Name | ForEach-Object {
  $m = [regex]::Match($_.Name, "第\s*(\d+)\s*课")
  if ($m.Success) { $jobs += [pscustomobject]@{ Src = $_.FullName; Out = ("第{0}课-面试题库" -f $m.Groups[1].Value) } }
}
if (Test-Path "学习日志.md") { $jobs += [pscustomobject]@{ Src = (Resolve-Path "学习日志.md").Path; Out = "学习日志" } }

foreach ($j in $jobs) {
  $tmpMd   = Join-Path $root "pdf\_tmp.md"
  $tmpHtml = Join-Path $root "pdf\_tmp.html"
  $outPdf  = Join-Path $root ("pdf\" + $j.Out + ".pdf")
  Copy-Item $j.Src $tmpMd -Force
  node "pdf\md2html.mjs" "pdf\_tmp.md" "pdf\_tmp.html" "--cols=1" "--css=pdf\print-9pt.css" | Out-Null
  if (Test-Path $outPdf) { Remove-Item $outPdf -Force }
  $uri = "file:///" + ($tmpHtml -replace "\\", "/")
  $a = @("--headless=new", "--disable-gpu", "--no-sandbox", "--user-data-dir=$udd", "--no-first-run",
         "--no-default-browser-check", "--no-pdf-header-footer", "--virtual-time-budget=10000",
         "--print-to-pdf=$outPdf", $uri)
  $p = Start-Process -FilePath $chrome -ArgumentList $a -Wait -PassThru -NoNewWindow -RedirectStandardError $errLog -RedirectStandardOutput $outLog
  Remove-Item $tmpMd, $tmpHtml -ErrorAction SilentlyContinue
  if (Test-Path $outPdf) {
    Write-Host ("  OK   pdf\{0}.pdf   {1} KB" -f $j.Out, [math]::Round((Get-Item $outPdf).Length / 1KB))
  } else {
    Write-Host ("  FAIL pdf\" + $j.Out + ".pdf   exit=" + $p.ExitCode + "  log=" + $errLog)
  }
}
Write-Host "done."