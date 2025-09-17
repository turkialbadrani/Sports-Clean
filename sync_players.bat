#!/bin/bash

PKG="com.example.today_smart"
LOCAL_FILE="players_ar.json"
REMOTE_DIR="/data/data/$PKG/files"
REMOTE_FILE="$REMOTE_DIR/players_ar.json"

echo "📥 سحب الملف من المحاكي..."
adb shell run-as $PKG cat files/players_ar.json > $LOCAL_FILE

if [ -f "$LOCAL_FILE" ]; then
  echo "✅ الملف انحفظ محلي: $LOCAL_FILE"
else
  echo "❌ فشل تحميل الملف"
  exit 1
fi

echo ""
echo "✍️ افتح الملف، عدله، وبعد ما تخلص اضغط Enter للرفع..."
read

echo "📤 رفع الملف المعدل للمحاكي..."
adb push $LOCAL_FILE $REMOTE_FILE

echo "✅ تمت العملية"
