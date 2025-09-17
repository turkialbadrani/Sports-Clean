# سكربت سحب ورفع ملف players_ar.json من/إلى المحاكي
# يستخدم المسار الكامل للـ adb.exe

$ADB = "C:\Users\Tbadar\AppData\Local\Android\Sdk\platform-tools\adb.exe"
$PKG = "com.example.today_smart"
$LOCAL_FILE = "players_ar.json"
$REMOTE_FILE = "/data/data/$PKG/files/players_ar.json"

Write-Output "📥 سحب الملف من المحاكي..."
& $ADB shell run-as $PKG cat files/players_ar.json > $LOCAL_FILE

if (Test-Path $LOCAL_FILE) {
    Write-Output "✅ الملف انحفظ محلي: $LOCAL_FILE"
} else {
    Write-Output "❌ فشل تحميل الملف"
    exit 1
}

Write-Output "`n✍️ افتح الملف $LOCAL_FILE، عدله، وبعد ما تخلص اضغط Enter للرفع..."
Read-Host | Out-Null

Write-Output "📤 رفع الملف المعدل للمحاكي..."
& $ADB push $LOCAL_FILE $REMOTE_FILE | Out-Null

Write-Output "✅ تمت العملية بنجاح"
