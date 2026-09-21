param (
    [string]$texFile
)

# 1. Setup directory names
$buildDir = "build"
$pdfDir = "pdf"

# 2. Create output directories quietly
New-Item -ItemType Directory -Force $buildDir, $pdfDir | Out-Null

# 3. Put auxiliary files in build and the final PDF in pdf
latexmk -pdf -interaction=nonstopmode -synctex=1 `
    "-auxdir=$buildDir" "-outdir=$pdfDir" $texFile

# SyncTeX data is auxiliary output, so keep it with the other build files.
$synctexName = [System.IO.Path]::GetFileNameWithoutExtension($texFile) + ".synctex.gz"
$synctexFile = Join-Path $pdfDir $synctexName
if (Test-Path $synctexFile) {
    Move-Item $synctexFile (Join-Path $buildDir $synctexName) -Force
}
