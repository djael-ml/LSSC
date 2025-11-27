#!/bin/bash

# LSSC - Linux Storage Space Cleaner
# Nettoyage complet du système Linux (toutes partitions)
# Compatible : Debian/Ubuntu, Arch/Manjaro, Fedora/RHEL, openSUSE
# Version: 1.0

set -e

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables globales
DEEP_CLEAN=false
AUTO_MODE=false
ANALYZE_ONLY=false
TOOLS_INSTALLED=()

# Gestion des arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --deep)
                DEEP_CLEAN=true
                shift
                ;;
            --auto)
                AUTO_MODE=true
                shift
                ;;
            --analyze)
                ANALYZE_ONLY=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                shift
                ;;
        esac
    done
}

# Affichage de l'aide
show_help() {
    echo "LSSC - Linux Storage Space Cleaner"
    echo ""
    echo "Usage: sudo lssc [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --deep      Nettoyage profond (installe ncdu et bleachbit temporairement)"
    echo "  --auto      Mode automatique (nettoyage complet sans interaction)"
    echo "  --analyze   Analyse uniquement (pas de suppression)"
    echo "  --help, -h  Affiche cette aide"
    echo ""
    echo "Exemples:"
    echo "  sudo lssc                # Mode interactif (défaut)"
    echo "  sudo lssc --auto         # Nettoyage complet automatique"
    echo "  sudo lssc --deep         # Nettoyage avec outils avancés"
    echo "  sudo lssc --analyze      # Analyse de l'espace disque"
}

# Couleurs pour l'affichage
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction pour afficher des messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Fonction pour afficher l'espace disque de toutes les partitions
show_disk_space() {
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════════${NC}"
    df -h --output=source,fstype,size,used,avail,pcent,target | grep -E '^(/dev/|Filesystem)' | grep -v tmpfs | grep -v loop
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"
}

# Fonction pour obtenir l'utilisation totale du disque
get_total_disk_usage() {
    df --output=used | grep -v 'Used' | awk '{sum+=$1} END {print sum}'
}

# Fonction pour calculer l'espace libéré
calculate_freed_space() {
    local before=$1
    local after=$2
    local freed=$((before - after))
    echo $freed
}

# Détection de la distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        DISTRO_LIKE=$ID_LIKE
    elif [ -f /etc/debian_version ]; then
        DISTRO="debian"
    elif [ -f /etc/arch-release ]; then
        DISTRO="arch"
    elif [ -f /etc/fedora-release ]; then
        DISTRO="fedora"
    else
        DISTRO="unknown"
    fi
    
    print_info "Distribution détectée : $DISTRO"
}

# Installation d'outils avancés temporaires
install_advanced_tools() {
    if [ "$DEEP_CLEAN" = false ]; then
        return
    fi
    
    print_info "Installation d'outils avancés pour nettoyage profond..."
    
    case $DISTRO in
        debian|ubuntu|mint|pop)
            if ! command -v ncdu &> /dev/null; then
                apt-get install -y ncdu -qq > /dev/null 2>&1
                TOOLS_INSTALLED+=("ncdu")
                print_success "ncdu installé"
            fi
            if ! command -v bleachbit &> /dev/null; then
                apt-get install -y bleachbit -qq > /dev/null 2>&1
                TOOLS_INSTALLED+=("bleachbit")
                print_success "bleachbit installé"
            fi
            ;;
            
        arch|manjaro|endeavouros)
            if ! command -v ncdu &> /dev/null; then
                pacman -S --noconfirm ncdu > /dev/null 2>&1
                TOOLS_INSTALLED+=("ncdu")
                print_success "ncdu installé"
            fi
            if ! command -v bleachbit &> /dev/null; then
                pacman -S --noconfirm bleachbit > /dev/null 2>&1
                TOOLS_INSTALLED+=("bleachbit")
                print_success "bleachbit installé"
            fi
            ;;
            
        fedora|rhel|centos|rocky|almalinux)
            if ! command -v ncdu &> /dev/null; then
                dnf install -y ncdu -q > /dev/null 2>&1
                TOOLS_INSTALLED+=("ncdu")
                print_success "ncdu installé"
            fi
            if ! command -v bleachbit &> /dev/null; then
                dnf install -y bleachbit -q > /dev/null 2>&1
                TOOLS_INSTALLED+=("bleachbit")
                print_success "bleachbit installé"
            fi
            ;;
    esac
}

# Suppression des outils temporaires
remove_advanced_tools() {
    if [ ${#TOOLS_INSTALLED[@]} -eq 0 ]; then
        return
    fi
    
    print_info "Suppression des outils temporaires..."
    
    case $DISTRO in
        debian|ubuntu|mint|pop)
            for tool in "${TOOLS_INSTALLED[@]}"; do
                apt-get purge -y "$tool" -qq > /dev/null 2>&1
                print_success "$tool supprimé"
            done
            apt-get autoremove -y -qq > /dev/null 2>&1
            ;;
            
        arch|manjaro|endeavouros)
            for tool in "${TOOLS_INSTALLED[@]}"; do
                pacman -Rns --noconfirm "$tool" > /dev/null 2>&1
                print_success "$tool supprimé"
            done
            ;;
            
        fedora|rhel|centos|rocky|almalinux)
            for tool in "${TOOLS_INSTALLED[@]}"; do
                dnf remove -y "$tool" -q > /dev/null 2>&1
                print_success "$tool supprimé"
            done
            ;;
    esac
}

# Nettoyage profond avec BleachBit
deep_clean_with_bleachbit() {
    if [ "$DEEP_CLEAN" = false ] || ! command -v bleachbit &> /dev/null; then
        return
    fi
    
    print_info "Nettoyage profond avec BleachBit..."
    
    # Liste des nettoyeurs à utiliser
    bleachbit --clean \
        system.cache \
        system.tmp \
        system.trash \
        apt.autoclean \
        apt.clean \
        thumbnails.cache \
        firefox.cache \
        chromium.cache \
        > /dev/null 2>&1 || true
    
    print_success "Nettoyage BleachBit terminé"
}

# Vérification des privilèges root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        print_warning "Ce script nécessite les privilèges root pour certaines opérations."
        print_warning "Relancez avec : sudo $0"
        exit 1
    fi
}

# Sauvegarde de l'espace initial
get_disk_usage() {
    get_total_disk_usage
}

# Nettoyage des paquets selon la distribution
clean_packages() {
    print_info "Nettoyage des paquets..."
    
    case $DISTRO in
        debian|ubuntu|mint|pop)
            print_info "Nettoyage APT..."
            apt-get clean -y
            apt-get autoclean -y
            apt-get autoremove --purge -y
            print_success "Cache APT nettoyé"
            ;;
            
        arch|manjaro|endeavouros)
            print_info "Nettoyage Pacman..."
            pacman -Sc --noconfirm
            pacman -Rns $(pacman -Qtdq) --noconfirm 2>/dev/null || true
            if command -v paccache &> /dev/null; then
                paccache -rk 2
            fi
            print_success "Cache Pacman nettoyé"
            ;;
            
        fedora|rhel|centos|rocky|almalinux)
            print_info "Nettoyage DNF/YUM..."
            if command -v dnf &> /dev/null; then
                dnf clean all -y
                dnf autoremove -y
            else
                yum clean all -y
                yum autoremove -y
            fi
            print_success "Cache DNF/YUM nettoyé"
            ;;
            
        opensuse*|suse)
            print_info "Nettoyage Zypper..."
            zypper clean --all
            zypper packages --unneeded | awk -F'|' 'NR>5 {print $3}' | xargs -r zypper remove --clean-deps -y
            print_success "Cache Zypper nettoyé"
            ;;
            
        *)
            print_warning "Distribution non reconnue pour le nettoyage des paquets"
            ;;
    esac
}

# Nettoyage des journaux système
clean_logs() {
    print_info "Nettoyage des journaux système..."
    
    # Journalctl (systemd)
    if command -v journalctl &> /dev/null; then
        journalctl --vacuum-time=7d
        journalctl --vacuum-size=100M
        print_success "Journaux systemd nettoyés (conservés : 7 jours / 100MB max)"
    fi
    
    # Anciens logs
    find /var/log -type f -name "*.log.*" -delete 2>/dev/null || true
    find /var/log -type f -name "*.gz" -delete 2>/dev/null || true
    find /var/log -type f -name "*.old" -delete 2>/dev/null || true
    
    # Vide les logs actifs (garde le fichier)
    find /var/log -type f -name "*.log" -exec truncate -s 0 {} \; 2>/dev/null || true
    
    print_success "Anciens fichiers de logs supprimés"
}

# Nettoyage des anciens noyaux
clean_old_kernels() {
    print_info "Nettoyage des anciens noyaux..."
    
    case $DISTRO in
        debian|ubuntu|mint|pop)
            CURRENT_KERNEL=$(uname -r)
            print_info "Noyau actuel : $CURRENT_KERNEL"
            
            # Liste les anciens noyaux
            OLD_KERNELS=$(dpkg --list | grep linux-image | awk '{print $2}' | grep -v "$CURRENT_KERNEL" || true)
            
            if [ -n "$OLD_KERNELS" ]; then
                echo "$OLD_KERNELS" | xargs apt-get purge -y
                print_success "Anciens noyaux supprimés"
            else
                print_info "Aucun ancien noyau à supprimer"
            fi
            ;;
            
        arch|manjaro|endeavouros)
            print_info "Sur Arch, utilisez manuellement : pacman -R linux-lts (si non utilisé)"
            ;;
            
        fedora|rhel|centos|rocky|almalinux)
            if command -v dnf &> /dev/null; then
                dnf remove $(dnf repoquery --installonly --latest-limit=-2 -q) -y 2>/dev/null || true
            else
                package-cleanup --oldkernels --count=2 -y 2>/dev/null || true
            fi
            print_success "Anciens noyaux supprimés"
            ;;
    esac
}

# Nettoyage des caches utilisateurs (ne touche pas aux configs)
clean_user_caches() {
    print_info "Nettoyage des caches utilisateurs..."
    
    # Pour chaque utilisateur avec un home
    for USER_HOME in /home/*; do
        if [ -d "$USER_HOME" ]; then
            USERNAME=$(basename "$USER_HOME")
            
            # Cache général
            if [ -d "$USER_HOME/.cache" ]; then
                CACHE_SIZE=$(du -sm "$USER_HOME/.cache" 2>/dev/null | awk '{print $1}')
                rm -rf "$USER_HOME/.cache"/*
                mkdir -p "$USER_HOME/.cache"
                chown -R $USERNAME:$USERNAME "$USER_HOME/.cache"
                print_success "Cache de $USERNAME nettoyé (${CACHE_SIZE}MB)"
            fi
            
            # Corbeille
            if [ -d "$USER_HOME/.local/share/Trash" ]; then
                rm -rf "$USER_HOME/.local/share/Trash"/*
                print_success "Corbeille de $USERNAME vidée"
            fi
            
            # Ollama (si présent)
            if [ -d "$USER_HOME/.ollama" ]; then
                OLLAMA_SIZE=$(du -sm "$USER_HOME/.ollama" 2>/dev/null | awk '{print $1}')
                rm -rf "$USER_HOME/.ollama"
                print_success "Modèles Ollama de $USERNAME supprimés (${OLLAMA_SIZE}MB)"
            fi
        fi
    done
    
    # Cache root
    if [ -d /root/.cache ]; then
        rm -rf /root/.cache/*
        print_success "Cache root nettoyé"
    fi
}

# Nettoyage des fichiers temporaires sur toutes les partitions montées
clean_temp_files() {
    print_info "Nettoyage des fichiers temporaires sur toutes les partitions..."
    
    # /tmp (garde la structure)
    find /tmp -type f -atime +7 -delete 2>/dev/null || true
    find /tmp -type d -empty -delete 2>/dev/null || true
    
    # /var/tmp
    find /var/tmp -type f -atime +7 -delete 2>/dev/null || true
    find /var/tmp -type d -empty -delete 2>/dev/null || true
    
    # Cherche sur toutes les partitions montées
    df --output=target | grep -v 'Mounted' | grep -v tmpfs | grep -v loop | while read MOUNTPOINT; do
        if [ -d "$MOUNTPOINT" ] && [ "$MOUNTPOINT" != "/" ]; then
            # Nettoyage des fichiers cachés temporaires
            find "$MOUNTPOINT" -maxdepth 3 -name ".cache-*" -type f -atime +30 -delete 2>/dev/null || true
            find "$MOUNTPOINT" -maxdepth 3 -name "*.tmp" -type f -atime +30 -delete 2>/dev/null || true
            find "$MOUNTPOINT" -maxdepth 3 -name "*.temp" -type f -atime +30 -delete 2>/dev/null || true
        fi
    done
    
    print_success "Fichiers temporaires nettoyés sur toutes les partitions"
}

# Nettoyage Docker (si installé)
clean_docker() {
    if command -v docker &> /dev/null; then
        print_info "Nettoyage Docker..."
        docker system prune -af --volumes 2>/dev/null || true
        print_success "Cache Docker nettoyé"
    fi
}

# Nettoyage Flatpak (si installé)
clean_flatpak() {
    if command -v flatpak &> /dev/null; then
        print_info "Nettoyage Flatpak..."
        flatpak uninstall --unused -y 2>/dev/null || true
        flatpak repair --user 2>/dev/null || true
        print_success "Flatpak nettoyé"
    fi
}

# Nettoyage Snap (si installé)
clean_snap() {
    if command -v snap &> /dev/null; then
        print_info "Nettoyage Snap..."
        LANG=C snap list --all | awk '/disabled/{print $1, $3}' | while read snapname revision; do
            snap remove "$snapname" --revision="$revision" 2>/dev/null || true
        done
        print_success "Anciennes versions Snap supprimées"
    fi
}

# Rapport des plus gros dossiers sur toutes les partitions
show_big_directories() {
    print_info "Analyse de l'espace disque sur toutes les partitions..."
    echo ""
    
    df --output=target | grep -v 'Mounted' | grep -v tmpfs | grep -v loop | while read MOUNTPOINT; do
        if [ -d "$MOUNTPOINT" ]; then
            echo -e "${YELLOW}Partition : $MOUNTPOINT${NC}"
            du -h "$MOUNTPOINT" --max-depth=2 2>/dev/null | sort -hr | head -10 | awk '{print "  "$0}'
            echo ""
        fi
    done
}

# Nettoyage des thumbnails et caches graphiques
clean_thumbnails() {
    print_info "Nettoyage des vignettes et caches graphiques..."
    
    for USER_HOME in /home/*; do
        if [ -d "$USER_HOME" ]; then
            USERNAME=$(basename "$USER_HOME")
            
            # Thumbnails
            if [ -d "$USER_HOME/.thumbnails" ]; then
                THUMB_SIZE=$(du -sm "$USER_HOME/.thumbnails" 2>/dev/null | awk '{print $1}')
                rm -rf "$USER_HOME/.thumbnails"/*
                print_success "Vignettes de $USERNAME supprimées (${THUMB_SIZE}MB)"
            fi
            
            if [ -d "$USER_HOME/.cache/thumbnails" ]; then
                THUMB_SIZE=$(du -sm "$USER_HOME/.cache/thumbnails" 2>/dev/null | awk '{print $1}')
                rm -rf "$USER_HOME/.cache/thumbnails"/*
                print_success "Cache thumbnails de $USERNAME supprimé (${THUMB_SIZE}MB)"
            fi
        fi
    done
    
    print_success "Vignettes et caches graphiques nettoyés"
}

# Nettoyage des fichiers de swap inutilisés
clean_swap_files() {
    print_info "Recherche de fichiers swap inutilisés..."
    
    # Cherche les fichiers swap sur toutes les partitions
    find / -type f \( -name "*.swp" -o -name "*.swo" -o -name "*~" \) -delete 2>/dev/null || true
    
    print_success "Fichiers swap temporaires supprimés"
}

# Nettoyage spécifique aux navigateurs
clean_browser_caches() {
    print_info "Nettoyage des caches navigateurs (anciens)..."
    
    for USER_HOME in /home/*; do
        if [ -d "$USER_HOME" ]; then
            USERNAME=$(basename "$USER_HOME")
            
            # Firefox
            if [ -d "$USER_HOME/.mozilla/firefox" ]; then
                find "$USER_HOME/.mozilla/firefox" -type d -name "cache2" -exec rm -rf {} \; 2>/dev/null || true
                print_success "Cache Firefox de $USERNAME nettoyé"
            fi
            
            # Chrome/Chromium
            for BROWSER in ".config/google-chrome" ".config/chromium" ".config/brave-browser"; do
                if [ -d "$USER_HOME/$BROWSER" ]; then
                    find "$USER_HOME/$BROWSER" -type d -name "Cache" -exec rm -rf {} \; 2>/dev/null || true
                    find "$USER_HOME/$BROWSER" -type d -name "Code Cache" -exec rm -rf {} \; 2>/dev/null || true
                fi
            done
        fi
    done
    
    print_success "Caches navigateurs nettoyés"
}

# Menu interactif
interactive_menu() {
    echo -e "\n${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   LSSC - Linux Storage Space Cleaner      ║${NC}"
    echo -e "${GREEN}║            Version 1.0                     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}\n"
    
    show_disk_space
    
    if [ "$DEEP_CLEAN" = true ]; then
        echo -e "${CYAN}🔧 Mode nettoyage profond activé${NC}"
        echo ""
    fi
    
    echo "Que souhaitez-vous nettoyer ?"
    echo ""
    echo "  1) Nettoyage COMPLET (toutes partitions - recommandé)"
    echo "  2) Paquets uniquement"
    echo "  3) Journaux système uniquement"
    echo "  4) Anciens noyaux uniquement"
    echo "  5) Caches utilisateurs uniquement"
    echo "  6) Vignettes et caches graphiques"
    echo "  7) Caches navigateurs"
    echo "  8) Fichiers temporaires (toutes partitions)"
    echo "  9) Tout sauf les caches utilisateurs"
    echo "  A) Analyser l'espace disque (toutes partitions)"
    echo "  0) Quitter"
    echo ""
    read -p "Votre choix [1] : " choice
    choice=${choice:-1}
    
    echo ""
    
    case $choice in
        1)
            SPACE_BEFORE=$(get_disk_usage)
            install_advanced_tools
            clean_packages
            clean_logs
            clean_old_kernels
            clean_user_caches
            clean_thumbnails
            clean_browser_caches
            clean_swap_files
            clean_temp_files
            clean_docker
            clean_flatpak
            clean_snap
            deep_clean_with_bleachbit
            remove_advanced_tools
            SPACE_AFTER=$(get_disk_usage)
            ;;
        2)
            SPACE_BEFORE=$(get_disk_usage)
            clean_packages
            SPACE_AFTER=$(get_disk_usage)
            ;;
        3)
            SPACE_BEFORE=$(get_disk_usage)
            clean_logs
            SPACE_AFTER=$(get_disk_usage)
            ;;
        4)
            SPACE_BEFORE=$(get_disk_usage)
            clean_old_kernels
            SPACE_AFTER=$(get_disk_usage)
            ;;
        5)
            SPACE_BEFORE=$(get_disk_usage)
            clean_user_caches
            SPACE_AFTER=$(get_disk_usage)
            ;;
        6)
            SPACE_BEFORE=$(get_disk_usage)
            clean_thumbnails
            SPACE_AFTER=$(get_disk_usage)
            ;;
        7)
            SPACE_BEFORE=$(get_disk_usage)
            clean_browser_caches
            SPACE_AFTER=$(get_disk_usage)
            ;;
        8)
            SPACE_BEFORE=$(get_disk_usage)
            clean_temp_files
            clean_swap_files
            SPACE_AFTER=$(get_disk_usage)
            ;;
        9)
            SPACE_BEFORE=$(get_disk_usage)
            install_advanced_tools
            clean_packages
            clean_logs
            clean_old_kernels
            clean_thumbnails
            clean_browser_caches
            clean_swap_files
            clean_temp_files
            clean_docker
            clean_flatpak
            clean_snap
            deep_clean_with_bleachbit
            remove_advanced_tools
            SPACE_AFTER=$(get_disk_usage)
            ;;
        [Aa])
            show_big_directories
            if command -v ncdu &> /dev/null; then
                echo ""
                read -p "Lancer ncdu pour une analyse interactive ? [o/N] : " ncdu_choice
                if [[ $ncdu_choice =~ ^[Oo]$ ]]; then
                    ncdu /
                fi
            fi
            exit 0
            ;;
        0)
            print_info "Annulation..."
            exit 0
            ;;
        *)
            print_error "Choix invalide"
            exit 1
            ;;
    esac
    
    # Affichage du résumé
    FREED=$(calculate_freed_space $SPACE_BEFORE $SPACE_AFTER)
    FREED_MB=$((FREED / 1024))
    FREED_GB=$((FREED_MB / 1024))
    
    echo -e "\n${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║         NETTOYAGE TERMINÉ !                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}\n"
    
    if [ $FREED_GB -gt 0 ]; then
        print_success "Espace libéré : ${FREED_GB} GB (${FREED_MB} MB)"
    else
        print_success "Espace libéré : ${FREED_MB} MB"
    fi
    
    show_disk_space
    
    print_info "💡 Astuce : Relancez LSSC régulièrement pour maintenir votre système propre !"
}

# Mode automatique
auto_clean() {
    print_info "Mode automatique : nettoyage complet en cours..."
    
    SPACE_BEFORE=$(get_disk_usage)
    install_advanced_tools
    clean_packages
    clean_logs
    clean_old_kernels
    clean_user_caches
    clean_thumbnails
    clean_browser_caches
    clean_swap_files
    clean_temp_files
    clean_docker
    clean_flatpak
    clean_snap
    deep_clean_with_bleachbit
    remove_advanced_tools
    SPACE_AFTER=$(get_disk_usage)
    
    # Résumé
    FREED=$(calculate_freed_space $SPACE_BEFORE $SPACE_AFTER)
    FREED_MB=$((FREED / 1024))
    FREED_GB=$((FREED_MB / 1024))
    
    echo -e "\n${GREEN}╔════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║    NETTOYAGE AUTOMATIQUE TERMINÉ !         ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}\n"
    
    if [ $FREED_GB -gt 0 ]; then
        print_success "Espace libéré : ${FREED_GB} GB (${FREED_MB} MB)"
    else
        print_success "Espace libéré : ${FREED_MB} MB"
    fi
    
    show_disk_space
}

# Programme principal
main() {
    parse_args "$@"
    detect_distro
    check_root
    
    if [ "$ANALYZE_ONLY" = true ]; then
        show_disk_space
        show_big_directories
        if [ "$DEEP_CLEAN" = true ]; then
            install_advanced_tools
            if command -v ncdu &> /dev/null; then
                print_info "Lancement de ncdu pour analyse interactive..."
                ncdu /
            fi
            remove_advanced_tools
        fi
        exit 0
    fi
    
    if [ "$AUTO_MODE" = true ]; then
        auto_clean
    else
        interactive_menu
    fi
}

main "$@"
