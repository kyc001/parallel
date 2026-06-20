$ErrorActionPreference = "Stop"

$Root = if ($PSScriptRoot) { $PSScriptRoot } else { (Get-Location).Path }
$Deck = Join-Path $Root "coroutine_deck.pptx"
$Backup = Join-Path $Root "coroutine_deck.before-refine.pptx"
$RenderDir = Join-Path $Root "pptx_render_refined"

if (-not (Test-Path -LiteralPath $Deck)) {
  throw "Missing deck: $Deck"
}
if (-not (Test-Path -LiteralPath $Backup)) {
  Copy-Item -LiteralPath $Deck -Destination $Backup
}

function Shape-Text($Shape) {
  if ($Shape.HasTextFrame -and $Shape.TextFrame.HasText) {
    return $Shape.TextFrame.TextRange.Text
  }
  return $null
}

function Set-ShapeText($Shape, [string]$Text) {
  if ($Shape.HasTextFrame) {
    $Shape.TextFrame.TextRange.Text = $Text
  }
}

function Replace-In-Deck($Presentation, [hashtable]$Map) {
  foreach ($slide in $Presentation.Slides) {
    foreach ($shape in $slide.Shapes) {
      $text = Shape-Text $shape
      if ($null -eq $text) { continue }
      $newText = $text
      foreach ($key in $Map.Keys) {
        $newText = $newText.Replace($key, $Map[$key])
      }
      if ($newText -ne $text) {
        Set-ShapeText $shape $newText
      }
    }
  }
}

function Set-SlideShapeText($Presentation, [int]$SlideNo, [int]$ShapeId, [string]$Text) {
  $slide = $Presentation.Slides.Item($SlideNo)
  foreach ($shape in $slide.Shapes) {
    if ($shape.Id -eq $ShapeId) {
      Set-ShapeText $shape $Text
      return
    }
  }
  throw "Shape $ShapeId not found on slide $SlideNo"
}

function Clear-SlideShapeText($Presentation, [int]$SlideNo, [int]$ShapeId) {
  $slide = $Presentation.Slides.Item($SlideNo)
  foreach ($shape in $slide.Shapes) {
    if ($shape.Id -eq $ShapeId) {
      if ($shape.HasTextFrame) {
        $shape.TextFrame.TextRange.Text = ""
      }
      return
    }
  }
}

function Delete-TextContaining($Presentation, [string]$Needle) {
  foreach ($slide in $Presentation.Slides) {
    for ($i = $slide.Shapes.Count; $i -ge 1; $i--) {
      $shape = $slide.Shapes.Item($i)
      $text = Shape-Text $shape
      if ($null -ne $text -and $text.Contains($Needle)) {
        $shape.Delete()
      }
    }
  }
}

function Add-NoteBox($Slide, [double]$Left, [double]$Top, [double]$Width, [double]$Height, [string]$Text) {
  $msoTextOrientationHorizontal = 1
  $shape = $Slide.Shapes.AddTextbox($msoTextOrientationHorizontal, $Left, $Top, $Width, $Height)
  $shape.TextFrame.TextRange.Text = $Text
  $shape.TextFrame.TextRange.Font.NameFarEast = "Microsoft YaHei"
  $shape.TextFrame.TextRange.Font.Name = "Microsoft YaHei"
  $shape.TextFrame.TextRange.Font.Size = 12
  $shape.TextFrame.TextRange.Font.Color.RGB = 0x465978
  $shape.Fill.ForeColor.RGB = 0xF7F2EA
  $shape.Line.ForeColor.RGB = 0xC1740B
  $shape.Line.Weight = 1
  return $shape
}

$ppt = New-Object -ComObject PowerPoint.Application
$ppt.Visible = -1
$pres = $null

try {
  $pres = $ppt.Presentations.Open((Resolve-Path $Deck).Path, $false, $false, $true)

  Replace-In-Deck $pres @{
    "减��内核切换" = "减少内核切换";
    "避免单 G 独��" = "避免单个 G 独占 M";
    "同—函数即可开并发" = "同步函数即可开并发";
    "P99 起资" = "耗时";
    "3 · 氄漏与取消难" = "3 · 泄漏与取消难";
    "fib(35) 相对吞吐" = "CPU 密集相对耗时";
    "fib(30)" = "fib(25)";
    "Ubuntu 22.04" = "Windows 11 10.0.26200";
    "Go 1.22 / Py 3.12 / JDK 21" = "Go 1.25.6 / Python 3.12.9 / JDK 21.0.5";
    "多次重复取中位数" = "5 次重复取平均值与标准差";
    "百万连发下，OS 线程有≈ 1 万级 OOM 风险，协程则稳。" = "本机 10k 任务下协程/虚拟线程内存更稳；跨语言内存口径仅作量级参考。";
    "Go/Java 快主要来自多核并行，不是协程改变了算法复杂度。" = "CPU 密集任务中，协程不会改变算法复杂度；Go/Java 的短耗时主要来自运行时与多核调度。";
  }

  Set-SlideShapeText $pres 18 12 "CPU 密集"
  Set-SlideShapeText $pres 18 13 "1000 任务，每个 fib(25)"
  Set-SlideShapeText $pres 18 28 "总耗时"
  Set-SlideShapeText $pres 18 29 "平均值 ± 标准差"
  Set-SlideShapeText $pres 18 30 "资源"
  Set-SlideShapeText $pres 18 31 "峰值内存 / 运行时统计"
  Set-SlideShapeText $pres 18 32 "口径"
  Set-SlideShapeText $pres 18 33 "Python 峰值工作集；Go/Java 运行时统计"
  Set-SlideShapeText $pres 18 44 "原则：相同硬件、相同负载、5 次重复取平均值与标准差；sleep 模拟 I/O，不含真实协议栈开销。"

  Set-SlideShapeText $pres 20 7 "10k 任务相关内存（MB，口径不同，仅看量级）"
  Set-SlideShapeText $pres 20 8 "切换/恢复微基准（总耗时换算，越低越好）"
  Set-SlideShapeText $pres 20 11 "口径说明"
  Set-SlideShapeText $pres 20 12 "Python 峰值工作集；Go 为 MemStats.Sys；Java 为 heap+nonHeap。跨语言只看量级，不做绝对排名。"
  Set-SlideShapeText $pres 20 14 "本机结果支持的结论：协程/虚拟线程能显著降低 I/O 等待承载成本；内存与切换数据只用于解释量级，不做绝对排名。"
  Set-SlideShapeText $pres 20 15 "本机结果支持的结论：协程/虚拟线程能显著降低 I/O 等待承载成本；内存与切换数据只用于解释量级，不做绝对排名。"

  Set-SlideShapeText $pres 21 6 "CPU 密集相对耗时（越低越好，取自 fib(25) 实测）"
  Set-SlideShapeText $pres 21 8 "Python asyncio CPU 7.647s、threading 9.521s；Go/Java CPU 测试任务数较小，适合说明协程不会魔法加速计算。"

  $slide26 = $pres.Slides.Item(26)
  foreach ($shape in $slide26.Shapes) {
    $text = Shape-Text $shape
    if ($text -eq "?") {
      Set-ShapeText $shape "？"
      $shape.TextFrame.TextRange.Font.NameFarEast = "Microsoft YaHei"
      $shape.TextFrame.TextRange.Font.Name = "Microsoft YaHei"
      $shape.TextFrame.TextRange.Font.Size = 120
      $shape.TextFrame.TextRange.Font.Color.RGB = 0x0B3F78
    }
  }

  # Remove hidden text from accent bars after text replacement, otherwise it renders as squeezed vertical glyphs.
  Clear-SlideShapeText $pres 18 44
  Clear-SlideShapeText $pres 20 6
  Clear-SlideShapeText $pres 20 14
  Delete-TextContaining $pres "数据来源："

  $pres.Save()

  if (Test-Path -LiteralPath $RenderDir) {
    Remove-Item -LiteralPath $RenderDir -Recurse -Force
  }
  New-Item -ItemType Directory -Path $RenderDir | Out-Null
  $pres.Export((Resolve-Path $RenderDir).Path, "PNG", 1280, 720)
  Write-Host "Refined $Deck"
  Write-Host "Backup  $Backup"
  Write-Host "Slides  $($pres.Slides.Count)"
}
finally {
  if ($pres) {
    $pres.Close()
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($pres)
  }
  if ($ppt) {
    $ppt.Quit()
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($ppt)
  }
  [GC]::Collect()
  [GC]::WaitForPendingFinalizers()
}
