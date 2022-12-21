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
$configuration = @()
$adressesIP = [System.Collections.ArrayList]@()

######## Paramétrage ########################################

#Numéro à sélectionner, Nom connexion à sélectionner, adresse IP, masque de sous-réseau ("24" pour 255.255.255.0, "16" pour 255.255.0, "8" pour 255.0.0), adresse passerelle, adresse serveur DNS
#Si 0 utilisation de l'adresse par défaut
$Configuration += "0,DHCP,0,24,0,0"
$Configuration += "1,Alarme,192.168.1.110,24,0,0"
$Configuration += "2,Fixe,192.168.1.237,24,192.168.1.1,192.168.1.1"

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
     function Get-AdressesIP {
          foreach ($elem in $Configuration) {
               $tab = $elem -split ","

               #Write-Host $tab.count
               #Si la chaine est coorecte
               if ($tab.count -eq 6) {
                    write-host $tab[0] "-" $tab[1] "-" $tab[2] "-" $tab[3] "-" $tab[4] "-" $tab[5]
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

