
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()
$ErrorActionPreference = "Stop"

$script:RootPath = ""

# Display names only. Files are always saved as level_XX.ogg.
$script:KnownNames = @{
    0  = "DINGO_CANYON"
    1  = "DRAGON_MINES"
    2  = "BLIZZARD_BLUFF"
    3  = "CRASH_COVE"
    4  = "TIGER_TEMPLE"
    5  = "PAPU_PYRAMID"
    6  = "ROO_TUBES"
    7  = "HOT_AIR_SKYWAY"
    8  = "SEWER_SPEEDWAY"
    9  = "MYSTERY_CAVES"
    10 = "CORTEX_CASTLE"
    11 = "N_GIN_LABS"
    12 = "POLAR_PASS"
    13 = "OXIDE_STATION"
    14 = "COCO_PARK"
    15 = "TINY_ARENA"
    16 = "SLIDE_COLISEUM"
    17 = "TURBO_TRACK"
    18 = "NITRO_COURT"
    19 = "RAMPAGE_RUINS"
    20 = "PARKING_LOT"
    21 = "SKULL_ROCK"
    22 = "THE_NORTH_BOWL"
    23 = "ROCKY_ROAD"
    24 = "LAB_BASEMENT"
    25 = "GEM_STONE_VALLEY"
    26 = "N_SANITY_BEACH"
    27 = "THE_LOST_RUINS"
    28 = "GLACIER_PARK"
    29 = "CITADEL_CITY"
    30 = "INTRO_RACE_TODAY"
    31 = "INTRO_COCO"
    32 = "INTRO_TINY"
    33 = "INTRO_POLAR"
    34 = "INTRO_DINGODILE"
    35 = "INTRO_CORTEX"
    36 = "INTRO_SPACE"
    37 = "INTRO_CRASH"
    38 = "INTRO_OXIDE"
    39 = "MAIN_MENU_LEVEL"
    40 = "ADVENTURE_CHARACTER_SELECT"
    41 = "NAUGHTY_DOG_CRATE"
    42 = "OXIDE_ENDING"
    43 = "OXIDE_TRUE_ENDING"
    44 = "CREDITS_LEVEL"
    45 = "CREDITS_CRASH"
    46 = "CREDITS_TINY"
    47 = "CREDITS_COCO"
    48 = "CREDITS_N_GIN"
    49 = "CREDITS_DINGO"
    50 = "CREDITS_POLAR"
    51 = "CREDITS_PURA"
    52 = "CREDITS_PINSTRIPE"
    53 = "CREDITS_PAPU"
    54 = "CREDITS_ROO"
    55 = "CREDITS_JOE"
    56 = "CREDITS_TROPY"
    57 = "CREDITS_PENTA"
    58 = "CREDITS_FAKE_CRASH"
    59 = "CREDITS_OXIDE"
    60 = "CREDITS_AMI"
    61 = "CREDITS_ISABELLA"
    62 = "CREDITS_LIZ"
    63 = "CREDITS_MEGUMI"
    64 = "SCRAPBOOK"
}

# Show base references even without an OGG.
# Reference IDs are assigned in the exact order supplied by the user (0..64).
$script:ReferenceIds = 0..64

# ---------- Colors ----------
$C_BG      = [System.Drawing.Color]::FromArgb(30,30,32)
$C_PANEL   = [System.Drawing.Color]::FromArgb(39,39,42)
$C_PANEL2  = [System.Drawing.Color]::FromArgb(46,46,50)
$C_TEXT    = [System.Drawing.Color]::FromArgb(242,242,242)
$C_MUTED   = [System.Drawing.Color]::FromArgb(185,185,190)
$C_ACCENT  = [System.Drawing.Color]::FromArgb(66,133,244)
$C_DANGER  = [System.Drawing.Color]::FromArgb(170,65,65)
$C_BORDER  = [System.Drawing.Color]::FromArgb(78,78,84)

function Show-Error([string]$msg) {
    [System.Windows.Forms.MessageBox]::Show(
        $msg, "CTR Music Toolkit",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
}

function Show-Info([string]$msg) {
    [System.Windows.Forms.MessageBox]::Show(
        $msg, "CTR Music Toolkit",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}

function MusicDirs {
    if ([string]::IsNullOrWhiteSpace($script:RootPath)) { return @() }
    return @(
        (Join-Path $script:RootPath "assets\MUSIC_CUSTOM")
    )
}

function Test-CtrRoot([string]$path) {
    if (!(Test-Path $path -PathType Container)) { return $false }
    return (Test-Path (Join-Path $path "ctr_native.exe") -PathType Leaf)
}

function Ensure-MusicDirs {
    foreach ($d in (MusicDirs)) {
        if (!(Test-Path $d)) {
            [IO.Directory]::CreateDirectory($d) | Out-Null
        }
    }
}

function Set-Root([string]$path) {
    if ([string]::IsNullOrWhiteSpace($path)) { return $false }

    try {
        $path = [Environment]::ExpandEnvironmentVariables($path.Trim().Trim('"'))
        if ($path -match '(?i)\\ctr_native\.exe$') {
            $path = Split-Path $path -Parent
        }
        $resolved = (Resolve-Path -LiteralPath $path).Path
    }
    catch {
        Show-Error "Folder not found:`n$path"
        return $false
    }

    if (!(Test-CtrRoot $resolved)) {
        Show-Error "Select the compiled game folder containing ctr_native.exe:`n$resolved"
        return $false
    }

    try { [IO.Directory]::CreateDirectory((Join-Path $resolved "assets\MUSIC_CUSTOM")) | Out-Null }
    catch {
        Show-Error ("Could not create the music folder.`n`n" + $_.Exception.Message)
        return $false
    }

    $script:RootPath = $resolved
    $pathBox.Text = $resolved
    Refresh-List
    return $true
}

function Apply-RootFromBox {
    $entered = $pathBox.Text.Trim()
    if ([string]::IsNullOrWhiteSpace($entered)) {
        Show-Error "Enter the game folder path or click Browse."
        return $false
    }
    if ($entered -eq $script:RootPath) { return $true }
    return (Set-Root $entered)
}

function Pick-Root {
    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "Select the folder containing ctr_native.exe"
    if ($script:RootPath) { $dlg.SelectedPath = $script:RootPath }

    if ($dlg.ShowDialog($form) -eq [System.Windows.Forms.DialogResult]::OK) {
        [void](Set-Root $dlg.SelectedPath)
    }
}

function Get-DisplayName([int]$id) {
    if ($script:KnownNames.ContainsKey($id)) {
        return $script:KnownNames[$id]
    }
    return "Level $id"
}

function Get-TrackRows {
    $rows = @{}

    # 1) Always create base references.
    foreach ($id in $script:ReferenceIds) {
        $fileName = "level_{0:D2}.ogg" -f $id
        $rows[$fileName.ToLowerInvariant()] = [PSCustomObject]@{
            ID = $id
            Name = Get-DisplayName $id
            File = $fileName
            Paths = New-Object System.Collections.ArrayList
            HasFinal = $false
            IsReference = $true
        }
    }

    # 2) Detect installed OGG files.
    foreach ($d in (MusicDirs)) {
        if (!(Test-Path $d)) { continue }

        Get-ChildItem $d -Filter *.ogg -File -ErrorAction SilentlyContinue | ForEach-Object {
            $name = $_.Name
            $key = $name.ToLowerInvariant()

            if ($name -match '^level_(\d+)\.ogg$') {
                $id = [int]$matches[1]

                if (!$rows.ContainsKey($key)) {
                    # Add extra/custom IDs automatically.
                    $rows[$key] = [PSCustomObject]@{
                        ID = $id
                        Name = Get-DisplayName $id
                        File = $name
                        Paths = New-Object System.Collections.ArrayList
                        HasFinal = $false
                        IsReference = $false
                    }
                }

                [void]$rows[$key].Paths.Add($_.FullName)
            }
            elseif ($name -match '^level_(\d+)_final\.ogg$') {
                $id = [int]$matches[1]
                $normalName = "level_{0:D2}.ogg" -f $id
                $normalKey = $normalName.ToLowerInvariant()
                if (!$rows.ContainsKey($normalKey)) {
                    $rows[$normalKey] = [PSCustomObject]@{
                        ID = $id
                        Name = Get-DisplayName $id
                        File = $normalName
                        Paths = New-Object System.Collections.ArrayList
                        HasFinal = $false
                        IsReference = $false
                    }
                }
                $rows[$normalKey].HasFinal = $true
            }
            else {
                # Legacy/nonstandard file.
                if (!$rows.ContainsKey($key)) {
                    $rows[$key] = [PSCustomObject]@{
                        ID = ""
                        Name = "[Legacy] " + [IO.Path]::GetFileNameWithoutExtension($name)
                        File = $name
                        Paths = New-Object System.Collections.ArrayList
                        HasFinal = $false
                        IsReference = $false
                    }
                }

                [void]$rows[$key].Paths.Add($_.FullName)
            }
        }
    }

    return $rows.Values | Sort-Object `
        @{Expression={ if ($null -eq $_.ID -or [string]::IsNullOrWhiteSpace([string]$_.ID)) { 999999 } else { [int]$_.ID }}}, `
        File
}

function Refresh-List {
    $list.BeginUpdate()
    try {
        $list.Items.Clear()

        if ([string]::IsNullOrWhiteSpace($script:RootPath)) {
            $status.Text = "Select or enter the folder containing ctr_native.exe to begin."
            return
        }

        foreach ($r in (Get-TrackRows)) {
            $copies = $r.Paths.Count

            if ($copies -gt 0) {
                $copyText = if ($r.HasFinal) { "OGG + Final" } else { "OGG" }
            } elseif ($r.HasFinal) {
                $copyText = "Final only"
            } else {
                $copyText = "—"
            }

            $item = New-Object System.Windows.Forms.ListViewItem(([string]$r.ID))
            [void]$item.SubItems.Add($r.Name)
            [void]$item.SubItems.Add($r.File)
            [void]$item.SubItems.Add($copyText)

            if (($copies -eq 0) -and !$r.HasFinal) {
                $item.ForeColor = $C_MUTED
            }
            else {
                $item.ForeColor = $C_TEXT
            }

            $item.Tag = $r
            [void]$list.Items.Add($item)
        }

        $installed = @((Get-TrackRows) | Where-Object { $_.Paths.Count -gt 0 }).Count
        $status.Text = "{0} track(s) with custom OGG files. All reference IDs are shown." -f $installed
    }
    finally {
        $list.EndUpdate()
    }
}

function Prompt-TrackId {
    $f = New-Object System.Windows.Forms.Form
    $f.Text = "Assign Level ID"
    $f.StartPosition = "CenterParent"
    $f.ClientSize = New-Object System.Drawing.Size(380,150)
    $f.FormBorderStyle = "FixedDialog"
    $f.MaximizeBox = $false
    $f.MinimizeBox = $false
    $f.BackColor = $C_BG
    $f.ForeColor = $C_TEXT

    $lab = New-Object System.Windows.Forms.Label
    $lab.Text = "Level ID (example: 3, 26, 42)"
    $lab.AutoSize = $true
    $lab.ForeColor = $C_TEXT
    $lab.Location = New-Object System.Drawing.Point(18,18)

    $txt = New-Object System.Windows.Forms.NumericUpDown
    $txt.Minimum = 0
    $txt.Maximum = 999
    $txt.Value = 3
    $txt.Location = New-Object System.Drawing.Point(20,48)
    $txt.Width = 330
    $txt.Font = New-Object System.Drawing.Font("Segoe UI",10)

    $ok = New-Object System.Windows.Forms.Button
    $ok.Text = "OK"
    $ok.Location = New-Object System.Drawing.Point(190,94)
    $ok.Size = New-Object System.Drawing.Size(75,32)
    $ok.FlatStyle = "Flat"
    $ok.BackColor = $C_ACCENT
    $ok.ForeColor = [System.Drawing.Color]::White

    $cancel = New-Object System.Windows.Forms.Button
    $cancel.Text = "Cancel"
    $cancel.Location = New-Object System.Drawing.Point(275,94)
    $cancel.Size = New-Object System.Drawing.Size(75,32)
    $cancel.FlatStyle = "Flat"
    $cancel.BackColor = $C_PANEL2
    $cancel.ForeColor = $C_TEXT

    $ok.Add_Click({
        $script:PromptResult = [int]$txt.Value
        $f.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $f.Close()
    })
    $cancel.Add_Click({
        $f.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        $f.Close()
    })

    $f.Controls.AddRange(@($lab,$txt,$ok,$cancel))
    $f.AcceptButton = $ok
    $f.CancelButton = $cancel

    $script:PromptResult = $null
    if ($f.ShowDialog($form) -eq [System.Windows.Forms.DialogResult]::OK) {
        return $script:PromptResult
    }
    return $null
}

function Test-OggVorbis([IO.Stream]$stream) {
    $stream.Position = 0
    $reader = [IO.BinaryReader]::new($stream, [Text.Encoding]::ASCII, $true)
    try {
        $page = $reader.ReadBytes(27)
        if ($page.Length -ne 27) { return $false }
        if ([Text.Encoding]::ASCII.GetString($page, 0, 4) -ne "OggS") { return $false }
        if ($page[4] -ne 0) { return $false }
        $segments = $reader.ReadBytes([int]$page[26])
        if ($segments.Length -ne [int]$page[26]) { return $false }
        $packet = $reader.ReadBytes(7)
        return (($packet.Length -eq 7) -and ($packet[0] -eq 1) -and
            ([Text.Encoding]::ASCII.GetString($packet, 1, 6) -eq "vorbis"))
    }
    finally {
        $reader.Dispose()
        $stream.Position = 0
    }
}

function Copy-And-Verify([string]$source, [string]$dest) {
    $sourceStream = $null
    $temp = $null
    try {
        $sourceFull = [IO.Path]::GetFullPath($source)
        $destFull = [IO.Path]::GetFullPath($dest)
        $parent = Split-Path $destFull -Parent
        [IO.Directory]::CreateDirectory($parent) | Out-Null

        $sourceStream = [IO.File]::Open($sourceFull, [IO.FileMode]::Open,
            [IO.FileAccess]::Read, [IO.FileShare]::Read)
        $bytes = $sourceStream.Length
        if ($bytes -le 0) { throw "The source file is empty." }
        if (!(Test-OggVorbis $sourceStream)) {
            throw "The file must be OGG Vorbis (not Opus or a file renamed to .ogg)."
        }

        if (![string]::Equals($sourceFull, $destFull,
            [StringComparison]::OrdinalIgnoreCase)) {
            $temp = Join-Path $parent ("." + [IO.Path]::GetFileName($destFull) +
                "." + [Guid]::NewGuid().ToString("N") + ".tmp")
            $destStream = [IO.File]::Open($temp, [IO.FileMode]::CreateNew,
                [IO.FileAccess]::Write, [IO.FileShare]::None)
            try {
                $sourceStream.CopyTo($destStream)
                $destStream.Flush($true)
                if ($destStream.Length -ne $bytes) {
                    throw "The OGG file could not be fully copied."
                }
            }
            finally { $destStream.Dispose() }

            $sourceStream.Dispose()
            $sourceStream = $null
            [IO.File]::Copy($temp, $destFull, $true)
        }

        $check = [IO.File]::OpenRead($destFull)
        try {
            if ($check.Length -ne $bytes) {
                throw "The copied file has an unexpected size."
            }
        }
        finally { $check.Dispose() }

        return [PSCustomObject]@{
            Success = $true
            Path = $destFull
            Error = ""
            Bytes = $bytes
        }
    }
    catch {
        return [PSCustomObject]@{
            Success = $false
            Path = $dest
            Error = $_.Exception.Message
            Bytes = 0
        }
    }
    finally {
        if ($sourceStream) { $sourceStream.Dispose() }
        if ($temp -and (Test-Path -LiteralPath $temp)) {
            Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
        }
    }
}

function Add-Music {
    if ($pathBox.Text.Trim() -and $pathBox.Text.Trim() -ne $script:RootPath -and !(Apply-RootFromBox)) { return }
    if ([string]::IsNullOrWhiteSpace($script:RootPath)) {
        Pick-Root
        if ([string]::IsNullOrWhiteSpace($script:RootPath)) { return }
    }

    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title = "Select an OGG track"
    $dlg.Filter = "OGG Vorbis (*.ogg)|*.ogg"
    $dlg.CheckFileExists = $true

    if ($dlg.ShowDialog($form) -ne [System.Windows.Forms.DialogResult]::OK) { return }

    $id = Prompt-TrackId
    if ($null -eq $id) { return }

    $destName = "level_{0:D2}.ogg" -f $id
    $results = New-Object System.Collections.ArrayList

    Ensure-MusicDirs

    foreach ($d in (MusicDirs)) {
        $dest = Join-Path $d $destName
        [void]$results.Add((Copy-And-Verify $dlg.FileName $dest))
    }

    Refresh-List

    $okCount = @($results | Where-Object { $_.Success }).Count
    if ($okCount -eq 1) {
        $bytes = ($results | Select-Object -First 1).Bytes
        $status.Text = "OK: $destName - $bytes bytes."
        Show-Info ("Track imported successfully.`n`n" +
            "Level ID: $id`n" +
            "File: $destName`n" +
            "Size: $bytes bytes.")
    }
    else {
        Refresh-List

        $errors = ($results | Where-Object { !$_.Success } | ForEach-Object {
            "$($_.Path)`n  $($_.Error)"
        }) -join "`n`n"

        Show-Error ("Import failed.`n`n" +
            "Successful files: $okCount/1`n`n" +
            $errors)
    }
}

function Add-MusicForId([int]$id) {
    if ($pathBox.Text.Trim() -and $pathBox.Text.Trim() -ne $script:RootPath -and !(Apply-RootFromBox)) { return }
    if ([string]::IsNullOrWhiteSpace($script:RootPath)) {
        Pick-Root
        if ([string]::IsNullOrWhiteSpace($script:RootPath)) { return }
    }

    $dlg = New-Object System.Windows.Forms.OpenFileDialog
    $dlg.Title = "Select an OGG track"
    $dlg.Filter = "OGG Vorbis (*.ogg)|*.ogg"
    $dlg.CheckFileExists = $true

    if ($dlg.ShowDialog($form) -ne [System.Windows.Forms.DialogResult]::OK) { return }

    $destName = "level_{0:D2}.ogg" -f $id
    $results = New-Object System.Collections.ArrayList

    Ensure-MusicDirs

    foreach ($d in (MusicDirs)) {
        $dest = Join-Path $d $destName
        [void]$results.Add((Copy-And-Verify $dlg.FileName $dest))
    }

    Refresh-List

    $okCount = @($results | Where-Object { $_.Success }).Count
    if ($okCount -eq 1) {
        Show-Info ("Track imported successfully.`n`n" +
            "Level ID: $id`n" +
            "File: $destName.")
    }
    else {
        $errors = ($results | Where-Object { !$_.Success } | ForEach-Object {
            "$($_.Path)`n  $($_.Error)"
        }) -join "`n`n"

        Show-Error ("Import failed.`n`n" +
            "Verified files: $okCount/1`n`n" +
            $errors)
    }
}

function Find-FFmpeg {
    $localCandidates = @(
        (Join-Path $PSScriptRoot "tools\ffmpeg.exe"),
        (Join-Path $PSScriptRoot "ffmpeg.exe")
    )

    foreach ($p in $localCandidates) {
        if (Test-Path $p -PathType Leaf) { return $p }
    }

    $cmd = Get-Command ffmpeg.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }

    return $null
}

function Install-FFmpegForToolkit {
    $answer = [System.Windows.Forms.MessageBox]::Show(
        "FFmpeg is required to create a Final Lap while preserving pitch.`n`n" +
        "FFmpeg was not found on this PC.`n`n" +
        "Download FFmpeg Essentials automatically?`n" +
        "(about 109 MB, first time only)",
        "CTR Music Toolkit",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )

    if ($answer -ne [System.Windows.Forms.DialogResult]::Yes) {
        return $null
    }

    $toolsDir = Join-Path $PSScriptRoot "tools"
    $zipPath = Join-Path $toolsDir "ffmpeg.zip"
    $extractDir = Join-Path $toolsDir "_ffmpeg_extract"

    try {
        [IO.Directory]::CreateDirectory($toolsDir) | Out-Null

        $status.Text = "Downloading FFmpeg..."
        [System.Windows.Forms.Application]::DoEvents()

        $url = "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"
        Invoke-WebRequest -Uri $url -OutFile $zipPath -UseBasicParsing

        if (Test-Path $extractDir) {
            Remove-Item $extractDir -Recurse -Force
        }

        Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

        $ff = Get-ChildItem $extractDir -Recurse -Filter ffmpeg.exe -File |
            Select-Object -First 1

        if (!$ff) {
            throw "ffmpeg.exe was not found in the ZIP."
        }

        $dest = Join-Path $toolsDir "ffmpeg.exe"
        Copy-Item $ff.FullName $dest -Force

        Remove-Item $extractDir -Recurse -Force
        Remove-Item $zipPath -Force

        $status.Text = "FFmpeg ready."
        return $dest
    }
    catch {
        Show-Error ("Could not set up FFmpeg.`n`n" + $_.Exception.Message)
        return $null
    }
}

function Get-SelectedReferenceRow {
    if ($list.SelectedItems.Count -eq 0) {
        Show-Info "Select a Level ID from the list first."
        return $null
    }

    $row = $list.SelectedItems[0].Tag
    if ($row.ID -eq "") {
        Show-Info "Select a level_XX.ogg file."
        return $null
    }

    return $row
}

function Create-FinalLap {
    if ($pathBox.Text.Trim() -and $pathBox.Text.Trim() -ne $script:RootPath -and !(Apply-RootFromBox)) { return }
    if ([string]::IsNullOrWhiteSpace($script:RootPath)) {
        Pick-Root
        if ([string]::IsNullOrWhiteSpace($script:RootPath)) { return }
    }

    $row = Get-SelectedReferenceRow
    if ($null -eq $row) { return }

    $id = [int]$row.ID
    $normalName = "level_{0:D2}.ogg" -f $id
    $finalName = "level_{0:D2}_final.ogg" -f $id

    $source = $null
    foreach ($d in (MusicDirs)) {
        $candidate = Join-Path $d $normalName
        if (Test-Path $candidate -PathType Leaf) {
            $source = $candidate
            break
        }
    }

    if (!$source) {
        Show-Error "This Level ID has no $normalName to convert."
        return
    }

    $ffmpeg = Find-FFmpeg
    if (!$ffmpeg) {
        $ffmpeg = Install-FFmpegForToolkit
        if (!$ffmpeg) { return }
    }

    $temp = Join-Path ([IO.Path]::GetTempPath()) (
        "ctr_final_{0}_{1}.ogg" -f $id, [Guid]::NewGuid().ToString("N")
    )

    try {
        $status.Text = "Creating $finalName at 1.12x..."
        [System.Windows.Forms.Application]::DoEvents()

        # atempo changes tempo while preserving pitch.
        $args = @(
            "-y",
            "-hide_banner",
            "-loglevel", "error",
            "-i", $source,
            "-filter:a", "atempo=1.12",
            "-c:a", "libvorbis",
            "-q:a", "6",
            $temp
        )

        # Native invocation keeps quoted paths intact (including spaces).
        & $ffmpeg @args 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            throw "FFmpeg exited with code $LASTEXITCODE."
        }

        if (!(Test-Path $temp -PathType Leaf) -or ((Get-Item $temp).Length -le 0)) {
            throw "FFmpeg did not produce a valid OGG."
        }

        $ok = 0
        foreach ($d in (MusicDirs)) {
            [IO.Directory]::CreateDirectory($d) | Out-Null
            $dest = Join-Path $d $finalName
            [IO.File]::Copy($temp, $dest, $true)

            if ((Test-Path $dest) -and ((Get-Item $dest).Length -gt 0)) {
                $ok++
            }
        }

        if ($ok -ne 1) {
            throw "Could not save $finalName in the game folder."
        }

        $status.Text = "Final Lap created: $finalName - 1.12x, pitch preserved."
        Show-Info (
            "Final Lap created successfully.`n`n" +
            "$finalName`n" +
            "Speed: 1.12x`n" +
            "Pitch: preserved"
        )
    }
    catch {
        Show-Error ("Could not create the Final Lap.`n`n" + $_.Exception.Message)
    }
    finally {
        if (Test-Path $temp) {
            Remove-Item $temp -Force -ErrorAction SilentlyContinue
        }
        Refresh-List
    }
}

function Remove-Selected {
    if ($pathBox.Text.Trim() -and $pathBox.Text.Trim() -ne $script:RootPath -and !(Apply-RootFromBox)) { return }
    if ($list.SelectedItems.Count -eq 0) {
        Show-Info "Select a track from the list."
        return
    }

    $row = $list.SelectedItems[0].Tag

    if (($row.Paths.Count -eq 0) -and !$row.HasFinal) {
        Show-Info "This Level ID has no custom music yet."
        return
    }

    $ans = [System.Windows.Forms.MessageBox]::Show(
        "Remove '$($row.File)'?`n`nThe track will use the original music again.",
        "CTR Music Toolkit",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    if ($ans -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    $musicDir = Join-Path $script:RootPath "assets\MUSIC_CUSTOM"
    $files = @($row.File)
    if ($row.ID -ne "") {
        $files += "level_{0:D2}_final.ogg" -f [int]$row.ID
    }
    foreach ($name in $files) {
        $p = Join-Path $musicDir $name
        if (Test-Path $p -PathType Leaf) { Remove-Item $p -Force }
    }

    Refresh-List
}

function Remove-AllMusic {
    if ($pathBox.Text.Trim() -and $pathBox.Text.Trim() -ne $script:RootPath -and !(Apply-RootFromBox)) { return }
    if ([string]::IsNullOrWhiteSpace($script:RootPath)) { return }

    $ans = [System.Windows.Forms.MessageBox]::Show(
        "Remove ALL custom OGG files?`n`nCTR will use the original music again.",
        "CTR Music Toolkit",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    )
    if ($ans -ne [System.Windows.Forms.DialogResult]::Yes) { return }

    foreach ($d in (MusicDirs)) {
        if (Test-Path $d) {
            Get-ChildItem $d -Filter *.ogg -File -ErrorAction SilentlyContinue | Remove-Item -Force
        }
    }

    Refresh-List
}

function Create-Backup {
    if ($pathBox.Text.Trim() -and $pathBox.Text.Trim() -ne $script:RootPath -and !(Apply-RootFromBox)) { return }
    if ([string]::IsNullOrWhiteSpace($script:RootPath)) {
        Pick-Root
        if ([string]::IsNullOrWhiteSpace($script:RootPath)) { return }
    }

    $stamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $dest = Join-Path $script:RootPath ("CTR_Music_Backup\" + $stamp)
    [IO.Directory]::CreateDirectory($dest) | Out-Null

    $src = Join-Path $script:RootPath "assets\MUSIC_CUSTOM"
    Ensure-MusicDirs
    Copy-Item $src (Join-Path $dest "MUSIC_CUSTOM") -Recurse -Force

    [IO.File]::WriteAllText(
        (Join-Path $dest "BACKUP_INFO.txt"),
        "CTR Music Toolkit Backup`r`nDate: $(Get-Date)`r`nCTR Native: $script:RootPath",
        [Text.Encoding]::UTF8
    )

    Show-Info "Backup created:`n$dest"
}

function Restore-Backup {
    if ($pathBox.Text.Trim() -and $pathBox.Text.Trim() -ne $script:RootPath -and !(Apply-RootFromBox)) { return }
    if ([string]::IsNullOrWhiteSpace($script:RootPath)) {
        Pick-Root
        if ([string]::IsNullOrWhiteSpace($script:RootPath)) { return }
    }

    $backupRoot = Join-Path $script:RootPath "CTR_Music_Backup"
    if (!(Test-Path $backupRoot)) {
        Show-Info "No backups were found in this folder."
        return
    }

    $dlg = New-Object System.Windows.Forms.FolderBrowserDialog
    $dlg.Description = "Select the backup to restore"
    $dlg.SelectedPath = $backupRoot

    if ($dlg.ShowDialog($form) -ne [System.Windows.Forms.DialogResult]::OK) { return }

    $b = $dlg.SelectedPath
    $src = Join-Path $b "MUSIC_CUSTOM"
    if (!(Test-Path $src -PathType Container)) {
        Show-Error "The selected backup has no MUSIC_CUSTOM folder."
        return
    }
    $dest = Join-Path $script:RootPath "assets\MUSIC_CUSTOM"
    if (Test-Path $dest) { Remove-Item $dest -Recurse -Force }
    [IO.Directory]::CreateDirectory((Split-Path $dest -Parent)) | Out-Null
    Copy-Item $src $dest -Recurse -Force

    Refresh-List
    Show-Info "Backup restored."
}

function Open-MusicFolder {
    if ($pathBox.Text.Trim() -and $pathBox.Text.Trim() -ne $script:RootPath -and !(Apply-RootFromBox)) { return }
    if ([string]::IsNullOrWhiteSpace($script:RootPath)) {
        Pick-Root
        if ([string]::IsNullOrWhiteSpace($script:RootPath)) { return }
    }

    Ensure-MusicDirs
    Start-Process explorer.exe (Join-Path $script:RootPath "assets\MUSIC_CUSTOM")
}

# ---------- UI ----------
$form = New-Object System.Windows.Forms.Form
$form.Text = "CTR Music Toolkit"
$form.StartPosition = "CenterScreen"
$form.MinimumSize = New-Object System.Drawing.Size(760,500)
$form.Size = New-Object System.Drawing.Size(980,650)
$form.BackColor = $C_BG
$form.ForeColor = $C_TEXT
$form.Font = New-Object System.Drawing.Font("Segoe UI",9)

# Header
$header = New-Object System.Windows.Forms.Panel
$header.Dock = "Top"
$header.Height = 104
$header.BackColor = $C_PANEL
$header.Padding = New-Object System.Windows.Forms.Padding(16,12,16,12)

$title = New-Object System.Windows.Forms.Label
$title.Text = "CTR Music Toolkit"
$title.Font = New-Object System.Drawing.Font("Segoe UI Semibold",17)
$title.ForeColor = $C_TEXT
$title.AutoSize = $true
$title.Location = New-Object System.Drawing.Point(16,12)

$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "Custom OGG music for compiled CTR Native"
$subtitle.Font = New-Object System.Drawing.Font("Segoe UI",9)
$subtitle.ForeColor = $C_MUTED
$subtitle.AutoSize = $true
$subtitle.Location = New-Object System.Drawing.Point(18,44)

$pathBox = New-Object System.Windows.Forms.TextBox
$pathBox.ReadOnly = $false
$pathBox.BackColor = [System.Drawing.Color]::FromArgb(245,245,245)
$pathBox.ForeColor = [System.Drawing.Color]::FromArgb(28,28,28)
$pathBox.Location = New-Object System.Drawing.Point(18,70)
$pathBox.Anchor = "Top,Left,Right"
$pathBox.Width = 805

function New-Button([string]$text, [int]$width, [System.Drawing.Color]$color) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $text
    $b.Size = New-Object System.Drawing.Size($width,34)
    $b.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $b.FlatAppearance.BorderSize = 1
    $b.FlatAppearance.BorderColor = $C_BORDER
    $b.BackColor = $color
    $b.ForeColor = $C_TEXT
    $b.Font = New-Object System.Drawing.Font("Segoe UI Semibold",9)
    $b.Cursor = [System.Windows.Forms.Cursors]::Hand
    return $b
}

$btnRoot = New-Button "Browse..." 100 $C_ACCENT
$btnRoot.Location = New-Object System.Drawing.Point(844,67)
$btnRoot.Anchor = "Top,Right"

$btnAbout = New-Button "About" 70 $C_PANEL2
$btnAbout.Size = New-Object System.Drawing.Size(70,26)
$btnAbout.Location = New-Object System.Drawing.Point(874,12)
$btnAbout.Anchor = "Top,Right"

$header.Controls.AddRange(@($title,$subtitle,$pathBox,$btnRoot,$btnAbout))

# Action bar
$actions = New-Object System.Windows.Forms.FlowLayoutPanel
$actions.Dock = "Top"
$actions.Height = 58
$actions.Padding = New-Object System.Windows.Forms.Padding(14,11,14,8)
$actions.BackColor = $C_BG
$actions.WrapContents = $false
$actions.AutoScroll = $true

$btnAdd = New-Button "Add / Replace" 155 $C_ACCENT
$btnFinal = New-Button "Create Final Lap" 130 $C_PANEL2
$btnRemove = New-Button "Remove Selected" 150 $C_PANEL2
$btnRemoveAll = New-Button "Remove All" 105 $C_DANGER
$btnBackup = New-Button "Backup" 90 $C_PANEL2
$btnRestore = New-Button "Restore" 100 $C_PANEL2
$btnFolder = New-Button "Open Folder" 115 $C_PANEL2

$actions.Controls.AddRange(@($btnAdd,$btnFinal,$btnRemove,$btnRemoveAll,$btnBackup,$btnRestore,$btnFolder))

# Main panel
$main = New-Object System.Windows.Forms.Panel
$main.Dock = "Fill"
$main.Padding = New-Object System.Windows.Forms.Padding(14,0,14,10)
$main.BackColor = $C_BG

$list = New-Object System.Windows.Forms.ListView
$list.Dock = "Fill"
$list.View = [System.Windows.Forms.View]::Details
$list.FullRowSelect = $true
$list.GridLines = $false
$list.HideSelection = $false
$list.BackColor = $C_PANEL
$list.ForeColor = $C_TEXT
$list.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$list.Font = New-Object System.Drawing.Font("Segoe UI",10)
$list.HeaderStyle = [System.Windows.Forms.ColumnHeaderStyle]::Nonclickable

[void]$list.Columns.Add("ID",70)
[void]$list.Columns.Add("Track",250)
[void]$list.Columns.Add("File",330)
[void]$list.Columns.Add("Status",110)

$main.Controls.Add($list)

$status = New-Object System.Windows.Forms.Label
$status.Dock = "Bottom"
$status.Height = 30
$status.Padding = New-Object System.Windows.Forms.Padding(14,6,10,0)
$status.BackColor = $C_PANEL
$status.ForeColor = $C_MUTED
$status.Text = "Select or enter the folder containing ctr_native.exe to begin."

$form.Controls.Add($main)
$form.Controls.Add($actions)
$form.Controls.Add($header)
$form.Controls.Add($status)

# Basic responsive layout
$form.Add_Resize({
    $pathBox.Width = [Math]::Max(260, $form.ClientSize.Width - 145)
    $btnRoot.Left = $form.ClientSize.Width - 118
    $btnAbout.Left = $form.ClientSize.Width - 86

    $available = [Math]::Max(400, $list.ClientSize.Width - 10)
    $list.Columns[0].Width = 70
    $list.Columns[3].Width = 110
    $remaining = $available - 180
    $list.Columns[1].Width = [Math]::Max(160, [int]($remaining * 0.38))
    $list.Columns[2].Width = [Math]::Max(200, $remaining - $list.Columns[1].Width)
})

$btnRoot.Add_Click({ Pick-Root })
$pathBox.Add_KeyDown({
    if ($_.KeyCode -eq [System.Windows.Forms.Keys]::Enter) {
        [void](Apply-RootFromBox)
        $_.SuppressKeyPress = $true
    }
})
$btnAbout.Add_Click({
    Show-Info "CTR Music Toolkit v1.0.7`n`nManage custom OGG tracks for CTR Native. Select a game folder or type its path and press Enter.`n`nThe 65 provided names are numbered in their original order from 0 to 64. OGG filenames use these decimal numbers.`n`nTrack ID findings: Discord @carisa15demon"
})
$btnAdd.Add_Click({ Add-Music })
$btnFinal.Add_Click({ Create-FinalLap })
$btnRemove.Add_Click({ Remove-Selected })
$btnRemoveAll.Add_Click({ Remove-AllMusic })
$btnBackup.Add_Click({ Create-Backup })
$btnRestore.Add_Click({ Restore-Backup })
$btnFolder.Add_Click({ Open-MusicFolder })
$list.Add_DoubleClick({
    if ($list.SelectedItems.Count -gt 0) {
        $row = $list.SelectedItems[0].Tag
        if ($row.ID -ne "") {
            Add-MusicForId ([int]$row.ID)
        }
    }
})

[void]$form.ShowDialog()
