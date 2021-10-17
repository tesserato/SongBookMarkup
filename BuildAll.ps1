

$windows = $TRUE
$windows = $FALSE

$web = $TRUE
# $web = $FALSE

$android = $TRUE
$android = $FALSE

$upgrade = $TRUE
$upgrade = $FALSE

$icons = $TRUE
$icons = $FALSE


$config = $TRUE
$config = $FALSE

if ($config) {
  keytool.exe -genkey -v -keystore .\0LD\upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
}



if ($icons) {
  ## update in app image
  inkscape -w 192 -h 192 .\assets\icon.svg -o .\assets\images\icon.png
  # magick.exe convert -background none .\assets\icon.svg -define icon:auto-resize .\assets\images\icon.png

  ## Update android and ios icons (in app image)
  flutter pub run flutter_launcher_icons:main

  ## Windows Icon
  magick.exe convert -background none .\assets\icon.svg -define icon:auto-resize .\windows\runner\resources\app_icon.ico

  ## Web favicon
  inkscape -w 64 -h 64 .\assets\icon.svg -o .\web\favicon.png
  # magick.exe convert -background none .\assets\icon.svg -define icon:auto-resize .\web\favicon.png

  ## PWA icons
  inkscape -w 192 -h 192 .\assets\icon.svg -o .\web\icons\Icon-192.png
  inkscape -w 512 -h 512 .\assets\icon.svg -o .\web\icons\Icon-512.png

  magick.exe convert -background none .\web\icons\Icon-512.png -gravity center -resize 130x130 -extent 192x192 .\web\icons\Icon-maskable-192.png
  magick.exe convert -background none .\web\icons\Icon-512.png -gravity center -resize 350x350 -extent 512x512 .\web\icons\Icon-maskable-512.png
}

if ($upgrade) {
  flutter upgrade
  flutter pub upgrade
  flutter pub outdated
}

## WINDOWS
if ($windows) {
  flutter build windows --release
}

## WEB
if ($web) {
  try {
    flutter build web --release
  }
  catch {
    "VVVVVVVVVVVVV Web build failed VVVVVVVVVVVVV"
    $_
    ">>>>>>>>>>>> Web build failed <<<<<<<<<<<<<."
    exit
  } 
  
  ### firebase
  firebase deploy

  # az storage blob service-properties update --static-website --index-document "index.html" --account-name "markbookapp"

  ### azure
  az storage blob upload-batch -s ".\build\web\" -d '$web' --account-name "markbookapp" --content-type 'text/html; charset=utf-8'
  az storage account show -n "markbookapp" -g "MarkBook" --query "primaryEndpoints.web" --output tsv
}

## Android
if ($android) {
  flutter build apk --release
  flutter build appbundle --release
}






######################################################
######################## msix ########################
# $cert = New-SelfSignedCertificate -Type Custom -Subject "CN=Tesserato Software, O=Tesserato Corporation, C=BR" -KeyUsage DigitalSignature -FriendlyName "Mark Book installer certificate" -CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")

# $password = ConvertTo-SecureString -String "1984" -Force -AsPlainText 
# Export-PfxCertificate -cert ("Cert:\CurrentUser\My\" + $cert.thumbprint) -FilePath "cert.pfx" -Password $password
# flutter pub run msix:create
######################################################
######################################################
