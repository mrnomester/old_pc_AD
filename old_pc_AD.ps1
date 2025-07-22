# Функция для проверки прав администратора
function Test-IsAdmin {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Проверяем, запущен ли скрипт с правами администратора
if (-not (Test-IsAdmin)) {
    Write-Host "Скрипт не запущен с правами администратора. Перезапускаем с повышенными правами..."
    
    # Получаем полный путь к текущему скрипту
    $scriptPath = $MyInvocation.MyCommand.Definition
    
    # Запускаем скрипт с повышенными правами
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# Порог неактивности в днях
$daysInactive = 180
$timeLimit = (Get-Date).AddDays(-$daysInactive)  # Получаем настоящий DateTime

# Преобразуем в формат FileTime
$fileTimeLimit = $timeLimit.ToFileTime()

# Получаем список компьютеров и фильтруем
Get-ADComputer -Filter * -Properties LastLogonTimeStamp |
    Where-Object { $_.LastLogonTimeStamp -lt $fileTimeLimit } |
    Select-Object Name,
        OperatingSystem,
        @{Name="LastLogon";Expression={[DateTime]::FromFileTime($_.LastLogonTimeStamp).ToString("yyyy-MM-dd HH:mm")}} |
    Sort-Object LastLogon -Descending |
    Format-Table -AutoSize

# Ожидание нажатия Enter перед закрытием
Read-Host "`nНажмите Enter для выхода..."