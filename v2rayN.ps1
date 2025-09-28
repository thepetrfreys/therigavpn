# ==============================
# Эта хуйня навайбкожена специально для упрощения работы с v2rayN
# Нахуя ты вообще это читаешь?
# ==============================

function Get-Version {
    $confPath = "$env:LOCALAPPDATA\Programs\v2rayN\theriga.conf"
    if (Test-Path $confPath) {
        try {
            return (Get-Content $confPath -Raw).Trim()
        } catch {
            return "Ошибка чтения версии"
        }
    } else {
        return "Клиент не установлен"
    }
}

function Show-MainMenu {
    Clear-Host
    $version = Get-Version
    Write-Host "===== Меню управления v2rayN =====" -ForegroundColor Cyan
    Write-Host "Версия клиента: $version" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Установка v2rayN"
    Write-Host "2. Настройка автозапуска"
    Write-Host "3. Удаление v2rayN"
    Write-Host "4. Выход"
    $choice = Read-Host "Выберите вариант (1-4)"
    switch ($choice) {
        "1" { Install-v2rayN }
        "2" { Autostart-Menu }
        "3" { Remove-v2rayN }
        "4" { exit }
        default { Show-MainMenu }
    }
}

function Install-v2rayN {
    $installDir = "$env:LOCALAPPDATA\Programs\v2rayN"
    if (Test-Path $installDir) {
        Write-Host "Уже установлено. Удалите старую версию перед установкой." -ForegroundColor Red
        Pause
        Show-MainMenu
        return
    }

    $url = "https://therigavpn.lv:1337/v2rayN-TheRigaVPN-windows-64-v2-1.zip"
    $zipPath = "$env:TEMP\v2rayN.zip"

    Write-Host "Скачивание клиента..."
    Invoke-WebRequest -Uri $url -OutFile $zipPath

    Write-Host "Распаковка..."
    Expand-Archive -Path $zipPath -DestinationPath $installDir

    # Создание ярлыка
    $shortcutPath = "$env:USERPROFILE\Desktop\v2rayN.lnk"
    $targetPath = "$installDir\run_v2rayn.exe"
    $WScriptShell = New-Object -ComObject WScript.Shell
    $Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $Shortcut.TargetPath = $targetPath
    $Shortcut.WorkingDirectory = $installDir
    $Shortcut.Save()

    Write-Host "Установка завершена!" -ForegroundColor Green
    Pause
    Show-MainMenu
}

function Autostart-Menu {
    $guiConfigPath = "$env:LOCALAPPDATA\Programs\v2rayN\guiConfigs\guiNConfig.json"
    if (-not (Test-Path $guiConfigPath)) {
        Write-Host "Конфиг guiNConfig.json не найден. Установите клиент v2rayN." -ForegroundColor Red
        Pause
        Show-MainMenu
        return
    }

    # Проверка состояния автозапуска
    $task = schtasks /Query /TN "v2rayN_Autostart" /FO LIST /V 2>$null
    $autostartEnabled = $task -match "v2rayN_Autostart"

    Clear-Host
    Write-Host "===== Настройка автозапуска v2rayN =====" -ForegroundColor Cyan
    if ($autostartEnabled) {
        Write-Host "Текущее состояние: Включен" -ForegroundColor Green
    } else {
        Write-Host "Текущее состояние: Выключен" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "1. Включить автозапуск"
    Write-Host "2. Отключить автозапуск"
    Write-Host "3. Назад в главное меню"

    $subchoice = Read-Host "Выберите вариант (1-3)"
    switch ($subchoice) {
        "1" { Enable-Autostart }
        "2" { Disable-Autostart }
        "3" { Show-MainMenu }
        default { Autostart-Menu }
    }
}

function Enable-Autostart {
    $guiConfigPath = "$env:LOCALAPPDATA\Programs\v2rayN\guiConfigs\guiNConfig.json"
    try {
        $json = Get-Content $guiConfigPath -Raw | ConvertFrom-Json
        $json.UiItem.AutoHideStartup = $true
        $json | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 $guiConfigPath
        Write-Host "AutoHideStartup включен." -ForegroundColor Green
    } catch {
        Write-Warning "Не удалось изменить AutoHideStartup: $_"
    }

    $exePath = "$env:LOCALAPPDATA\Programs\v2rayN\v2rayN.exe"
    schtasks /Create /TN "v2rayN_Autostart" /TR "`"$exePath`"" /SC ONLOGON /RL HIGHEST /F /RU $env:USERNAME | Out-Null
    Write-Host "Задача автозапуска создана." -ForegroundColor Green
    Pause
    Show-MainMenu
}

function Disable-Autostart {
    $guiConfigPath = "$env:LOCALAPPDATA\Programs\v2rayN\guiConfigs\guiNConfig.json"
    if (Test-Path $guiConfigPath) {
        try {
            $json = Get-Content $guiConfigPath -Raw | ConvertFrom-Json
            $json.UiItem.AutoHideStartup = $false
            $json | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 $guiConfigPath
            Write-Host "AutoHideStartup отключен." -ForegroundColor Yellow
        } catch {
            Write-Warning "Не удалось изменить AutoHideStartup: $_"
        }
    }

    schtasks /Delete /TN "v2rayN_Autostart" /F 2>$null | Out-Null
    Write-Host "Задача автозапуска удалена." -ForegroundColor Yellow
    Pause
    Show-MainMenu
}

function Remove-v2rayN {
    $installDir = "$env:LOCALAPPDATA\Programs\v2rayN"
    if (-not (Test-Path $installDir)) {
        Write-Host "v2rayN не установлен." -ForegroundColor Red
        Pause
        Show-MainMenu
        return
    }

    $confirm = Read-Host "Вы уверены, что хотите удалить v2rayN? (y/n)"
    if ($confirm -ne "y") {
        Show-MainMenu
        return
    }

    # Проверка запущен ли процесс
    if (Get-Process "v2rayN" -ErrorAction SilentlyContinue) {
        Write-Host "Закройте клиент v2rayN перед удалением." -ForegroundColor Red
        Pause
        Show-MainMenu
        return
    }

    # Удаление директории
    Remove-Item $installDir -Recurse -Force

    # Удаление ярлыка
    $desktopShortcut = "$env:USERPROFILE\Desktop\v2rayN.lnk"
    if (Test-Path $desktopShortcut) {
        Remove-Item $desktopShortcut -Force
        Write-Host "Ярлык v2rayN удалён." -ForegroundColor Yellow
    }

    # Удаление задачи автозапуска
    schtasks /Delete /TN "v2rayN_Autostart" /F 2>$null | Out-Null

    Write-Host "v2rayN успешно удалён." -ForegroundColor Green
    Pause
    Show-MainMenu
}

# ===== Старт =====
Show-MainMenu