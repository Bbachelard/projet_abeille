#!/bin/bash

if [ $# -eq 0 ]; then
    echo "Usage: $0 <ruche_id>"
    echo "Exemple: $0 2"
    echo "Note: Si aucun ID n'est fourni, la valeur par défaut 1 sera utilisée."
    RUCHE_ID=1
else
    # Vérifier que l'argument est un nombre
    if [[ $1 =~ ^[0-9]+$ ]]; then
        RUCHE_ID=$1
    else
        echo "Erreur: L'ID de ruche doit être un nombre entier."
        echo "Usage: $0 <ruche_id>"
        exit 1
    fi
fi
# Configuration
SD_CARD_PATH="/media/pi/SD"  # Chemin vers la carte SD montée
LOCAL_IMG_DIR="$HOME/images"  # Dossier local pour stocker les images
DB_PATH="/home/pi/nom_base.sqlite"  # Chemin vers la base de données SQLite
IMAGE_PERMISSIONS="755"  # Permissions pour les nouvelles images (rwxr-xr-x)
WEB_IMAGES_DIR="/var/www/html/ruche_connectee/images"  # Dossier web pour les images

# Fonction pour afficher les messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}
log "Démarrage de la synchronisation des images pour la ruche ID: $RUCHE_ID"

# Vérifier si un périphérique de stockage externe est présent
check_external_storage() {
    # Vérifier si des périphériques externes sont présents
    DEVICE=$(lsblk -o NAME,SIZE,TYPE | grep "disk" | grep -v "mmcblk0" | awk '{print $1}' | head -n 1)
    
    if [ -z "$DEVICE" ]; then
        log "Aucun périphérique de stockage externe détecté"
        return 1
    fi
    
    log "Périphérique de stockage externe détecté: /dev/$DEVICE"
    return 0
}

# Vérifier si la carte SD est montée
check_sd_card() {
    # Essayer de monter spécifiquement /dev/sda1 au début
    if [ ! -d "$SD_CARD_PATH" ]; then
        log "Création du point de montage $SD_CARD_PATH si nécessaire"
        sudo mkdir -p "$SD_CARD_PATH"
    fi

    # Vérifier si la carte SD est déjà montée
    if ! mountpoint -q "$SD_CARD_PATH"; then
        log "Tentative de montage de /dev/sda1 sur $SD_CARD_PATH"
        sudo mount /dev/sda1 "$SD_CARD_PATH"
        
        if [ $? -eq 0 ]; then
            log "Carte SD (/dev/sda1) montée avec succès sur $SD_CARD_PATH"
            return 0
        else
            log "Échec du montage de /dev/sda1, recherche d'autres périphériques..."
            
            # Si /dev/sda1 échoue, essayer la méthode originale
            DEVICE=$(lsblk -o NAME,SIZE,TYPE | grep "disk" | grep -v "mmcblk0" | awk '{print $1}' | head -n 1)
            
            if [ -n "$DEVICE" ]; then
                log "Carte SD trouvée: /dev/$DEVICE, tentative de montage..."
                
                sudo mount "/dev/$DEVICE" "$SD_CARD_PATH"
                
                if [ $? -eq 0 ]; then
                    log "Carte SD montée avec succès sur $SD_CARD_PATH"
                    return 0
                else
                    log "Échec du montage de la carte SD"
                    return 1
                fi
            else
                log "Aucune carte SD détectée"
                return 1
            fi
        fi
    fi
    
    log "Carte SD déjà montée sur $SD_CARD_PATH"
    return 0
}

# Créer le dossier local s'il n'existe pas
create_local_dir() {
    if [ ! -d "$LOCAL_IMG_DIR" ]; then
        mkdir -p "$LOCAL_IMG_DIR"
        log "Dossier local créé: $LOCAL_IMG_DIR"
    fi
    
    # S'assurer que nous avons les permissions d'écriture
    if [ ! -w "$LOCAL_IMG_DIR" ]; then
        sudo chown -R $(whoami):$(whoami) "$LOCAL_IMG_DIR"
        log "Permissions ajustées pour $LOCAL_IMG_DIR"
    fi
    
    # Créer le dossier web s'il n'existe pas
    if [ ! -d "$WEB_IMAGES_DIR" ]; then
        sudo mkdir -p "$WEB_IMAGES_DIR"
        log "Dossier web créé: $WEB_IMAGES_DIR"
    fi
    
    # S'assurer que les permissions du dossier web sont correctes
    sudo chown -R www-data:www-data "$WEB_IMAGES_DIR"
    sudo chmod 755 "$WEB_IMAGES_DIR"
}

# Vérifier si la base de données existe et est accessible
check_database() {
    if [ ! -f "$DB_PATH" ]; then
        log "Base de données non trouvée: $DB_PATH"
        
        # Chercher la base de données
        DB_FOUND=$(find /var/www -name "*.db" -o -name "*.sqlite" 2>/dev/null | head -n 1)
        
        if [ -n "$DB_FOUND" ]; then
            DB_PATH="$DB_FOUND"
            log "Base de données trouvée: $DB_PATH"
        else
            log "Aucune base de données trouvée, création d'une nouvelle..."
            DB_DIR=$(dirname "$DB_PATH")
            sudo mkdir -p "$DB_DIR"
            
            # Créer la structure de la base de données
            sqlite3 "$DB_PATH" << EOF
CREATE TABLE IF NOT EXISTS "ruche" (
  "id_ruche" INTEGER NOT NULL,
  "nom_ruche" TEXT DEFAULT NULL,
  "localisation" TEXT DEFAULT NULL,
  PRIMARY KEY ("id_ruche")
);

CREATE TABLE IF NOT EXISTS "images" (
  "id_image" INTEGER NOT NULL,
  "id_ruche" INTEGER NOT NULL,
  "chemin_fichier" text DEFAULT NULL,
  "date_capture" TEXT DEFAULT NULL,
  PRIMARY KEY ("id_image"),
  FOREIGN KEY ("id_ruche") REFERENCES "ruche"("id_ruche")
);

-- Ajouter la ruche si elle n'existe pas
INSERT OR IGNORE INTO ruche (id_ruche, nom_ruche) VALUES ($RUCHE_ID, 'Ruche $RUCHE_ID');
EOF
            
            # Ajuster les permissions
            sudo chown pi:pi "$DB_PATH"
            sudo chmod 664 "$DB_PATH"
            log "Base de données créée: $DB_PATH"
        fi
    fi
    
    # Vérifier que nous pouvons écrire dans la base de données
    if [ ! -w "$DB_PATH" ]; then
        sudo chmod 664 "$DB_PATH"
        sudo chown pi:pi "$DB_PATH"
        log "Permissions ajustées pour la base de données"
    fi
}

# Synchroniser les images
sync_images() {
    # Compte le nombre d'images sur la carte SD
    local image_count=$(find "$SD_CARD_PATH" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.bmp" \) | wc -l)
    log "Trouvé $image_count images sur la carte SD"
    
    # Si aucune image, sortir
    if [ "$image_count" -eq 0 ]; then
        log "Aucune image à synchroniser depuis la carte SD"
        return 0
    fi
    
    # Variables pour compter les images synchronisées
    local images_synced=0
    local new_images=()
    
    # Parcourir les images sur la carte SD
    find "$SD_CARD_PATH" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.bmp" \) | while read image_file; do
        # Extraire les métadonnées de l'image (date de création)
        file_name=$(basename "$image_file")
        file_ext="${file_name##*.}"
        
        # Obtenir la date de création/modification du fichier
        file_date=$(stat -c "%y" "$image_file" | cut -d. -f1 | sed 's/ /T/g')
        
        # Générer un nouveau nom de fichier basé sur la date
        new_file_name="${file_date}.${file_ext}"
        new_file_path="$LOCAL_IMG_DIR/$new_file_name"
        
        # Vérifier si l'image existe déjà localement
        if [ -f "$new_file_path" ]; then
            log "L'image $new_file_name existe déjà dans le dossier local, vérification du dossier web..."
            
            # Vérifier si l'image existe dans le dossier web
            if [ ! -f "$WEB_IMAGES_DIR/$new_file_name" ]; then
                # Copier directement vers le dossier web
                sudo cp "$new_file_path" "$WEB_IMAGES_DIR/"
                sudo chmod $IMAGE_PERMISSIONS "$WEB_IMAGES_DIR/$new_file_name"
                sudo chown www-data:www-data "$WEB_IMAGES_DIR/$new_file_name"
                log "Image $new_file_name copiée vers le dossier web"
                
                # Vérifier si l'image est déjà dans la base de données
                local exists=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM images WHERE chemin_fichier = '/ruche_connectee/images/$new_file_name' AND id_ruche = $RUCHE_ID;")
                
                if [ "$exists" -eq 0 ]; then
                    # Ajouter l'image à la base de données
                    local db_date=$(echo "$file_date" | sed 's/\.[0-9]*$//')"Z"
                    
                    sqlite3 "$DB_PATH" << EOF
INSERT INTO images (id_image, id_ruche, chemin_fichier, date_capture) 
VALUES (
  (SELECT COALESCE(MAX(id_image), 0) + 1 FROM images), 
  $RUCHE_ID, 
  '/ruche_connectee/images/$new_file_name', 
  '$db_date'
);
EOF
                    
                    if [ $? -eq 0 ]; then
                        log "Image $new_file_name ajoutée à la base de données"
                        images_synced=$((images_synced + 1))
                    else
                        log "Erreur lors de l'ajout de l'image à la base de données"
                    fi
                else
                    log "L'image $new_file_name est déjà dans la base de données"
                fi
            fi
            
            continue
        fi
        
        # Copier l'image vers le dossier local
        cp "$image_file" "$new_file_path"
        
        if [ $? -eq 0 ]; then
            # S'assurer que les permissions sont correctes
            chmod $IMAGE_PERMISSIONS "$new_file_path"
            chown pi:pi "$new_file_path"
            
            # Copier également vers le dossier web
            sudo cp "$new_file_path" "$WEB_IMAGES_DIR/"
            sudo chmod $IMAGE_PERMISSIONS "$WEB_IMAGES_DIR/$new_file_name"
            sudo chown www-data:www-data "$WEB_IMAGES_DIR/$new_file_name"
            
            # Chemin pour la base de données
            rel_path="/ruche_connectee/images/$new_file_name"
            
            # Date de capture au format attendu par l'application
            db_date=$(echo "$file_date" | sed 's/\.[0-9]*$//')"Z"
            
            # Ajouter l'image à la base de données
            sqlite3 "$DB_PATH" << EOF
INSERT INTO images (id_image, id_ruche, chemin_fichier, date_capture) 
VALUES (
  (SELECT COALESCE(MAX(id_image), 0) + 1 FROM images), 
  $RUCHE_ID, 
  '$rel_path', 
  '$db_date'
);
EOF
            
            if [ $? -eq 0 ]; then
                log "Image $file_name copiée et ajoutée à la base de données comme $new_file_name"
                images_synced=$((images_synced + 1))
                new_images+=("$new_file_name")
            else
                log "Erreur lors de l'ajout de l'image à la base de données"
            fi
        else
            log "Erreur lors de la copie de l'image $file_name"
        fi
    done
    
    log "Synchronisation depuis la carte SD terminée. $images_synced nouvelles images traitées."
}

# Fonction pour synchroniser le dossier local avec le dossier web
sync_local_to_web() {
    log "Synchronisation du dossier local avec le dossier web..."
    
    # Compter les images dans le dossier local
    local local_count=$(find "$LOCAL_IMG_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.bmp" \) | wc -l)
    
    # Compter les images dans le dossier web
    local web_count=$(find "$WEB_IMAGES_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.bmp" \) 2>/dev/null | wc -l)
    
    log "Images locales: $local_count, Images web: $web_count"
    
    # Si les nombres ne correspondent pas, synchroniser
    if [ "$local_count" -ne "$web_count" ]; then
        log "Différence détectée, synchronisation en cours..."
        
        # Parcourir toutes les images du dossier local
        find "$LOCAL_IMG_DIR" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.bmp" \) | while read img; do
            local img_name=$(basename "$img")
            local web_img_path="$WEB_IMAGES_DIR/$img_name"
            
            # Vérifier si l'image existe dans le dossier web
            if [ ! -f "$web_img_path" ]; then
                # Copier l'image vers le dossier web
                sudo cp "$img" "$WEB_IMAGES_DIR/"
                sudo chmod $IMAGE_PERMISSIONS "$web_img_path"
                sudo chown www-data:www-data "$web_img_path"
                log "Image $img_name copiée vers le dossier web"
                
                # Vérifier si l'image est déjà dans la base de données
                local rel_path="/ruche_connectee/images/$img_name"
                local exists=$(sqlite3 "$DB_PATH" "SELECT COUNT(*) FROM images WHERE chemin_fichier = '$rel_path' AND id_ruche = $RUCHE_ID;")
                
                if [ "$exists" -eq 0 ]; then
                    # Extraire la date du nom de fichier (format supposé: YYYY-MM-DDTHH:MM:SS.ext)
                    local file_date=$(echo "$img_name" | sed -E 's/^([0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}).*$/\1/')
                    local db_date="${file_date}Z"
                    
                    # Ajouter l'image à la base de données
                    sqlite3 "$DB_PATH" << EOF
INSERT INTO images (id_image, id_ruche, chemin_fichier, date_capture) 
VALUES (
  (SELECT COALESCE(MAX(id_image), 0) + 1 FROM images), 
  $RUCHE_ID, 
  '$rel_path', 
  '$db_date'
);
EOF
                    
                    if [ $? -eq 0 ]; then
                        log "Image $img_name ajoutée à la base de données"
                    else
                        log "Erreur lors de l'ajout de l'image à la base de données"
                    fi
                fi
            fi
        done
        
        log "Synchronisation local → web terminée"
    else
        log "Les dossiers sont déjà synchronisés"
    fi
}

# Démonter proprement la carte SD
unmount_sd_card() {
    log "Démontage de la carte SD..."
    sudo umount "$SD_CARD_PATH" 2>/dev/null
    log "Carte SD démontée. Vous pouvez la retirer en toute sécurité."
}

# Fonction principale
main() {
    log "Démarrage de la synchronisation des images"
    
    # Vérifier d'abord si un périphérique de stockage externe est présent
    check_external_storage
    if [ $? -ne 0 ]; then
        log "Aucun périphérique de stockage externe détecté. Arrêt de la synchronisation."
        exit 0
    fi
    
    # Vérifier et monter la carte SD
    check_sd_card
    if [ $? -ne 0 ]; then
        log "Impossible de monter le périphérique de stockage. Arrêt de la synchronisation."
        exit 0
    fi
    
    # Créer le dossier local et web
    create_local_dir
    
    # Vérifier la base de données
    check_database
    
    # Synchroniser les images
    sync_images
    
    # Synchroniser le dossier local avec le web
    sync_local_to_web
    
    # Démonter la carte SD
    unmount_sd_card
    
    log "Synchronisation terminée avec succès"
}

# Exécuter la fonction principale
main
