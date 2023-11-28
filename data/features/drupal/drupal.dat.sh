#!/usr/bin/env bash
drupal_name="Drupal"
drupal_description="Web CMS"
drupal_version="9.2.10"
drupal_tags=("web")
drupal_systemcategories=("CMS" "Web" "WebDevelopment")

drupal_packagedependencies=("php-dom" "php-gd")
drupal_downloadKeys=("bundle")
drupal_bundle_URL="https://ftp.drupal.org/files/projects/drupal-9.2.10.tar.gz"
drupal_bundle_downloadPath="/var/www/html"
drupal_bashfunctions=("silentFunction")
drupal_launcherkeynames="default"
drupal_default_exec="xdg-open http://localhost/drupal"
drupal_manualcontentavailable="0;0;1"
