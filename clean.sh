#!/bin/bash
echo "🧹 Nettoyage complet du système..."

echo "📦 Nettoyage des paquets..."
sudo apt autoremove --purge -y
sudo apt autoclean -y
sudo apt clean -y

echo "📝 Nettoyage des logs..."
sudo journalctl --vacuum-time=3d

echo "🗑️ Nettoyage du cache utilisateur..."
rm -rf ~/.cache/*
rm -rf ~/.thumbnails/*

echo "📊 Espace disque disponible:"
df -h /

echo "✅ Nettoyage terminé!"
