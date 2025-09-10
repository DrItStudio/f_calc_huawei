# Поиск пути к keytool
$jdkPaths = @(
    "C:\Program Files\Android\Android Studio\jre\bin",
    "C:\Program Files\Android\Android Studio\jbr\bin",
    "C:\Program Files\Java\jdk*\bin",
    "${env:LOCALAPPDATA}\Android\Sdk\jdk\*\bin",
    "${env:PROGRAMFILES}\Android\Android Studio\jbr\bin"
)

$keytoolPath = $null

foreach ($path in $jdkPaths) {
    $possiblePaths = Resolve-Path -Path $path -ErrorAction SilentlyContinue
    if ($possiblePaths) {
        foreach ($possiblePath in $possiblePaths) {
            $testPath = Join-Path -Path $possiblePath -ChildPath "keytool.exe"
            if (Test-Path $testPath) {
                $keytoolPath = $testPath
                break
            }
        }
    }
    if ($keytoolPath) { break }
}

if ($keytoolPath) {
    Write-Host "Найден keytool: $keytoolPath"
    
    # Создание keystore
    $keystorePath = "android-keys\huawei-keystore.jks"
    
    & $keytoolPath -genkey -v -keystore $keystorePath -alias huawei_key -keyalg RSA -keysize 2048 -validity 10000
} else {
    Write-Host "Не удалось найти keytool. Установите Java JDK или укажите путь вручную."
}
