#!/bin/bash

# LSSC - Linux Storage Space Cleaner
# Script d'installation rapide
# Version: 1.0

set -e

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Variables
GITHUB_REPO="VOTRE_USERNAME/lssc"
GITHUB_BRANCH="main"
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="lssc"

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_header() {
    clear
    echo -e "${GREEN}"
    cat << "EOF"
╔════════════════════════════════════════════════════════╗
║                                                        ║
║     LSSC - Linux Storage Space Cleaner v1.0           ║
║                                                        ║
║     Installation automatique                          ║
║                                                        ║
╚════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
}

# Vérification des privilèges root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_error "Ce script nécessite les privilèges root (sudo)"
        echo ""
        print_info "Relancez avec :"
        echo -e "  ${CYAN}curl -fsSL https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/install.sh | sudo bash${NC}"
        echo ""
        exit 1
    fi
}

# Vérification des dépendances
check_dependencies() {
    print_info "Vérification des dépendances..."
    
    local missing_deps=()
    
    if ! command -v curl &> /dev/null && ! command -v wget &> /dev/null; then
        missing_deps+=("curl ou wget")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        print_error "Dépendances manquantes : ${missing_deps[*]}"
        print_info "Installez les dépendances et réessayez"
        exit 1
    fi
    
    print_success "Toutes les dépendances sont présentes"
}

# Détection de la distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        print_info "Distribution détectée : $DISTRO"
    else
        print_warning "Distribution non identifiée"
        DISTRO="unknown"
    fi
}

# Téléchargement du script principal
download_lssc() {
    print_info "Téléchargement de LSSC depuis GitHub..."
    
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    LSSC_URL="https://raw.githubusercontent.com/$GITHUB_REPO/$GITHUB_BRANCH/lssc.sh"
    
    # Essai avec curl
    if command -v curl &> /dev/null; then
        if curl -fsSL "$LSSC_URL" -o lssc.sh; then
            print_success "Téléchargement réussi avec curl"
        else
            print_error "Échec du téléchargement avec curl"
            cleanup
            exit 1
        fi
    # Sinon essai avec wget
    elif command -v wget &> /dev/null; then
        if wget -q "$LSSC_URL" -O lssc.sh; then
            print_success "Téléchargement réussi avec wget"
        else
            print_error "Échec du téléchargement avec wget"
            cleanup
            exit 1
        fi
    else
        print_error "Impossible de télécharger : curl et wget non disponibles"
        cleanup
        exit 1
    fi
    
    # Vérification du fichier téléchargé
    if [ ! -s lssc.sh ]; then
        print_error "Le fichier téléchargé est vide ou corrompu"
        cleanup
        exit 1
    fi
    
    chmod +x lssc.sh
}

# Installation dans le système
install_system() {
    print_info "Installation de LSSC dans le système..."
    
    # Création du répertoire si nécessaire
    if [ ! -d "$INSTALL_DIR" ]; then
        mkdir -p "$INSTALL_DIR"
    fi
    
    # Sauvegarde si une version existe déjà
    if [ -f "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        print_warning "Une version de LSSC existe déjà"
        cp "$INSTALL_DIR/$SCRIPT_NAME" "$INSTALL_DIR/${SCRIPT_NAME}.backup"
        print_info "Ancienne version sauvegardée : ${SCRIPT_NAME}.backup"
    fi
    
    # Copie du script
    cp lssc.sh "$INSTALL_DIR/$SCRIPT_NAME"
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    
    # Vérification de l'installation
    if [ -x "$INSTALL_DIR/$SCRIPT_NAME" ]; then
        print_success "LSSC installé avec succès dans $INSTALL_DIR/$SCRIPT_NAME"
    else
        print_error "Échec de l'installation"
        cleanup
        exit 1
    fi
}

# Vérification que la commande est accessible
verify_installation() {
    print_info "Vérification de l'installation..."
    
    if command -v $SCRIPT_NAME &> /dev/null; then
        print_success "La commande '$SCRIPT_NAME' est accessible depuis n'importe où"
    else
        print_warning "$INSTALL_DIR n'est peut-être pas dans votre PATH"
        print_info "Vous pouvez l'utiliser avec : sudo $INSTALL_DIR/$SCRIPT_NAME"
    fi
}

# Affichage du résumé
show_summary() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                        ║${NC}"
    echo -e "${GREEN}║          ✓  INSTALLATION TERMINÉE AVEC SUCCÈS          ║${NC}"
    echo -e "${GREEN}║                                                        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    print_success "LSSC est maintenant installé sur votre système !"
    echo ""
    
    print_info "📚 Utilisation :"
    echo -e "  ${CYAN}sudo lssc${NC}                 # Mode interactif"
    echo -e "  ${CYAN}sudo lssc --auto${NC}          # Nettoyage automatique complet"
    echo -e "  ${CYAN}sudo lssc --deep${NC}          # Nettoyage profond avec outils avancés"
    echo -e "  ${CYAN}sudo lssc --analyze${NC}       # Analyser l'espace disque"
    echo -e "  ${CYAN}sudo lssc --help${NC}          # Afficher l'aide"
    echo ""
}

# Demande de lancement immédiat
ask_run() {
    read -p "$(echo -e ${CYAN}Voulez-vous lancer LSSC maintenant ? [O/n] :${NC} )" choice
    choice=${choice:-O}
    
    if [[ $choice =~ ^[OoYy]$ ]]; then
        echo ""
        print_info "Lancement de LSSC..."
        echo ""
        sleep 1
        "$INSTALL_DIR/$SCRIPT_NAME"
    else
        echo ""
        print_info "Vous pouvez lancer LSSC quand vous voulez avec : sudo lssc"
        echo ""
    fi
}

# Nettoyage des fichiers temporaires
cleanup() {
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        cd /
        rm -rf "$TEMP_DIR"
    fi
}

# Gestion des erreurs
error_handler() {
    print_error "Une erreur s'est produite durant l'installation"
    cleanup
    exit 1
}

trap error_handler ERR
trap cleanup EXIT

# Programme principal
main() {
    print_header
    
    # Vérifications préalables
    check_root
    detect_distro
    check_dependencies
    
    echo ""
    
    # Installation
    download_lssc
    install_system
    verify_installation
    
    # Nettoyage
    cleanup
    
    # Résumé
    show_summary
    
    # Proposition de lancement
    ask_run
    
    echo -e "${GREEN}Merci d'utiliser LSSC ! 🚀${NC}\n"
}

# Lancement
main "$@"
