#!/bin/bash
# Скрипт для обновления базы guiNDB.db в v2rayN (macOS)

set -e

# === Настройки ===
REPO_URL="https://raw.githubusercontent.com/thepetrfreys/therigavpn/main/client_cfg/guiNDB.db"
TARGET_DIR="$HOME/Library/Application Support/v2rayN/guiConfigs"
TARGET_FILE="$TARGET_DIR/guiNDB.db"

echo "🚀 Обновление базы guiNDB.db..."

# Проверка существования директории
if [ ! -d "$TARGET_DIR" ]; then
  echo "❌ Директория $TARGET_DIR не найдена. Создаю..."
  mkdir -p "$TARGET_DIR"
fi

# Скачивание файла
echo "⬇️  Скачиваю базу из $REPO_URL"
curl -L -o "$TARGET_FILE" "$REPO_URL"

# Проверка успешности
if [ $? -eq 0 ]; then
  echo "✅ База успешно обновлена: $TARGET_FILE"
else
  echo "❌ Ошибка при скачивании файла!"
  exit 1
fi
