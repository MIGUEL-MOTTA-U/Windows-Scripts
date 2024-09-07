function Print-Menu {
    Write-Host @"
    Menu de Grep Powered
    1. Busqueda directorio / archivo dado el nombre.
    2. Busqueda de palabra en un archivo.
    3. Busqueda de archivo y palabra.
    4. Contar lineas de archivo.
    5. Mostrar las primeras n lineas de un archivo dado.
    6. Mostrar las ultimas n lineas de un archivo dado.
    7. Salir
"@
}

function Menu-Choice {
    $choice = Read-Host 'Eleccion'
    return $choice
}

function Word-Choice {
    $choice = Read-Host 'Palabra'
    return $choice
}

function File-Choice {
    $choice = Read-Host 'Archivo'
    return $choice
}

function Line-Choice {
    $choice = Read-Host 'Lineas'
    return $choice
}


function Buscar-Palabra-En-Archivos {
    param (
        [string]$target,
        [string]$patron_archivo,
        [string]$palabra_buscar
    )

    $total_global = 0

    Get-ChildItem -Path $target -Filter "*$patron_archivo*" -Recurse -File | ForEach-Object {
        $archivo = $_.FullName
        $resultados = Select-String -Path $archivo -Pattern $palabra_buscar
        $cuenta = $resultados.Count
        
        if ($cuenta -gt 0) {
            Write-Host "Archivo encontrado: $archivo"
            Write-Host "Total de ocurrencias en este archivo: $cuenta"
            Write-Host "------------------------"
            $total_global += $cuenta
        }
    }

    Write-Host "Total de ocurrencias en todos los archivos: $total_global"
    return $total_global
}

# Define the Main function with a parameter for the target directory
function Main {
    param (
        [string]$target
    )

    while ($true) {
        Print-Menu
        $choice = Menu-Choice
        switch ($choice) {
            '1' {
                $word = Word-Choice
                $results = Get-ChildItem -Path $target -Recurse -File | Where-Object { $_.Name -match $word } | Select-Object FullName
	        if ($results) {
	   	   	$results | ForEach-Object { $_.FullName }
		} else {
		    Write-Host "No matching files found."
		}

            }
            '2' {
	    $word = Word-Choice
	    Write-Host "------------------------"
	    Write-Host "Archivos en directorio $target :"
	    $results = Get-ChildItem -Path $target -File | Select-Object FullName
		if ($results) {
	   	   	$results | ForEach-Object { $_.FullName }
		} else {
		    Write-Host "No matching files found."
		}
	    Write-Host "------------------------"
	    $file = File-Choice
	    $fullPath = Join-Path -Path $target -ChildPath $file
	    $results = Select-String -Path $fullPath -Pattern $word
	    foreach ($result in $results) {
	        Write-Host $result.LineNumber ": " $result.Line
		    }
		}
            '3' {
                $word = Word-Choice
                $file = File-Choice
                Buscar-Palabra-En-Archivos -target $target -patron_archivo $file -palabra_buscar $word
            }
            '4' {
		Write-Host "------------------------"
                Write-Host "Archivos en directorio $target :"
                $output4 = Get-ChildItem -Path $target -File | Select-Object Name
		foreach ($line_4 in $output4){
			Write-Host $line_4.Name
		}
                Write-Host "------------------------"
                $file = File-Choice
		$fullPath = Join-Path -Path $target -ChildPath $file
                (Get-Content $fullPath).Count
            }
            '5' {
		Write-Host "------------------------"
                Write-Host "Archivos en directorio $target :"
                $output5 = Get-ChildItem -Path $target -File | Select-Object Name
		foreach ($line_5 in $output5) {
			Write-Host $line_5.Name
		}
                Write-Host "------------------------"
                $file = File-Choice
		$fullPath = Join-Path -Path $target -ChildPath $file
                $lines = Line-Choice
                Get-Content $fullPath | Select-Object -First $lines
            }
            '6' {
		Write-Host "------------------------"
                Write-Host "Archivos en directorio $target :"
                $output6 = Get-ChildItem -Path $target -File | Select-Object Name
		foreach ($line_6 in $output6){
			Write-Host $line_6.Name
		}
                Write-Host "------------------------"
                $file = File-Choice
		$fullPath = Join-Path -Path $target -ChildPath $file
                $lines = Line-Choice
                Get-Content $fullPath | Select-Object -Last $lines
            }
            '7' {
		Write-Host "Saliendo..."
                exit
            }
            default {
                Write-Host "Opcion Incorrecta"
            }
        }
    }

    Clear-Host
    Write-Host "Fin del Programa"
}

# This checks if the script is being run directly and not being dot-sourced
Main -target $args[0]