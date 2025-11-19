# 🎮 Los Nachos - Serveur de Mods (Raspberry Pi)

Système de synchronisation automatique des mods pour le launcher Los Nachos avec interface web de gestion.

## 📦 Publication sur GitHub

**Avant d'installer sur le Raspberry Pi**, assurez-vous d'avoir publié votre projet sur GitHub :

```bash
# Sur votre PC, dans le dossier du projet
cd e:\Projet\Perso\lunchermc

# Initialiser Git (si pas déjà fait)
git init

# Ajouter tous les fichiers
git add .

# Créer un commit
git commit -m "Initial commit - Los Nachos Launcher"

# Ajouter le repository distant (créez d'abord un repo sur github.com)
git remote add origin https://github.com/Mathew3585/mc-mod.git

# Pousser vers GitHub
git push -u origin main
```

Une fois votre projet publié sur GitHub, vous pourrez l'installer facilement sur le Raspberry Pi.

## 📋 Vue d'ensemble

Ce serveur permet de :
- **Centraliser** tous les mods sur un Raspberry Pi
- **Gérer** les mods via une interface web (ajouter/supprimer)
- **Synchroniser** automatiquement les mods chez tous les joueurs
- **Partager** facilement les mods avec toute votre équipe

## 🚀 Installation sur Raspberry Pi

### Prérequis

- Raspberry Pi 3 ou supérieur
- Raspberry Pi OS Lite 64-bit (ou Desktop)
- Connexion internet
- Git (généralement préinstallé sur Raspberry Pi OS)

### Étape 1 : Installer Git (si nécessaire)

Si Git n'est pas installé sur votre Raspberry Pi :

```bash
ssh pi@[IP_RASPBERRY]
sudo apt-get update
sudo apt-get install -y git
git --version  # Vérifier l'installation
```

### Étape 2 : Cloner le repository

Clonez le repository GitHub :

```bash
cd ~
git clone https://github.com/Mathew3585/mc-mod.git
cd mc-mod/raspberry-pi-server-storage
```

**Méthode alternative (téléchargement direct sans Git)** :

```bash
cd ~
wget https://github.com/Mathew3585/mc-mod/archive/refs/heads/main.zip
sudo apt-get install -y unzip  # Installer unzip si nécessaire
unzip main.zip
mv mc-mod-main mc-mod
cd mc-mod/raspberry-pi-server-storage
```

### Étape 3 : Installer

Exécutez le script d'installation :

```bash
chmod +x setup-server.sh
./setup-server.sh
```

Le script va :
1. Mettre à jour le système
2. Installer Python 3 et les dépendances
3. Générer un mot de passe administrateur aléatoire
4. Configurer le service systemd (démarrage automatique)
5. Démarrer le serveur

**IMPORTANT** : Notez le mot de passe administrateur affiché !

### Étape 3 : Accéder à l'interface

Ouvrez un navigateur et accédez à :

```
http://[IP_RASPBERRY]:8080/admin
```

Entrez le mot de passe administrateur pour vous connecter.

## 🖥️ Utilisation de l'interface web

### Ajouter des mods

1. **Méthode 1 - Glisser-déposer** :
   - Téléchargez le mod `.jar` sur votre PC
   - Glissez-déposez le fichier dans la zone d'upload

2. **Méthode 2 - Sélection** :
   - Cliquez sur "Choisir des fichiers"
   - Sélectionnez un ou plusieurs fichiers `.jar`

Les mods sont automatiquement uploadés et le manifest est régénéré.

### Supprimer des mods

1. Trouvez le mod dans la liste
2. Cliquez sur le bouton "🗑️ Supprimer"
3. Confirmez la suppression

Le manifest est automatiquement régénéré.

### Autres fonctionnalités

- **♻️ Régénérer le manifest** : Force la régénération du fichier manifest.json
- **🔄 Rafraîchir** : Recharge la liste des mods
- **📥 Télécharger** : Télécharge un mod vers votre PC (backup)

## 🎯 Configuration du Launcher

Une fois le serveur configuré, vous devez configurer le launcher pour qu'il se connecte au serveur.

**Dans les settings du launcher**, ajoutez l'URL du serveur :

```
http://[IP_RASPBERRY]:8080
```

Au prochain lancement, les mods seront automatiquement synchronisés !

## 🔧 Administration du serveur

### Commandes utiles

```bash
# Voir les logs en temps réel
sudo journalctl -u minecraft-mods.service -f

# Redémarrer le serveur
sudo systemctl restart minecraft-mods.service

# Arrêter le serveur
sudo systemctl stop minecraft-mods.service

# Démarrer le serveur
sudo systemctl start minecraft-mods.service

# Voir le statut
sudo systemctl status minecraft-mods.service
```

### Changer le mot de passe administrateur

Éditez le fichier `.env` :

```bash
nano ~/mc-mod/raspberry-pi-server-storage/.env
```

Modifiez la ligne :

```
ADMIN_PASSWORD=votre_nouveau_mot_de_passe
```

Redémarrez le serveur :

```bash
sudo systemctl restart minecraft-mods.service
```

### Ajouter des mods manuellement (sans interface web)

Si vous préférez utiliser la ligne de commande :

```bash
# Copier un mod depuis votre PC
scp mon-mod.jar pi@[IP_RASPBERRY]:~/mc-mod/raspberry-pi-server-storage/mods/

# Régénérer le manifest
ssh pi@[IP_RASPBERRY]
cd ~/mc-mod/raspberry-pi-server-storage/server
python3 -c "import utils; utils.generate_manifest('../mods')"
```

## 📊 Structure des fichiers

```
~/mc-mod/raspberry-pi-server-storage/
├── .env                          # Configuration (mot de passe, etc.)
├── requirements.txt              # Dépendances Python
├── setup-server.sh               # Script d'installation
├── minecraft-mods.service        # Service systemd
├── README.md                     # Cette documentation
├── server/
│   ├── app.py                    # Serveur Flask
│   ├── utils.py                  # Fonctions utilitaires
│   ├── static/
│   │   ├── style.css
│   │   └── app.js
│   └── templates/
│       ├── index.html            # Interface d'administration
│       └── login.html            # Page de connexion
└── mods/
    ├── mod1.jar
    ├── mod2.jar
    └── manifest.json             # Généré automatiquement
```

## 🔐 Sécurité

### Protection par mot de passe

L'interface web est protégée par un mot de passe. Assurez-vous de :
- Changer le mot de passe par défaut
- Utiliser un mot de passe fort
- Ne pas partager le mot de passe publiquement

### Pare-feu

Le serveur écoute sur le port 8080. Si vous avez un pare-feu configuré :

```bash
sudo ufw allow 8080
```

### Accès depuis internet

Par défaut, le serveur n'est accessible que depuis votre réseau local. Pour l'exposer sur internet, vous devrez :
1. Configurer le port forwarding sur votre routeur
2. Utiliser un nom de domaine ou Dynamic DNS
3. **IMPORTANT** : Ajouter du HTTPS (Let's Encrypt) pour sécuriser les communications

## 🐛 Dépannage

### Le serveur ne démarre pas

Vérifiez les logs :

```bash
sudo journalctl -u minecraft-mods.service -n 50
```

Vérifiez que Python 3 et Flask sont installés :

```bash
python3 --version
pip3 list | grep Flask
```

### Impossible d'accéder à l'interface web

Vérifiez que le service est actif :

```bash
sudo systemctl status minecraft-mods.service
```

Vérifiez l'adresse IP du Raspberry Pi :

```bash
hostname -I
```

Testez la connexion depuis votre PC :

```bash
ping [IP_RASPBERRY]
curl http://[IP_RASPBERRY]:8080/manifest.json
```

### Les mods ne se synchronisent pas

Dans le launcher :
1. Vérifiez l'URL du serveur dans les settings
2. Cliquez sur "Tester la connexion"
3. Vérifiez les logs du launcher

Sur le serveur :
1. Vérifiez que le manifest.json existe : `ls ~/mc-mod/raspberry-pi-server-storage/mods/manifest.json`
2. Vérifiez le contenu : `cat ~/mc-mod/raspberry-pi-server-storage/mods/manifest.json`

## 📝 Format du manifest.json

Le fichier `manifest.json` est généré automatiquement et contient :

```json
{
  "version": "1.0.0",
  "minecraft_version": "1.20.1",
  "last_updated": "2024-01-20T15:30:00",
  "mods": [
    {
      "filename": "mod-exemple.jar",
      "size": 1234567,
      "sha256": "abc123...",
      "url": "/mods/mod-exemple.jar"
    }
  ]
}
```

## 🆕 Mise à jour du serveur

Pour mettre à jour le serveur avec de nouvelles fonctionnalités :

```bash
# Connectez-vous au Raspberry Pi
ssh pi@[IP_RASPBERRY]

# Arrêtez le service
sudo systemctl stop minecraft-mods.service

# Mettez à jour le repository
cd ~/mc-mod
git pull origin main

# Redémarrez le service
sudo systemctl start minecraft-mods.service
```

**Alternative si vous avez modifié des fichiers localement** :

```bash
# Sauvegardez vos modifications
cd ~/mc-mod
git stash

# Récupérez les dernières modifications
git pull origin main

# Réappliquez vos modifications (optionnel)
git stash pop

# Redémarrez le service
sudo systemctl restart minecraft-mods.service
```

## 💡 Astuces

### Backup des mods

Sauvegardez régulièrement vos mods :

```bash
# Depuis le Raspberry Pi
cd ~/mc-mod/raspberry-pi-server-storage
tar -czf mods-backup-$(date +%Y%m%d).tar.gz mods/

# Ou depuis votre PC
scp -r pi@[IP_RASPBERRY]:~/mc-mod/raspberry-pi-server-storage/mods ./mods-backup/
```

### Accès depuis plusieurs launchers

Tous les launchers configurés avec la même URL de serveur recevront automatiquement les mêmes mods.

### Performance

Le Raspberry Pi 3 peut facilement gérer :
- 10-20 joueurs simultanés
- Plusieurs centaines de mods
- Bande passante : ~10 MB/s

Pour de meilleures performances, utilisez un Raspberry Pi 4.

## 📞 Support

Pour toute question ou problème :
1. Vérifiez les logs : `sudo journalctl -u minecraft-mods.service -f`
2. Vérifiez que le serveur est accessible : `curl http://[IP_RASPBERRY]:8080/manifest.json`
3. Contactez l'équipe Los Nachos

## 📜 Licence

Ce projet fait partie du Los Nachos Launcher.

---

**Los Nachos Chipies © 2024**
