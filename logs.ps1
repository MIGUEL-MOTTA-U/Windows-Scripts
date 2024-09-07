function Print-Menu {
    Write-Host "Menu de LOGS"
    Write-Host "1. Listar 15 líneas"
    Write-Host "2. Listar y buscar palabra"
    Write-Host "3. Salir"
}

while ($true) {
    Print-Menu
    $choise = Read-Host "---->"
    Write-Host ""

    switch ($choise) {
        '1' {
            # Mostramos las últimas 15 líneas de los logs de Sistema, Aplicación y Seguridad
            Write-Host "System"
	    Get-EventLog -LogName System -Newest 15
	    Write-Host ""
            Write-Host "Application"
            Get-EventLog -LogName Application -Newest 15
	    Write-Host ""
            Write-Host "Security"
            Get-EventLog -LogName Security -Newest 15
        }
        '2' {
            $word = Read-Host "Palabra"
            Write-Host "Buscando '$word' en los logs..."
            Get-EventLog -LogName System -Newest 15 | Where-Object { $_.Message -match $word }
            Get-EventLog -LogName Application -Newest 15 | Where-Object { $_.Message -match $word }
            Get-EventLog -LogName Security -Newest 15 | Where-Object { $_.Message -match $word }
        }
        '3' {
            exit
        }
        default {
            Write-Host ""
            Write-Host "Incorrecto"
        }
    }

    Write-Host ""
    $tmp = Read-Host "Da enter para limpiar"
    Clear-Host
}
