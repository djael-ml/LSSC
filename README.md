# 🧹 LSSC - Linux Storage Space Cleaner

<div align="center">


![Version](https://img.shields.io/badge/version-1.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Bash](https://img.shields.io/badge/bash-5.0+-orange.svg)

**Le nettoyeur ultime pour votre système Linux**

Libérez de l'espace disque en quelques secondes sur toutes vos partitions !

</div>

---

## 🚀 Installation et Utilisation Rapide

**Une seule commande pour tout faire :**

```bash
curl -fsSL https://raw.githubusercontent.com/djael-ml/LSSC/main/install.sh | sudo bash
```

Ou si vous préférez avec `wget` :

```bash
wget -qO- https://raw.githubusercontent.com/djael-ml/LSSC/main/install.sh | sudo bash
```

**Installation manuelle :**

```bash
git clone https://github.com/djael-ml/LSSC.git
cd lssc
chmod +x lssc.sh
sudo ./lssc.sh
```

---

## ✨ Fonctionnalités

- 🔍 **Détection automatique** de votre distribution Linux
- 🗂️ **Nettoyage complet** de toutes les partitions (pas seulement `/`)
- 📦 **Gestion des paquets** : APT, Pacman, DNF/YUM, Zypper
- 📝 **Journaux système** : Nettoyage intelligent avec systemd
- 🐧 **Anciens noyaux** : Suppression automatique des versions obsolètes
- 💾 **Caches utilisateurs** : Firefox, Chrome, Brave, Thumbnails, Ollama
- 🐳 **Docker, Flatpak, Snap** : Nettoyage des conteneurs et paquets inutilisés
- 📊 **Analyse détaillée** : Visualisation de l'espace sur toutes les partitions
- 🎨 **Interface colorée** : Menu interactif facile à utiliser
- ⚡ **Outils avancés** : Installation automatique de `ncdu` et `bleachbit` si nécessaire

---

## 🎯 Distributions Supportées

| Distribution                 | Status | Gestionnaire de paquets |
| ---------------------------- | ------ | ----------------------- |
| Debian / Ubuntu / Mint       | ✅      | APT                     |
| Arch / Manjaro / EndeavourOS | ✅      | Pacman                  |
| Fedora / RHEL / CentOS       | ✅      | DNF/YUM                 |
| openSUSE / SUSE              | ✅      | Zypper                  |

---

## 📋 Ce qui est nettoyé

### 🗑️ Nettoyage Système

- Cache des gestionnaires de paquets (APT, Pacman, DNF, Zypper)
- Anciens noyaux Linux (garde le noyau actuel + 1 de secours)
- Journaux système (logs de plus de 7 jours)
- Fichiers temporaires sur toutes les partitions (`/tmp`, `/var/tmp`)
- Fichiers swap d'édition (`.swp`, `.swo`, `~`)

### 👤 Nettoyage Utilisateur

- Cache général (`~/.cache`)
- Corbeille (`~/.local/share/Trash`)
- Vignettes d'images (`~/.thumbnails`, `~/.cache/thumbnails`)
- Cache des navigateurs (Firefox, Chrome, Chromium, Brave)
- Modèles Ollama (`~/.ollama`)

### 🐳 Outils Tiers

- Images et conteneurs Docker inutilisés
- Paquets Flatpak obsolètes
- Anciennes versions Snap

---

## 🛡️ Sécurité

**Ce qui N'EST JAMAIS touché :**

- ❌ Configurations d'applications (`~/.config`)
- ❌ Documents utilisateurs
- ❌ Bases de données
- ❌ Fichiers de paramètres personnalisés
- ❌ Données importantes

Le script est conçu pour être **100% sûr** et ne supprime que les fichiers temporaires et caches.

---

## 📖 Options du Menu

```
1) Nettoyage COMPLET (toutes partitions - recommandé)
2) Paquets uniquement
3) Journaux système uniquement
4) Anciens noyaux uniquement
5) Caches utilisateurs uniquement
6) Vignettes et caches graphiques
7) Caches navigateurs
8) Fichiers temporaires (toutes partitions)
9) Tout sauf les caches utilisateurs
A) Analyser l'espace disque (toutes partitions)
0) Quitter
```

---

## 🔧 Utilisation Avancée

### Mode Silencieux (sans interaction)

```bash
sudo ./lssc.sh --auto
```

### Nettoyage avec outils avancés

```bash
sudo ./lssc.sh --deep
```

Installe temporairement `ncdu` (analyseur d'espace) et `bleachbit` (nettoyeur avancé) puis les supprime après usage.

### Analyse uniquement (pas de suppression)

```bash
sudo ./lssc.sh --analyze
```

---

## 📊 Exemple de Sortie

```
╔════════════════════════════════════════════╗
║   LSSC - Linux Storage Space Cleaner      ║
║            Version 1.0                     ║
╚════════════════════════════════════════════╝

════════════════════════════════════════════════════════════════
Filesystem      Type   Size  Used Avail Use% Mounted on
/dev/sda5       ext4   9.4G  8.3G  693M  93% /
/dev/sda6       ext4    50G   15G   32G  32% /home
════════════════════════════════════════════════════════════════

[✓] Cache APT nettoyé
[✓] Journaux systemd nettoyés (conservés : 7 jours / 100MB max)
[✓] Anciens noyaux supprimés
[✓] Cache de user supprimé (450MB)
[✓] Corbeille de user vidée
[✓] Modèles Ollama supprimés (8500MB)

╔════════════════════════════════════════════╗
║         NETTOYAGE TERMINÉ !                ║
╚════════════════════════════════════════════╝

[✓] Espace libéré : 12 GB (12450 MB)

💡 Astuce : Relancez LSSC régulièrement pour maintenir votre système propre !
```

---

## 🤝 Contribution

Les contributions sont les bienvenues ! N'hésitez pas à :

- 🐛 Signaler des bugs
- 💡 Proposer de nouvelles fonctionnalités
- 🔧 Soumettre des pull requests

---

## 📝 Licence

MIT License - Libre d'utilisation, modification et distribution

---

## ⚠️ Avertissement

Bien que ce script soit conçu pour être sûr, il est recommandé de :

- Faire une sauvegarde avant la première utilisation
- Vérifier ce qui sera supprimé
- Ne pas interrompre le processus en cours

**Utilisez toujours avec `sudo` pour un nettoyage complet du système.**

---

## 🌟 Remerciements

Merci à tous les contributeurs et utilisateurs de LSSC !

Si ce projet vous a aidé, n'oubliez pas de lui donner une ⭐ sur GitHub !

---

<div align="center">


**Fait avec ❤️ pour la communauté Linux**

[Signaler un bug](https://github.com/VOTRE_USERNAME/lssc/issues) • [Documentation](https://github.com/VOTRE_USERNAME/lssc/wiki)

</div>
