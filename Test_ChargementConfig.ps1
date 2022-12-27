$NomConnexion = "Ethernet 2"
$configuration = [System.Collections.ArrayList]@()

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

# .SYNOPSIS
# Fonction de test d'une entrée du fichier de configuration
#
# .DESCRIPTION
# Limit-Configuration réalise different tests afin de vérifier que l'entrée peut être traitée par le script.
# La fonction attend une chaîne de caractère du type "index;nom;adresseIP;masque;passerelle;serveurDns" avec :
# - index : entier réprésentant l'index qui sera à taper pour sélectionner l'adresse IP
# - nom : description de l'adresse
# - adresseIP : 0 ou adresse IP valide. Si 0, paramétrage du DHCP
# - masque : entier représentant le masque de sous réseau (8 pour 255.0.0.0, 16 pour 255.255.0.0, 24 pour 255.255.255.0)
# - passerelle : 0 ou adresse IP valide. Si 0, auncune passerelle n'est indiquée.
# - serveurDNS : 0 ou adresse IP valide. Si 0, aucun serveur DNS paramétré.
#
# .PARAMETER ligne
# ligne représente une ligne du fichier de configuration
# La fonction attend une chaîne de caractère du type "index;nom;adresseIP;masque;passerelle;serveurDns" avec :
# - index : entier réprésentant l'index qui sera à taper pour sélectionner l'adresse IP
# - nom : description de l'adresse
# - adresseIP : 0 ou adresse IP valide. Si 0, paramétrage du DHCP
# - masque : entier représentant le masque de sous réseau (8 pour 255.0.0.0, 16 pour 255.255.0.0, 24 pour 255.255.255.0)
# - passerelle : 0 ou adresse IP valide. Si 0, auncune passerelle n'est indiquée.
# - serveurDNS : 0 ou adresse IP valide. Si 0, aucun serveur DNS paramétré.
#
# .EXAMPLE
# Limit-Configuration -ligne "0;DHCP;0;24;0;0"
# 
# .EXAMPLE
# Limit-Configuration -ligne "1;Alarme;192.168.1.110;24;0;0"
#
# .EXAMPLE
# Limit-Configuration -ligne "2;Fixe;192.168.1.237;24;192.168.1.1;192.168.1.1"
#
# .NOTES
# Aucune remarque complémentaire
#
# .LINK
# Voir lien github pour dernière version
function Limit-Configuration {
    param (
        [string]$ligne
    )
    #"0;DHCP;0;24;0;0"
    $Erreur = $false
    $Description = ""

    Write-Debug "Analyse de : $ligne"
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

# .SYNOPSIS
# Lit un fichier de configuration
#
# .DESCRIPTION
# Get-Config lit un fichier de configuration et met à jour les deux variables suivantes : 
# - $NomConnexion
# - $configuration = [System.Collections.ArrayList]@()
# 
#   $NomConnexion prend l'entrée du fichier débutant par "NomConnexion=". Nom Connexion doit correspondre à un nom de carte réseau dans le PC.
#   $configuration prend les entrées débutant par "IP=" et ayant la forme suivante :"index;nom;adresseIP;masque;passerelle;serveurDns" avec :
# - index : entier réprésentant l'index qui sera à taper pour sélectionner l'adresse IP
# - nom : description de l'adresse
# - adresseIP : 0 ou adresse IP valide. Si 0, paramétrage du DHCP
# - masque : entier représentant le masque de sous réseau (8 pour 255.0.0.0, 16 pour 255.255.0.0, 24 pour 255.255.255.0)
# - passerelle : 0 ou adresse IP valide. Si 0, auncune passerelle n'est indiquée.
# - serveurDNS : 0 ou adresse IP valide. Si 0, aucun serveur DNS paramétré.
#
# .PARAMETER ligne
# ligne représente une ligne du fichier de configuration
# La fonction attend une chaîne de caractère du type "index;nom;adresseIP;masque;passerelle;serveurDns" avec :
# - index : entier réprésentant l'index qui sera à taper pour sélectionner l'adresse IP
# - nom : description de l'adresse
# - adresseIP : 0 ou adresse IP valide. Si 0, paramétrage du DHCP
# - masque : entier représentant le masque de sous réseau (8 pour 255.0.0.0, 16 pour 255.255.0.0, 24 pour 255.255.255.0)
# - passerelle : 0 ou adresse IP valide. Si 0, auncune passerelle n'est indiquée.
# - serveurDNS : 0 ou adresse IP valide. Si 0, aucun serveur DNS paramétré.
#
function Get-Config {

    [CmdletBinding()] #<<-- This turns a regular function into an advanced function

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
                    $configuration.Add($Tableau[1])
                }
            }
        } catch {
            Write-Host $Ligne "n''a pas le format attendu"
        }
    }

    Write-Debug "NomConnexion = $NomConnexion"
    foreach ($elt in $configuration) {
        Write-Debug $elt
    }
    #Write-Host $configuration[1]
}

#Programme
Get-Config