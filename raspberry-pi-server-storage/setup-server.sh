#!/bin/bash
# Script d'installation du serveur de mods Los Nachos sur Raspberry Pi

echo "========================================="
echo "Installation du serveur de mods Los Nachos"
echo "========================================="
echo ""

# Vérifier si on est sur le Raspberry Pi
if [ ! -f /etc/rpi-issue ]; then
    echo "ATTENTION: Ce script est conçu pour Raspberry Pi OS"
    read -p "Voulez-vous continuer quand même ? (o/N) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Oo]$ ]]; then
        exit 1
    fi
fi

# Mettre à jour le système
echo "[1/7] Mise à jour du système..."
sudo apt-get update -qq

# Installer Python 3 et pip (normalement déjà installés sur Raspberry Pi OS)
echo "[2/7] Vérification de Python 3..."
if ! command -v python3 &> /dev/null; then
    echo "Installation de Python 3..."
    sudo apt-get install -y python3 python3-pip
else
    echo "Python 3 est déjà installé"
fi

# Installer les dépendances Python
echo "[3/7] Installation des dépendances Python..."
pip3 install -r requirements.txt --user

# Créer le fichier .env s'il n'existe pas
if [ ! -f .env ]; then
    echo "[4/7] Création du fichier de configuration..."
    cp .env.example .env

    # Générer un mot de passe aléatoire
    RANDOM_PASSWORD=$(openssl rand -base64 12)
    sed -i "s/ADMIN_PASSWORD=admin/ADMIN_PASSWORD=$RANDOM_PASSWORD/" .env

    # Générer une clé secrète aléatoire
    RANDOM_SECRET=$(openssl rand -base64 32)
    sed -i "s/SECRET_KEY=.*/SECRET_KEY=$RANDOM_SECRET/" .env

    echo ""
    echo "========================================="
    echo "IMPORTANT: Mot de passe administrateur"
    echo "========================================="
    echo "Mot de passe: $RANDOM_PASSWORD"
    echo ""
    echo "Notez ce mot de passe ! Il est enregistré dans .env"
    echo "========================================="
    echo ""
    read -p "Appuyez sur Entrée pour continuer..."
else
    echo "[4/7] Fichier .env déjà existant"
fi

# Créer le service systemd
echo "[5/7] Configuration du service systemd..."
SERVICE_FILE="/etc/systemd/system/minecraft-mods.service"

sudo tee $SERVICE_FILE > /dev/null <<EOF
[Unit]
Description=Los Nachos Minecraft Mods Server
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$(pwd)/server
EnvironmentFile=$(pwd)/.env
ExecStart=/usr/bin/python3 $(pwd)/server/app.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Recharger systemd et activer le service
echo "[6/7] Activation du service..."
sudo systemctl daemon-reload
sudo systemctl enable minecraft-mods.service
sudo systemctl start minecraft-mods.service

# Vérifier le statut
sleep 2
if sudo systemctl is-active --quiet minecraft-mods.service; then
    echo "✓ Service démarré avec succès !"
else
    echo "✗ Erreur lors du démarrage du service"
    echo "Logs:"
    sudo journalctl -u minecraft-mods.service -n 20
    exit 1
fi

# Afficher l'adresse IP
echo "[7/7] Configuration terminée !"
echo ""
echo "========================================="
echo "Installation terminée avec succès !"
echo "========================================="
echo ""
echo "Le serveur est maintenant accessible à l'adresse :"
IP_ADDRESS=$(hostname -I | awk '{print $1}')
echo ""
echo "  Interface web: http://$IP_ADDRESS:8080/admin"
echo "  API (launcher): http://$IP_ADDRESS:8080/manifest.json"
echo ""
echo "Commandes utiles :"
echo "  - Voir les logs:      sudo journalctl -u minecraft-mods.service -f"
echo "  - Redémarrer:         sudo systemctl restart minecraft-mods.service"
echo "  - Arrêter:            sudo systemctl stop minecraft-mods.service"
echo "  - Démarrer:           sudo systemctl start minecraft-mods.service"
echo ""
echo "Pour ajouter des mods :"
echo "  1. Accédez à http://$IP_ADDRESS:8080/admin"
echo "  2. Connectez-vous avec le mot de passe affiché précédemment"
echo "  3. Glissez-déposez vos fichiers .jar"
echo ""
echo "========================================="
