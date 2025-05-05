#!/bin/bash

# Script simplifié pour supprimer une image
# Usage: ./deleteimage.sh <chemin_complet>

# Configuration
LOG_FILE="$HOME/deleteimage.log"  # Log dans le répertoire home
LOCAL_IMG_DIR="$HOME/images"  # Dossier local des images
WEB_IMAGES_DIR="/var/www/html/ruche_connectee/images"  # Dossier web

# Fonction de journalisation
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Vérifier le nombre d'arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <chemin_complet>"
    echo "Exemple: $0 /var/www/html/ruche_connectee/images/2025-03-26T10:27:48.png"
    exit 1
fi

# Récupérer l'argument (chemin complet)
FULL_PATH=$1

# Extraire juste le nom du fichier (sans le chemin)
FILENAME=$(basename "$FULL_PATH")

log "Début de la suppression d'image, fichier: $FILENAME (chemin complet: $FULL_PATH)"

# Supprimer le fichier des répertoires locaux
delete_local_files() {
    SUCCESS=0
    
    # 1. Supprimer du chemin original fourni
    if [ -f "$FULL_PATH" ]; then
        log "Suppression du fichier au chemin original: $FULL_PATH"
        rm -f "$FULL_PATH" 2>/dev/null || sudo rm -f "$FULL_PATH" 2>/dev/null
        
        if [ $? -ne 0 ]; then
            log "Erreur lors de la suppression du fichier au chemin original"
            SUCCESS=1
        else
            log "Fichier supprimé avec succès du chemin original"
        fi
    else
        log "Le fichier n'existe pas au chemin original: $FULL_PATH"
    fi
    
    # 2. Supprimer du dossier web standard (si différent du chemin original)
    WEB_PATH="$WEB_IMAGES_DIR/$FILENAME"
    if [ "$WEB_PATH" != "$FULL_PATH" ] && [ -f "$WEB_PATH" ]; then
        log "Suppression du fichier du dossier web standard: $WEB_PATH"
        rm -f "$WEB_PATH" 2>/dev/null || sudo rm -f "$WEB_PATH" 2>/dev/null
        
        if [ $? -ne 0 ]; then
            log "Erreur lors de la suppression du fichier du dossier web standard"
            SUCCESS=1
        else
            log "Fichier supprimé avec succès du dossier web standard"
        fi
    fi
    
    # 3. Supprimer du dossier local
    LOCAL_PATH="$LOCAL_IMG_DIR/$FILENAME"
    if [ -f "$LOCAL_PATH" ]; then
        log "Suppression du fichier local: $LOCAL_PATH"
        rm -f "$LOCAL_PATH" 2>/dev/null
        
        if [ $? -ne 0 ]; then
            log "Erreur lors de la suppression du fichier local"
            SUCCESS=1
        else
            log "Fichier local supprimé avec succès"
        fi
    else
        log "Le fichier local n'existe pas: $LOCAL_PATH"
    fi
    
    return $SUCCESS
}

# Exécution principale
# Supprimer des répertoires locaux
delete_local_files
LOCAL_DELETE_SUCCESS=$?

# Afficher un résumé
log "Résumé de la suppression pour $FILENAME:"
if [ $LOCAL_DELETE_SUCCESS -eq 0 ]; then
    log "- Suppression des fichiers locaux: Réussi"
    log "Suppression de l'image terminée avec succès"
    exit 0
else
    log "- Suppression des fichiers locaux: Échec"
    log "Suppression de l'image terminée avec des erreurs"
    exit 1
fi
