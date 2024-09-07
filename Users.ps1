# Este script debe ejecutarse con privilegios de administrador

# Función para crear un nuevo usuario
function New-CustomUser {
    param(
        [string]$nombre,
        [string]$grupo,
        [string]$descripcion,
        [string]$directorio,
        [string]$shell,
        [string]$perm_usuario,
        [string]$perm_grupo,
        [string]$perm_otros
    )

    # Crear el usuario
    $securePassword = ConvertTo-SecureString "PasswordTemporal123!" -AsPlainText -Force
    New-LocalUser -Name $nombre -Password $securePassword -Description $descripcion -UserMayNotChangePassword $false -PasswordNeverExpires $false

    # Agregar el usuario al grupo
    Add-LocalGroupMember -Group $grupo -Member $nombre

    # Crear el directorio de inicio si no existe
    if (-not (Test-Path $directorio)) {
        New-Item -Path $directorio -ItemType Directory
    }

    # Establecer los permisos del directorio
    $acl = Get-Acl $directorio
    $permisos = "$perm_usuario$perm_grupo$perm_otros"
    $acl.SetAccessRuleProtection($true, $false)
    $regla = New-Object System.Security.AccessControl.FileSystemAccessRule($nombre, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow")
    $acl.AddAccessRule($regla)
    Set-Acl $directorio $acl

    Write-Host "Usuario $nombre creado exitosamente"
}

# Función para crear un nuevo grupo
function New-CustomGroup {
    param(
        [string]$nombre_grupo,
        [int]$id_grupo
    )

    # Crear el grupo
    New-LocalGroup -Name $nombre_grupo
    Write-Host "Grupo $nombre_grupo creado exitosamente"
}

# Procesar los argumentos y verificar si es "newuser" o "newgroup"
if ($args.Count -eq 0) {
    Write-Host "Opción Inválida"
    Write-Host @"
Ejemplo de USO:
.\Users.ps1 newuser juan ti "Juan Pablo" C:\Users\juan C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe 7 5 5
.\Users.ps1 newgroup desarrolladores 1001
"@
    exit 1
}

switch ($args[0]) {
    "newuser" {
        if ($args.Count -ne 9) {
            Write-Host "Número incorrecto de argumentos para newuser"
            exit 1
        }
        New-CustomUser $args[1] $args[2] $args[3] $args[4] $args[5] $args[6] $args[7] $args[8]
    }
    "newgroup" {
        if ($args.Count -ne 3) {
            Write-Host "Numero incorrecto de argumentos para newgroup"
            exit 1
        }
        New-CustomGroup $args[1] $args[2]
    }
    default {
        Write-Host "Opción Invalida"
        exit 1
    }
}