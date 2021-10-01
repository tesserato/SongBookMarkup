flutter pub run flutter_launcher_icons:main

# flutter build windows
# flutter pub run msix:create

# flutter build web --release
# firebase deploy

# az storage blob service-properties update --static-website --index-document "index.html" --account-name "markbookapp"

# az storage blob upload-batch -s ".\build\web\" -d '$web' --account-name "markbookapp" --content-type 'text/html; charset=utf-8'

# az storage account show -n "markbookapp" -g "MarkBook" --query "primaryEndpoints.web" --output tsv

flutter build apk --release