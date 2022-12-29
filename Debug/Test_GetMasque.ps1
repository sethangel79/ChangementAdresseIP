function Get-Masque {
    param (
         [string]$adressesIP
    )
    Write-Debug "Adresse IP parametre : $adressesIP"

    $tab = $adressesIP -split "\."
    foreach ($elt in $tab) {
        Write-Debug $elt
    }

    $premierNombre = [int]$tab[0]
    Write-Debug $premierNombre
    
    if (($premierNombre -ge 0) -and ($premierNombre -le 126)) {
         return 8
    } elseif ($premierNombre -ge 128 -and $premierNombre -le 191) {
         return 16
    } else {
         return 24
    }
}

$DebugPreference = "continue"

$masque1 = Get-Masque -adressesIP "10.0.0.0"
Write-Host $masque1

$masque3 = Get-Masque -adressesIP "172.10.0.1"
Write-Host $masque3 

$masque2 = Get-Masque -adressesIP "192.168.0.1"
Write-Host $masque2 