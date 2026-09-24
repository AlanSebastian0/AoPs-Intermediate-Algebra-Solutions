param (
    [Parameter(Mandatory = $true)]
    [string]$texFile
)

$workspaceDir = Split-Path -Parent $PSScriptRoot
$sourcePath = if ([System.IO.Path]::IsPathRooted($texFile)) {
    [System.IO.Path]::GetFullPath($texFile)
} else {
    [System.IO.Path]::GetFullPath((Join-Path $workspaceDir $texFile))
}
$buildDir = Join-Path $workspaceDir "build"
$pdfDir = Join-Path $workspaceDir "pdf"

New-Item -ItemType Directory -Force $buildDir, $pdfDir | Out-Null

if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
    throw "LaTeX source file not found: $sourcePath"
}

Push-Location $workspaceDir
try {
    latexmk -pdf -interaction=nonstopmode -synctex=1 `
        "-auxdir=$buildDir" "-outdir=$pdfDir" $sourcePath
    if ($LASTEXITCODE -ne 0) {
        exit $LASTEXITCODE
    }
}
finally {
    Pop-Location
}

$synctexName = [System.IO.Path]::GetFileNameWithoutExtension($sourcePath) + ".synctex.gz"
$synctexFile = Join-Path $pdfDir $synctexName
if (Test-Path $synctexFile) {
    Move-Item $synctexFile (Join-Path $buildDir $synctexName) -Force
}
