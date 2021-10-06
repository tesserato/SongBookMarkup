## Update android and ios icons
# flutter pub run flutter_launcher_icons:main





## WINDOWS
# flutter build windows
exit

flutter build web --release
firebase deploy

# az storage blob service-properties update --static-website --index-document "index.html" --account-name "markbookapp"

az storage blob upload-batch -s ".\build\web\" -d '$web' --account-name "markbookapp" --content-type 'text/html; charset=utf-8'
az storage account show -n "markbookapp" -g "MarkBook" --query "primaryEndpoints.web" --output tsv

# flutter build apk --release






######################################################
######################## msix ########################
# $cert = New-SelfSignedCertificate -Type Custom -Subject "CN=Tesserato Software, O=Tesserato Corporation, C=BR" -KeyUsage DigitalSignature -FriendlyName "Mark Book installer certificate" -CertStoreLocation "Cert:\CurrentUser\My" -TextExtension @("2.5.29.37={text}1.3.6.1.5.5.7.3.3", "2.5.29.19={text}")

# $password = ConvertTo-SecureString -String "1984" -Force -AsPlainText 
# Export-PfxCertificate -cert ("Cert:\CurrentUser\My\" + $cert.thumbprint) -FilePath "cert.pfx" -Password $password
# flutter pub run msix:create
######################################################
######################################################
