#############################################################
#                                                           #
#    Script de changement d'adresse IP avec présélection    #
#                                                           #
#    Lancer le script avec powershell et choisissez         #
#    l'adresse IP à définir pour la carte réseau            #
#                                                           #
#    Date de création : 17/12/2022                          #
#    Auteur : Github : sethangel79                          #
#                                                           #
#############################################################    

######## Initialisation #####################################
$Global:Configuration = [System.Collections.ArrayList]@()
$Global:adressesIP = [System.Collections.ArrayList]@()
$Global:NomConnexion = [String]@()

######## Paramétrage ########################################

#Numéro à sélectionner, Nom connexion à sélectionner, adresse IP, masque de sous-réseau ("24" pour 255.255.255.0, "16" pour 255.255.0, "8" pour 255.0.0), adresse passerelle, adresse serveur DNS
#Si 0 utilisation de l'adresse par défaut
#$Configuration.Add("0,DHCP,0,24,0,0")
#$Configuration.Add("1,Alarme,192.168.1.110,24,0,0")
#$Configuration.Add("2,Fixe,192.168.1.237,24,192.168.1.1,192.168.1.1")

#Indiquer entre guillemet le nom de la carte réseau à modifier "Wi-Fi" ou "Ethernet 2" par exemple à chercher dans Panneau de Configuration\Réseau et Internet\Connexions réseau
#$Global:NomConnexion = "Wi-Fi" 
#$Global:NomConnexion = "Ethernet 2" 

######## Programmation ######################################


######## Fonctions ##########################################

# .SYNOPSIS
# Vérifie que la chaîne de caractère passée en paramètre à bien la forme d'une adresse IP
#
# .DESCRIPTION
# Recherche si nous avons bien quatre nombres compris entre 0 et 255 séparés par des points
# Une exception est levée si la chaîne n'est pas une adresse IP
#
# .PARAMETER adresseIP
# Chaîne de caractère représentant une adresse IP
#
# .EXAMPLE
# Limite-AdresseIP - adresseIP "192.168.1.10"
#
# .NOTES
# A refaire avec une expression régulière pour que cela soit plus propre
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

# .SYNOPSIS
# Vérifie que le masque passé en paramètre est bien compris entre [0;32]
#
# .DESCRIPTION
# Lève une exception le masque de sous réseau n'est pas dans les bornes autorisées
#
# .PARAMETER masque
# Entier à tester
#
# .EXAMPLE
# LImite-Masque -masque 24
function Limit-Masque {
     param (
          [int]$masque
     )

     if ($masque -lt 0 -or $masque -gt 32) {
          throw $masque + " n''est pas dans une plage valide"
     }
}

# .SYNOPSIS
# Lève une exception si la longueur de la chaîne de caractère passée en paramètre dépasse 40 caractères
#
# .DESCRIPTION
# Lève une exception si la longueur de la chaîne de caractère passée en paramètre dépasse 40 caractères
#
# .PARAMETER chaine
# Chaîne de caractère dont la longueur doit être testée
#
# .EXAMPLE
# LImite-Chaine "Ma chaîne de caractères"
function Limit-Chaine {
     param (
          [string]$chaine
     )

     $NBChar = 40
     if ($chaine.count -gt $NBChar) {
          throw $chaine + " est trop long : limité à " + $NBChar
     }
}

# .SYNOPSIS
# Recherche la classe d'appartenance de l'adresse IP passée an paramètre
#
# .DESCRIPTION
# Get-Masque renvoie un entier (8, 16, 24) correspondant à la classe d'adresse IP de l'adresse IP privée passée en paramètre
# Renvoie 24 (255.255.255.0) par défaut
#
# .PARAMETER adresseIP
# Chaîne de caractère représentant une adresse IP privée
#
# .EXAMPLE
# Get-masque -AdresseIP "192.168.1.10"
#
# .NOTES
# Renvoie :
# - 8 pour IP [0.0.0.0; 126.255.255.255]
# - 16 pour IP [128.0.0.0; 191.255.255.255]
# - 24 pour les autres cas
function Get-Masque {
     param (
          [string]$adressesIP
     )
     $tab = $adressesIP -split "."
     $premierNombre = [int]$tab[0]
     if ($premierNombre -ge 0 -and $premierNombre -le 126) {
          return 8
     } elseif ($premierNombre -ge 128 -and $premierNombre -le 191) {
          return 16
     } else {
          return 24
     }
}

# .SYNOPSIS
# Fonction de test d'une entrée du fichier de Configuration
#
# .DESCRIPTION
# Get-AdressesIP crée à partir de la variables $Configuration des objets de type myAdresse et les ajoute au tableau de myAdresse $adresseIP
# myAdresse : $myAdresse = [PSCustomObject]@{
#     index : int
#     nom : string
#     adresseIP : adresse IP ou 0
#     masque : int < 32
#     passerelle : adresse IP ou 0
#     serveurDNS : adresse IP ou 0
function Get-AdressesIP {
     foreach ($elem in $Configuration) {
          $tab = $elem -split ";"

          #Write-Host $tab.count
          #Si la chaine est coorecte
          if ($tab.count -eq 6) {
               write-host $tab[0] "-" $tab[1] "-" $tab[2] "-" $tab[3] "-" $tab[4] "-" $tab[5]
               try {
                    #Test
                    Limit-Chaine -chaine $tab[1]
                    Limit-AdresseIP -AdresseIP $tab[2]
                    Limit-Masque -masque $tab[3]
                    Limit-AdresseIP -AdresseIP $tab[4]
                    Limit-AdresseIP -AdresseIP $tab[5]

                    $myAdresse = [PSCustomObject]@{
                         index = [int]$tab[0]
                         nom = $tab[1]
                         adresseIP = $tab[2]
                         masque = [int]$tab[3]
                         passerelle = $tab[4]
                         serveurDNS = $tab[5]
                    }
                    #Ajout de l'objet adresse au tableau
                    $adressesIP.Add($myAdresse)
               } catch {
                    Write-Host $elt "n''a pas été ajoutée :" $_
               }
          } else {
               Write-Host $elt "n''a pas été ajoutée : problème de tableau 6 éléments n''ont pas été trouvés"
          }
     }
}

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
# ligne représente une ligne du fichier de Configuration
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
# Lit un fichier de Configuration
#
# .DESCRIPTION
# Get-Config lit un fichier de Configuration et met à jour les deux variables suivantes : 
# - $Global:NomConnexion
# - $Configuration = [System.Collections.ArrayList]@()
# 
#   $Global:NomConnexion prend l'entrée du fichier débutant par "NomConnexion=". Nom Connexion doit correspondre à un nom de carte réseau dans le PC.
#   $Configuration prend les entrées débutant par "IP=" et ayant la forme suivante :"index;nom;adresseIP;masque;passerelle;serveurDns" avec :
# - index : entier réprésentant l'index qui sera à taper pour sélectionner l'adresse IP
# - nom : description de l'adresse
# - adresseIP : 0 ou adresse IP valide. Si 0, paramétrage du DHCP
# - masque : entier représentant le masque de sous réseau (8 pour 255.0.0.0, 16 pour 255.255.0.0, 24 pour 255.255.255.0)
# - passerelle : 0 ou adresse IP valide. Si 0, auncune passerelle n'est indiquée.
# - serveurDNS : 0 ou adresse IP valide. Si 0, aucun serveur DNS paramétré.
#
# .PARAMETER ligne
# ligne représente une ligne du fichier de Configuration
# La fonction attend une chaîne de caractère du type "index;nom;adresseIP;masque;passerelle;serveurDns" avec :
# - index : entier réprésentant l'index qui sera à taper pour sélectionner l'adresse IP
# - nom : description de l'adresse
# - adresseIP : 0 ou adresse IP valide. Si 0, paramétrage du DHCP
# - masque : entier représentant le masque de sous réseau (8 pour 255.0.0.0, 16 pour 255.255.0.0, 24 pour 255.255.255.0)
# - passerelle : 0 ou adresse IP valide. Si 0, auncune passerelle n'est indiquée.
# - serveurDNS : 0 ou adresse IP valide. Si 0, aucun serveur DNS paramétré.
#
function Get-Config {

     $DebugPreference = "continue"
 
     [CmdletBinding()] #<<-- This turns a regular function into an advanced function
 
     $NumberOfLinesMax = 200
 
 
     $AdresseFichierConfiguration = $PSCommandPath -replace ".ps1", ".conf"
     Write-Host $AdresseFichierConfiguration
 
     $TestConfigPath =  Test-Path -Path $AdresseFichierConfiguration
     if ($TestConfigPath) {
         $Conf = Get-Content -Path $AdresseFichierConfiguration -TotalCount $NumberOfLinesMax
 
         foreach ($Ligne in $Conf) {
             try {
                 if ($Ligne.StartsWith("NomConnexion")) {
                     $Tableau = $Ligne -split "="
                     if ($Tableau.length -eq 2) {
                         $Global:NomConnexion = $Tableau[1].Trim()
                     }
                 }
                 if ($Ligne.StartsWith("IP")) {
                     $Tableau = $Ligne -split "="
                     if ($Tableau.length -eq 2) {
                         Limit-Configuration -ligne $Tableau[1]
                         $Configuration.Add($Tableau[1])
                     }
                 }
             } catch {
                 Write-Host $Ligne "n''a pas le format attendu"
             }
         }
 
         Write-Debug "NomConnexion = $Global:NomConnexion "
         foreach ($elt in $Configuration) {
             Write-Debug $elt
         } 
     } else {
         Write-Host "Fichier de Configuration non trouvé. Attendu $AdresseFichierConfiguration"
         #Configuration par défaut
         $Configuration.Add("0,DHCP,0,24,0,0")
         $Configuration.Add("1,Alarme,192.168.1.110,24,0,0")
         $Configuration.Add("2,Fixe,192.168.1.237,24,192.168.1.1,192.168.1.1")
 
         #Indiquer entre guillemet le nom de la carte réseau à modifier "Wi-Fi" ou "Ethernet 2" par exemple à chercher dans Panneau de Configuration\Réseau et Internet\Connexions réseau
         $Global:NomConnexion  = "Ethernet 2" 
 
     }
     #Write-Host $Configuration[1]
 }


<#
.SYNOPSIS
# Affiche le menu en fonction de la variable AdressesIP

.DESCRIPTION
Affiche pour chaque élément de AdresseIP l'index et le nom de l'adresse à afficher.
Propose aussi une saisie manuelle avec M ou de quitter le script avec Q

.PARAMETER Title
Titre à afficher

.EXAMPLE
Show-Menu -Title "Titre du menu"
#>
function Show-Menu {
     param (
          [string]$Title = 'Sélection d''une connexion réseau'
     )
     #Clear-Host
     Write-Host "================ $Title ================"
     
     foreach ($elem in $AdressesIP) {
               Write-Host $elem.index ": " $elem.nom
     }
     Write-Host "M: Taper 'M' pour entrer une adresse IP."
     Write-Host "Q: Taper 'Q' pour quitter."
     }

######## Programmes #########################################


# Restart this script in elevated mode if this user is not an administrator.
Write-Host 'Checking for Administrator Access...'
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
     Write-Host 'Le script n''a pas été lanné avec des droits administrateurs, Essai d''élévation...'
     $arguments = "& '" + $myinvocation.mycommand.definition + "'"
     Start-Process powershell -Verb runAs -ArgumentList $arguments
     Break
} else {

     Get-Config
     Write-Host "Nom connexion = $Global:NomConnexion "
     Get-AdressesIP

     do
     {
          #Write-host $AdressesIP
          Show-Menu
          $entree = Read-Host "Faites un choix"

          if ($entree -eq 'q') {
               return
          } elseif ($entree -eq 'm') {
               $adresseIPManuelle = Read-Host "Entrer une adresse IP"
               try {
                    Limit-AdresseIP -AdresseIP $adresseIPManuelle
                    $masque = Get-masque -AdresseIP $adresseIPManuelle

                    Write-Debug "NomConnexion = $Global:NomConnexion "
                    Set-NetIPInterface -InterfaceAlias $Global:NomConnexion -Dhcp Enabled

                    #Suppression de la passerelle si elle existe
                    try {
                         Remove-NetRoute -InterfaceAlias $Global:NomConnexion -Confirm:$false
                    } catch {
                         Write-Host "Aucune passerelle à supprimer"
                    }

                    #Definition de l'adresse
                    New-NetIpAddress –InterfaceAlias $Global:NomConnexion -IpAddress $adresseIPManuelle -PrefixLength $masque
                    exit
               } catch {
                    Write-Host $adresseIPmanuelle "invalide"
               }
          } else {
               $index = [int]$entree
               foreach ($elt in $AdressesIP) {
                    if ($elt.index -eq $index) {
                         write-host $elt.nom "sélectionné"
                         
                         Write-Host "NomConnexion = $Global:NomConnexion "
                         #Adresse IP
                         #si DHCP
                         Set-NetIPInterface -InterfaceAlias $Global:NomConnexion -Dhcp Enabled

                         #Suppression de la passerelle si elle existe
                         try {
                              Remove-NetRoute -InterfaceAlias $Global:NomConnexion -Confirm:$false
                         } catch {
                              Write-Host "Aucune passerelle à supprimer"
                         }

                         if ($elt.adresseIP -ne '0') {
                         if ($elt.passerelle -eq '0') {                             
                              New-NetIpAddress –InterfaceAlias $Global:NomConnexion -IpAddress $elt.adresseIP -PrefixLength $elt.masque
                         } else {
                              New-NetIpAddress –InterfaceAlias $Global:NomConnexion -IpAddress $elt.adresseIP -PrefixLength $elt.masque -DefaultGateway $elt.passerelle
                         }
                         }

                         #DNS
                         if ($elt.serveurDNS -eq '0') {
                              Set-DnsClientServerAddress –InterfaceAlias $Global:NomConnexion -ResetServerAddresses
                         } else {
                              Set-DnsClientServerAddress -InterfaceAlias $Global:NomConnexion -ServerAddresses $elt.serveurDNS
                         }

                         #Start-Sleep -Seconds 1.5
                         
                         exit
                    }
               }
          }
     }
     until ($entree -eq 'q')

}

