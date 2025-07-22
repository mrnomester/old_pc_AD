# ������� ��� �������� ���� ��������������
function Test-IsAdmin {
    $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object System.Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ���������, ������� �� ������ � ������� ��������������
if (-not (Test-IsAdmin)) {
    Write-Host "������ �� ������� � ������� ��������������. ������������� � ����������� �������..."
    
    # �������� ������ ���� � �������� �������
    $scriptPath = $MyInvocation.MyCommand.Definition
    
    # ��������� ������ � ����������� �������
    Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# ����� ������������ � ����
$daysInactive = 180
$timeLimit = (Get-Date).AddDays(-$daysInactive)  # �������� ��������� DateTime

# ����������� � ������ FileTime
$fileTimeLimit = $timeLimit.ToFileTime()

# �������� ������ ����������� � ���������
Get-ADComputer -Filter * -Properties LastLogonTimeStamp |
    Where-Object { $_.LastLogonTimeStamp -lt $fileTimeLimit } |
    Select-Object Name,
        OperatingSystem,
        @{Name="LastLogon";Expression={[DateTime]::FromFileTime($_.LastLogonTimeStamp).ToString("yyyy-MM-dd HH:mm")}} |
    Sort-Object LastLogon -Descending |
    Format-Table -AutoSize

# �������� ������� Enter ����� ���������
Read-Host "`n������� Enter ��� ������..."