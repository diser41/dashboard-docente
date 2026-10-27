<#
.SYNOPSIS
  Prepara los datos ficticios del mock up (tareas T002 y T003 de specs/001-dashboard-docente/tasks.md).

.DESCRIPTION
  1. Lee la planilla de ejemplo (.xlsx) sin Excel: abre el zip y lee el XML de cada hoja.
  2. Convierte la numeración ilustrativa OA1–OA5 a los códigos oficiales MINEDUC (plan §5).
  3. Simula las preguntas de las sumativas de forma determinista (plan §7).
  4. Escribe data/mockup-data_generado.json y lo inserta en el HTML del mock up,
     entre los marcadores <!-- DATA:BEGIN --> y <!-- DATA:END -->.

  Nunca modifica los originales de data/. Termina con error si alguna comprobación falla.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File mockup/scripts/extract-data.ps1
#>
param(
  [string]$Workbook = (Join-Path $PSScriptRoot '..\..\data\Base_Evaluaciones_1MA_Quimica_2026.xlsx'),
  [string]$ObjectivesCsv = (Join-Path $PSScriptRoot '..\..\data\OA_Quimica_1M_MINEDUC.csv'),
  [string]$OutJson = (Join-Path $PSScriptRoot '..\..\data\mockup-data_generado.json'),
  [string]$Html = (Join-Path $PSScriptRoot '..\dashboard-docente.html'),
  [int]$Seed = 2026
)

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$utf8 = New-Object System.Text.UTF8Encoding $false

function Fail($message) { throw "extract-data: $message" }

# --- Lectura del xlsx -------------------------------------------------------

function Read-ZipEntry($zip, $name) {
  $entry = $zip.GetEntry($name)
  if (-not $entry) { Fail "no se encontró $name en la planilla" }
  $reader = New-Object System.IO.StreamReader($entry.Open(), [Text.Encoding]::UTF8)
  try { $reader.ReadToEnd() } finally { $reader.Dispose() }
}

function Read-Sheet($zip, $sheetName, $sharedStrings, $sheetPaths) {
  [xml]$sheet = Read-ZipEntry $zip $sheetPaths[$sheetName]
  $rows = @($sheet.worksheet.sheetData.row)
  $header = @{}
  foreach ($c in $rows[0].c) { $header[($c.r -replace '\d', '')] = $sharedStrings[[int]$c.v] }
  foreach ($row in ($rows | Select-Object -Skip 1)) {
    $record = [ordered]@{}
    foreach ($c in $row.c) {
      $col = $c.r -replace '\d', ''
      if (-not $header.ContainsKey($col)) { continue }
      $record[$header[$col]] = if ($c.t -eq 's') { $sharedStrings[[int]$c.v] } elseif ($c.v) { $c.v } else { $null }
    }
    if ($record.Count -gt 0) { [pscustomobject]$record }
  }
}

$zip = [IO.Compression.ZipFile]::OpenRead((Resolve-Path $Workbook))
try {
  [xml]$sst = Read-ZipEntry $zip 'xl/sharedStrings.xml'
  $sharedStrings = @($sst.sst.si | ForEach-Object { $_.InnerText })
  [xml]$wb = Read-ZipEntry $zip 'xl/workbook.xml'
  [xml]$rels = Read-ZipEntry $zip 'xl/_rels/workbook.xml.rels'
  $targets = @{}
  foreach ($r in $rels.Relationships.Relationship) { $targets[$r.Id] = 'xl/' + $r.Target }
  $sheetPaths = @{}
  foreach ($s in $wb.workbook.sheets.sheet) {
    $sheetPaths[$s.name] = $targets[$s.GetAttribute('id', 'http://schemas.openxmlformats.org/officeDocument/2006/relationships')]
  }
  $rawStudents = @(Read-Sheet $zip 'Estudiantes' $sharedStrings $sheetPaths)
  $rawEvaluations = @(Read-Sheet $zip 'Evaluaciones' $sharedStrings $sheetPaths)
  $rawResults = @(Read-Sheet $zip 'Resultados' $sharedStrings $sheetPaths)
} finally { $zip.Dispose() }

function Convert-ExcelDate($serial) { ([datetime]'1899-12-30').AddDays([int]$serial).ToString('yyyy-MM-dd') }

# --- Conversión a OA oficiales (plan §5) ------------------------------------

$objectiveMap = @{
  'OA1' = 'CN1M OA 17'
  'OA2' = 'CN1M OA 18'
  'OA3' = 'CN1M OA 20'
  'OA4' = 'CN1M OA 20'
  'OA5' = 'CN1M OAH d, f'
}
$typeMap = @{ 'Diagnóstica' = 'diagnostic'; 'Formativa' = 'formative'; 'Sumativa' = 'summative' }

$csv = Import-Csv -Path $ObjectivesCsv -Delimiter ';' -Encoding UTF8
$objectives = @()
foreach ($o in ($csv | Where-Object { $_.tipo -eq 'Conocimiento' })) {
  $objectives += [ordered]@{ code = $o.codigo; kind = 'knowledge'; text = $o.descripcion }
}
$skillText = (($csv | Where-Object { $_.codigo -in 'CN1M OAH d', 'CN1M OAH f' }) | ForEach-Object { $_.codigo + ': ' + $_.descripcion }) -join ' '
$objectives += [ordered]@{ code = 'CN1M OAH d, f'; kind = 'skill'; text = $skillText }

# --- Estudiantes (sin género ni asistencia: minimización, plan §5) ----------

$students = @($rawStudents | ForEach-Object {
  [ordered]@{ id = $_.'ID estudiante'; name = $_.Nombre; pie = ($_.PIE -eq 'Sí') }
})

# --- Evaluaciones -----------------------------------------------------------

$evaluations = @()
foreach ($e in $rawEvaluations) {
  $maxPerObjective = [int]$e.'Puntaje máximo por OA'
  $evalObjectives = [ordered]@{}
  foreach ($local in ($e.'OA evaluados' -split ',\s*')) {
    $code = $objectiveMap[$local]
    if (-not $code) { Fail "OA desconocido '$local' en $($e.'ID evaluación')" }
    $evalObjectives[$code] = [int]$evalObjectives[$code] + $maxPerObjective
  }
  $weight = $e.'Ponderación en nota final'
  $evaluations += [ordered]@{
    id = $e.'ID evaluación'
    type = $typeMap[$e.Tipo]
    name = $e.Nombre
    instrument = $e.Instrumento
    date = Convert-ExcelDate $e.Fecha
    weight = if ($weight) { [int][math]::Round([double]$weight * 100) } else { $null }
    objectives = @($evalObjectives.Keys | ForEach-Object { [ordered]@{ code = $_; maxScore = $evalObjectives[$_] } })
  }
}

# --- Resultados: suma OA3 + OA4 cuando una evaluación mide ambos ------------

$expectedRows = ($rawEvaluations | ForEach-Object { ($_.'OA evaluados' -split ',\s*').Count } | Measure-Object -Sum).Sum * $students.Count
if ($rawResults.Count -ne $expectedRows) { Fail "Resultados tiene $($rawResults.Count) filas; se esperaban $expectedRows" }

$merged = [ordered]@{}
foreach ($r in $rawResults) {
  $code = $objectiveMap[$r.OA]
  $key = "$($r.'ID estudiante')|$($r.'ID evaluación')|$code"
  if (-not $merged.Contains($key)) {
    $merged[$key] = [ordered]@{ studentId = $r.'ID estudiante'; evaluationId = $r.'ID evaluación'; objective = $code; score = 0; maxScore = 0; absent = $true }
  }
  $m = $merged[$key]
  $m.maxScore += [int]$r.'Puntaje máximo'
  if ($r.Estado -eq 'Rendida') { $m.absent = $false; $m.score += [int]$r.'Puntaje obtenido' }
  elseif ($r.Estado -ne 'Ausente') { Fail "estado desconocido '$($r.Estado)'" }
}
$results = @($merged.Values | ForEach-Object { if ($_.absent) { $_.score = $null }; $_ })

# --- Simulación de preguntas de las sumativas (plan §7) ---------------------

$script:rngState = [uint64]$Seed
function Next-Random {
  # Generador congruencial lineal de 32 bits (Numerical Recipes): determinista con semilla fija.
  $script:rngState = (1664525 * $script:rngState + 1013904223) % 4294967296
  [double]$script:rngState / 4294967296
}

$questions = @()
$answers = @()
foreach ($e in ($evaluations | Where-Object { $_.type -eq 'summative' })) {
  # Una pregunta de 1 punto por cada punto máximo del OA, con dificultad ficticia.
  $pool = @()
  foreach ($o in $e.objectives) {
    for ($i = 0; $i -lt $o.maxScore; $i++) { $pool += [pscustomobject]@{ objective = $o.code; difficulty = (Next-Random); order = (Next-Random) } }
  }
  $pool = @($pool | Sort-Object order)
  for ($n = 0; $n -lt $pool.Count; $n++) {
    $pool[$n] | Add-Member number ($n + 1)
    $questions += [ordered]@{ evaluationId = $e.id; number = $n + 1; objective = $pool[$n].objective; points = 1 }
  }

  foreach ($s in $students) {
    $correct = New-Object char[] $pool.Count
    for ($n = 0; $n -lt $pool.Count; $n++) { $correct[$n] = '0' }
    $absent = $false
    foreach ($o in $e.objectives) {
      $result = $merged["$($s.id)|$($e.id)|$($o.code)"]
      if ($result.absent) { $absent = $true; continue }
      # Acierta exactamente "score" preguntas del OA, de preferencia las más fáciles.
      $ranked = @($pool | Where-Object { $_.objective -eq $o.code } |
        ForEach-Object { [pscustomobject]@{ number = $_.number; key = $_.difficulty + 0.8 * (Next-Random) } } |
        Sort-Object key | Select-Object -First $result.score)
      foreach ($q in $ranked) { $correct[$q.number - 1] = '1' }
    }
    if (-not $absent) { $answers += [ordered]@{ studentId = $s.id; evaluationId = $e.id; correct = -join $correct } }
  }
}

# Garantía de coherencia: aciertos por estudiante y OA = puntaje de la planilla.
foreach ($a in $answers) {
  foreach ($q in ($questions | Where-Object { $_.evaluationId -eq $a.evaluationId })) {
    $key = "$($a.studentId)|$($a.evaluationId)|$($q.objective)"
    if ($null -eq $merged[$key].hits) { $merged[$key].hits = 0 }
    if ($a.correct[$q.number - 1] -eq '1') { $merged[$key].hits++ }
  }
}
foreach ($m in $merged.Values) {
  if ($m.Contains('hits') -and $m.hits -ne $m.score) { Fail "aciertos ($($m.hits)) distintos del puntaje ($($m.score)) en $($m.studentId)/$($m.evaluationId)/$($m.objective)" }
  $m.Remove('hits')
}

# --- Escritura ---------------------------------------------------------------

$data = [ordered]@{
  meta = [ordered]@{
    course = '1° Medio A'
    subject = 'Química'
    year = 2026
    note = 'Datos FICTICIOS para el mock up. Generado por mockup/scripts/extract-data.ps1; no editar a mano.'
    source = 'data/Base_Evaluaciones_1MA_Quimica_2026.xlsx y data/OA_Quimica_1M_MINEDUC.csv'
    seed = $Seed
  }
  students = $students
  objectives = $objectives
  evaluations = $evaluations
  results = $results
  questions = $questions
  answers = $answers
}
$json = $data | ConvertTo-Json -Depth 6 -Compress
[IO.File]::WriteAllText($OutJson, $json, $utf8)

if (Test-Path $Html) {
  $page = [IO.File]::ReadAllText((Resolve-Path $Html), $utf8)
  $pattern = '(?s)(<!-- DATA:BEGIN -->).*?(<!-- DATA:END -->)'
  if ($page -notmatch $pattern) { Fail "no se encontraron los marcadores DATA:BEGIN/DATA:END en $Html" }
  $block = "<!-- DATA:BEGIN -->`n<script type=`"application/json`" id=`"mockup-data`">$json</script>`n<!-- DATA:END -->"
  $page = [regex]::Replace($page, $pattern, { param($m) $block })
  [IO.File]::WriteAllText((Resolve-Path $Html), $page, $utf8)
}

# --- Resumen -----------------------------------------------------------------

$absentCount = @($results | Where-Object { $_.absent }).Count
$summary = @(
  "Estudiantes:          $($students.Count) (PIE: $(@($students | Where-Object { $_.pie }).Count))"
  "Evaluaciones:         $($evaluations.Count)"
  "Filas de la planilla: $($rawResults.Count) -> $($results.Count) resultados con OA oficiales"
  "Ausencias:            $absentCount"
  "OA de conocimiento:   $(@($objectives | Where-Object { $_.kind -eq 'knowledge' }).Count) (sin resultados: $(@($objectives | Where-Object { $o = $_.code; $_.kind -eq 'knowledge' -and -not ($results | Where-Object { $_.objective -eq $o }) } | ForEach-Object { $_.code }) -join ', '))"
  "Preguntas simuladas:  $(($evaluations | Where-Object { $_.type -eq 'summative' } | ForEach-Object { $id = $_.id; "$id=$(@($questions | Where-Object { $_.evaluationId -eq $id }).Count)" }) -join ' ')"
  "Respuestas:           $($answers.Count) (coherentes con los puntajes)"
  "JSON:                 $OutJson ($([math]::Round($json.Length / 1KB)) KB)"
)
$summary | ForEach-Object { Write-Output $_ }
