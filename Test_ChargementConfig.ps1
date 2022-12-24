$NomConnexion = "Ethernet 2"
$configuration = @()

#Pour test
function Limit-AdresseIP {
    param (
         [string]$adresseIP
    )

    $Erreur = $FALSE
    $tab = $adressesIP -split "."
    if ($tab.count -eq 4) {
         foreach ($elt in $tab) {
              try {
              $chiffre = [int]$elt
              if ($chiffre -lt 0 -or $chiffre -gt 255) {
                   $Erreur = $TRUE
              }
              } catch {
                   $Erreur = $TRUE
              }

         }
    }

    if ($Erreur -eq $TRUE) {
         throw $adressesIP + " n''a pas le format d'une adresse IP"
    }
}

function Limit-Masque {
    param (
         [int]$masque
    )

    if ($masque -lt 0 -or $masque -gt 32) {
         throw $masque + " n''est pas dans une plage valide"
    }
}

function Limit-Chaine {
    param (
         [string]$chaine
    )

    $NBChar = 40
    if ($chaine.count -gt $NBChar) {
         throw $chaine + " est trop long : limité à " + $NBChar
    }
}

#Fin des fonctions utilisée pour le test




function Limit-Configuration {
    param (
        [string]$ligne
    )
    #"0,DHCP,0,24,0,0"
    $Erreur = $false
    $Description = ""

    Write-Host "Analyse de :" $ligne
    $Tableau = $ligne -split ";"
    try {
        #Write-Host $Tableau.Length " - " $Tableau

        if ($Tableau.Length -eq 6) {
            #Write-Host $Tableau[0]
            $index = [int]$Tableau[0]
            
            #Write-Host $Tableau[1]
            Limit-Chaine -chaine $Tableau[1]

            #Write-Host $Tableau[2]
            if ($Tableau[2] -ne "0") {
                Limit-AdresseIP -adresseIP $Tableau[2]
            }

            #Write-Host $Tableau[3]
            Limit-Masque -masque $Tableau[3]

            #Write-Host $Tableau[4]
            if ($Tableau[4] -ne "0") {
                Limit-AdresseIP -adresseIP $Tableau[4]
            }

            #Write-Host $Tableau[5]
            if ($Tableau[5] -ne "0") {
                Limit-AdresseIP -adresseIP $Tableau[5]
            }            
        } else {
            $Erreur = $True 
        }
    } catch {
        $Erreur = $True
        $Description = $_
    }

    if ($Erreur -eq $TRUE) {
        throw $ligne + " n''est pas conforme à l'attendu :" + $Description
   }
}

function Get-Config {
    $NumberOfLinesMax = 200

    $Conf = Get-Content -Path .\ListeAdressesIP.conf -TotalCount $NumberOfLinesMax

    foreach ($Ligne in $Conf) {
        try {
            if ($Ligne.StartsWith("NomConnexion")) {
                $Tableau = $Ligne -split "="
                if ($Tableau.length -eq 2) {
                    $NomConnexion = $Tableau[1]
                }
            }
            if ($Ligne.StartsWith("IP")) {
                $Tableau = $Ligne -split "="
                if ($Tableau.length -eq 2) {
                    Limit-Configuration -ligne $Tableau[1]
                    $configuration += $Tableau[1]
                }
            }
        } catch {
            Write-Host $Ligne "n''a pas le format attendu"
        }
    }

    Write-Host "$NomConnexion = " $NomConnexion
    foreach ($elt in $configuration) {
        Write-Host $elt
    }
}

#Programme
Get-Config