# Скрипт для подготовки ключа для Huawei AppGallery

# Настройки
$keystore = "huawei-keystore.jks"
$alias = "upload"
$keystorePassword = "4256942569"
$outputZip = "huawei-key.zip"
$encryptionKey = "034200041E224EE22B45D19B23DB91BA9F52DE0A06513E03A5821409B34976FDEED6E0A47DBA48CC249DD93734A6C5D9A0F43461F9E140F278A5D2860846C2CF5D2C3C02"

# Загрузка pepk.jar, если его нет
if (-not (Test-Path "pepk.jar")) {
    Write-Host "Загрузка pepk.jar..."
    $url = "https://github.com/google/play-core-publisher/raw/master/pepk.jar"
    
    try {
        Invoke-WebRequest -Uri $url -OutFile "pepk.jar" -UseBasicParsing
    } catch {
        Write-Host "Не удалось загрузить pepk.jar: $_"
        exit 1
    }
}

# Проверка наличия Java
$javaPath = "D:\program\jdk-17.0.15+6\bin\java.exe"
if (-not (Test-Path $javaPath)) {
    Write-Host "Java не найдена по пути $javaPath"
    exit 1
}

# Создание зашифрованного архива ключа
Write-Host "Создание зашифрованного архива ключа..."
& $javaPath -jar "pepk.jar" --keystore $keystore --alias $alias --output=$outputZip --encryptionkey=$encryptionKey --include-cert --key-pass=$keystorePassword --ks-pass=$keystorePassword

if ($LASTEXITCODE -eq 0) {
    Write-Host "Успешно создан файл $outputZip"
    Write-Host "Загрузите этот файл в AppGallery Connect как ключ подписи (метод 2)"
} else {
    Write-Host "Ошибка при создании зашифрованного архива ключа"
}

# Создание сертификата для ключа загрузки (опционально)
Write-Host "Создание сертификата для ключа загрузки..."
$keytoolPath = "D:\program\jdk-17.0.15+6\bin\keytool.exe"
& $keytoolPath -export -rfc -keystore $keystore -alias $alias -file "upload_certificate.pem" -storepass $keystorePassword

if ($LASTEXITCODE -eq 0) {
    Write-Host "Успешно создан сертификат upload_certificate.pem"
    Write-Host "При необходимости загрузите его в AppGallery Connect как ключ загрузки"
} else {
    Write-Host "Ошибка при создании сертификата ключа загрузки"
}
