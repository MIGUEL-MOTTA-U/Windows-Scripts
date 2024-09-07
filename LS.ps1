function Print-Menu {
    Write-Host @"
    Menu 1
    1. Ordenar por mas reciente.
    2. Ordenar por mas antiguo.
    3. Ordenar por tamano de mayor a menor.
    4. Ordenar por tamano de menor a mayor.
    5. Ordenar por tipo de archivo.
    6. Aplicar filtros de busqueda.
    7. Salir
"@
}

function Menu-Choice {
    $choice = Read-Host 'Elige una opcion'
    return $choice
}

function File-Choice {
    $choice = Read-Host 'Ingresa el directorio'
    return $choice
}

function Chain-Choice {
    $choice = Read-Host 'Ingresa la cadena para el filtro'
    return $choice
}

function Mostrar-Archivos($target, $recurse) {
    if ($recurse -eq "y") {
        return Get-ChildItem -Path $target -Recurse -Force
    } else {
        return Get-ChildItem -Path $target -Force
    }
}

function Ordenar-Archivos {
    param (
        [string]$target,
        [bool]$recurse = $false
    )

    while ($true) {
        Print-Menu
        $choice = Menu-Choice
        $files = Mostrar-Archivos $target $recurse

        switch ($choice) {
            '1' {
		Clear-Host
                $archivos_ordenados = $files | Where-Object { -not $_.PSIsContainer } | Sort-Object LastWriteTime -Descending
                Agrupar-Por-Fecha $archivos_ordenados
            }
            '2' {
		Clear-Host
                $archivos_ordenados = $files | Where-Object { -not $_.PSIsContainer } | Sort-Object LastWriteTime # Ascendente por defecto
                Agrupar-Por-Fecha $archivos_ordenados
            }
            '3' {
		Clear-Host
                $archivos_ordenados = $files | Where-Object { -not $_.PSIsContainer } | Sort-Object Length -Descending
                Agrupar-Por-Tamano $archivos_ordenados
            }
            '4' {
		Clear-Host
                $archivos_ordenados = $files | Where-Object { -not $_.PSIsContainer } | Sort-Object Length # Ascendente por defecto
                Agrupar-Por-Tamano $archivos_ordenados
            }
            '5' {
		Clear-Host
                $archivos_ordenados = $files | Sort-Object { $_.PSIsContainer }
                Agrupar-Por-Tipo $archivos_ordenados
            }
            '6' {
		Clear-Host
                Aplicar-Filtros $target $recurse
            }
            '7' {
		Clear-Host
                Write-Host "Saliendo..."
                exit
            }
            default {
		Clear-Host
                Write-Host "Opcion incorrecta, intenta nuevamente."
            }
        }
    }
}

function Agrupar-Por-Fecha($archivos) {
    $archivos | Group-Object LastWriteTime | ForEach-Object {
        Write-Host "Fecha: $($_.Name) - Archivos: $($_.Count)"
        $_.Group | ForEach-Object { Write-Host $_.FullName }
        Write-Host "------------------------"
    }
}

function Agrupar-Por-Tamano($archivos) {
    $archivos | Group-Object Length | ForEach-Object {
        Write-Host "Tamano: $($_.Name) bytes - Archivos: $($_.Count)"
        $_.Group | ForEach-Object { Write-Host $_.FullName }
        Write-Host "------------------------"
    }
}

function Agrupar-Por-Tipo($archivos) {
    $archivos | Group-Object { if ($_.PSIsContainer) { "Directorio" } else { "Archivo" } } | ForEach-Object {
        Write-Host "Tipo: $($_.Name) - Archivos: $($_.Count)"
        $_.Group | ForEach-Object { Write-Host $_.FullName }
        Write-Host "------------------------"
    }
}


function Aplicar-Filtros($target, $recurse) {
    while ($true) {
        Write-Host @"
        Filtros Disponibles:
        1. Buscar archivos que inicien con una cadena.
        2. Buscar archivos que terminen con una cadena.
        3. Buscar archivos que contengan una cadena.
        4. Volver al menu principal.
"@
        $choice = Menu-Choice
        $files = Mostrar-Archivos $target $recurse

        switch ($choice) {
            '1' {
		Clear-Host
                $inicio = Chain-Choice -Prompt "Ingresa la cadena de inicio"
                $filtrados = $files | Where-Object { $_.Name -like "$inicio*" }
                Mostrar-Files-Filtrados $filtrados
            }
            '2' {
		Clear-Host
                $fin = Chain-Choice -Prompt "Ingresa la cadena de fin"
                $filtrados = $files | Where-Object { $_.Name -like "*$fin" }
                Mostrar-Files-Filtrados $filtrados
            }
            '3' {
		Clear-Host
                $contiene = Chain-Choice -Prompt "Ingresa la cadena contenida"
                $filtrados = $files | Where-Object { $_.Name -like "*$contiene*" }
                Mostrar-Files-Filtrados $filtrados
            }
            '4' {
		Clear-Host
                return 
            }
            default {
		Clear-Host
                Write-Host "Opcion incorrecta, intenta nuevamente."
            }
        }
    }
}

function Mostrar-Files-Filtrados($filtrados) {
    if ($filtrados) {
        $filtrados | ForEach-Object { Write-Host $_.FullName }
    } else {
        Write-Host "No se encontraron archivos que coincidan con los filtros."
    }
}



# Main script
$target = File-Choice
$recurse = Read-Host "Incluir subdirectorios? (y/n)"
Ordenar-Archivos -target $target -recurse ($recurse -eq "y")
