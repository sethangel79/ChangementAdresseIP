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
$configuration = [System.Collections.ArrayList]@()
$adressesIP = [System.Collections.ArrayList]@()

######## Paramétrage ########################################

#Numéro à sélectionner, Nom connexion à sélectionner, adresse IP, masque de sous-réseau ("24" pour 255.255.255.0, "16" pour 255.255.0, "8" pour 255.0.0), adresse passerelle, adresse serveur DNS
#Si 0 utilisation de l'adresse par défaut
$Configuration.Add("0,DHCP,0,24,0,0")
$Configuration.Add("1,Alarme,192.168.1.110,24,0,0")
$Configuration.Add("2,Fixe,192.168.1.237,24,192.168.1.1,192.168.1.1")

#Indiquer entre guillemet le nom de la carte réseau à modifier "Wi-Fi" ou "Ethernet 2" par exemple à chercher dans Panneau de configuration\Réseau et Internet\Connexions réseau
#$NomConnexion = "Wi-Fi" 
$NomConnexion = "Ethernet 2" 

######## Programmation ######################################


# Restart this script in elevated mode if this user is not an administrator.
Write-Host 'Checking for Administrator Access...'
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {   
     Write-Host 'Le script n''a pas été lanné avec des droits administrateurs, Essai d''élévation...'
     $arguments = "& '" + $myinvocation.mycommand.definition + "'"
     Start-Process powershell -Verb runAs -ArgumentList $arguments
     Break
} else {

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


     function Get-AdressesIP {
          foreach ($elem in $Configuration) {
               $tab = $elem -split ","

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
               }
          }
     }

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

                    Set-NetIPInterface -InterfaceAlias $NomConnexion -Dhcp Enabled

                    #Suppression de la passerelle si elle existe
                    try {
                         Remove-NetRoute -InterfaceAlias $NomConnexion -Confirm:$false
                    } catch {
                         Write-Host "Aucune passerelle à supprimer"
                    }

                    #Definition de l'adresse
                    New-NetIpAddress –InterfaceAlias $NomConnexion -IpAddress $adresseIPManuelle -PrefixLength $masque
                    exit
               } catch {
                    Write-Host $adresseIPmanuelle "invalide"
               }
          } else {
               $index = [int]$entree
               foreach ($elt in $AdressesIP) {
                    if ($elt.index -eq $index) {
                         write-host $elt.nom "sélectionné"

                         #Adresse IP
                         #si DHCP
                         Set-NetIPInterface -InterfaceAlias $NomConnexion -Dhcp Enabled

                         #Suppression de la passerelle si elle existe
                         try {
                              Remove-NetRoute -InterfaceAlias $NomConnexion -Confirm:$false
                         } catch {
                              Write-Host "Aucune passerelle à supprimer"
                         }

                         if ($elt.adresseIP -ne '0') {
                         if ($elt.passerelle -eq '0') {                             
                              New-NetIpAddress –InterfaceAlias $NomConnexion -IpAddress $elt.adresseIP -PrefixLength $elt.masque
                         } else {
                              New-NetIpAddress –InterfaceAlias $NomConnexion -IpAddress $elt.adresseIP -PrefixLength $elt.masque -DefaultGateway $elt.passerelle
                         }
                         }

                         #DNS
                         if ($elt.serveurDNS -eq '0') {
                              Set-DnsClientServerAddress –InterfaceAlias $NomConnexion -ResetServerAddresses
                         } else {
                              Set-DnsClientServerAddress -InterfaceAlias $NomConnexion -ServerAddresses $elt.serveurDNS
                         }

                         #Start-Sleep -Seconds 1.5
                         
                         exit
                    }
               }
          }
     }
     until ($entree -eq 'q')

}

