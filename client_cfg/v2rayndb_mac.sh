#!/bin/bash
# Скрипт для обновления guiNDB.db и guiNConfig.json в v2rayN (macOS)

set -e

# === Настройки ===
BASE_URL="https://raw.githubusercontent.com/thepetrfreys/therigavpn/main/client_cfg/"
TARGET_DIR="$HOME/Library/Application Support/v2rayN/guiConfigs"

FILES=("guiNDB.db" "guiNConfig.json")

echo "===== Установка конфигурации v2rayN ====="

# Проверка существования директории
if [ ! -d "$TARGET_DIR" ]; then
  echo "📂 Директория $TARGET_DIR не найдена. Создаю..."
  mkdir -p "$TARGET_DIR"
fi

# Скачивание файлов
for file in "${FILES[@]}"; do
  echo "⬇️  Скачиваю $file..."
  curl -fsSL -o "$TARGET_DIR/$file" "$BASE_URL/$file"
  if [ $? -eq 0 ]; then
    echo "✅ $file успешно обновлён."
  else
    echo "❌ Ошибка при скачивании $file!"
    exit 1
  fi
done

echo "===== Установка конфигурации завершена ====="
