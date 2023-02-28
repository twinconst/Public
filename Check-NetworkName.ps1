<#
Author: Siarhei Trukhan
Version: 1.0.0

Purpose: Реализовать функцию. Требования: Проверить имя компьютера на существование в AD и вывести в Verbose сообщение о начатой проверке. Если компьютер не найден, остановить выполнение.
Реализация: Получить список процессов с указанных на входе компьютерах и сформировать json в котором будет содержаться Name, Id и путь к исполняемому файлу процесса.
#>

#requires -Version 3.0 -Module ActiveDirectory

function Check-NetworkName
{
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [String[]]$DeviceName
    )
    Begin {
        $Domain = (Get-ADForest).RootDomain
    }
    Process {
        foreach ($NetworkName in $DeviceName)
        {
            Write-Verbose -Message "Search for the '$NetworkName' computer in the AD"

            try
            {
                Get-ADComputer -Identity $NetworkName -Server $Domain -ErrorAction Stop
            }
            catch
            {
                continue
            }
        }
    }
}

# Check-NetworkName -DeviceName 'comp1', 'comp2' -Verbose

$ComputesFromAD = 'comp1', 'comp2' | Check-NetworkName -Verbose

foreach ($ADCompute in $ComputesFromAD)
{
    $Processes = Get-Process -ComputerName $ADCompute

    foreach ($Process in $Processes)
    {
        [PSCustomObject]@{
            Name = $Process.Name
            Id = $Process.Id
            Path = $Process.Path
        } |
        ConvertTo-Json
    }
}