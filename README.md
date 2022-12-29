# ChangementAdresseIP

## Configuration
Pour utiliser le script, commencez par configurer le fichier ChangementAdresseIP.conf: 

- NomConnexion= : Doit correspondre exactement au nom de la carte réseau à modifier dans Windows (Ethernet 2 dans notre exemple)
![Image de la carte réseau](/Images/00%20-%20Reseau.png)

- IP= : Correspond à une configuration de carte à appliquer. 
    _La syntaxe est la suivante :
    Numéro à sélectionner, Nom connexion à sélectionner, adresse IP, masque de sous-réseau ("24" pour 255.255.255.0, "16" pour 255.255.0, "8" pour 255.0.0), adresse passerelle, adresse serveur DNS
    Si 0 utilisation de l'adresse par défaut
    Exemple :
    * IP=0;DHCP;0;24;0;0
    * IP=1;Alarme;192.168.1.110;24;0;0
    * *IP=2;Fixe;192.168.1.237;24;192.168.1.1;192.168.1.1_

## Lancement
Pour utiliser le script, plusieurs choix s'offre à vous :
- Lancer une fenêtre powershell et lancer le script

![Lancement du script](/Images/01%20-%20Lancement%20shell.png)

- Lancement depuis l'explorateur windows par clic droit

![clic droit](/Images/00%20-%20Lancement%20Clic%20droit.png)

- Création d'un raccourcis windows

![raccourcis](/Images/01%20-%20Cr%C3%A9ationRaccourcis.png)
![raccourcis](/Images/01%20-%20Cr%C3%A9ationRaccourcis%201.png)
![raccourcis](/Images/01%20-%20Cr%C3%A9ationRaccourcis%202.png)

## Note
Le script nécessite les droits administrateurs pour s'exécuter (changement adresse IP).
Pour cela si le script est lancé avec des droits classiques, une fenêtre d'autorisation sera affichée par Windows. Cliquer sur oui.

## Utilisation
Le script affiche les IP valides du fichier de configuration en choix.
Il permet aussi de saisir simplement une adresse IP seule (m) et de quitter l'application sans modification (q)

![Shell exemple](/Images/02%20-%20Execution.png)

Saisissez le numéro de l'index correspondant au choix souhaité (dans notre cas, 0 pour DHCP par exemple) et appuyer sur entrée.
L'adresse IP est modifiée.