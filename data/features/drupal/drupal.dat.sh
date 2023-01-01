#!/usr/bin/env bash
drupal_name="Drupal"
drupal_description="Web CMS"
drupal_version="9.2.10"
drupal_tags=("CMS" "web" "development")
drupal_systemcategories=("CMS" "WebDevelopment" "Web")

drupal_packagedependencies=("php-dom" "php-gd")
drupal_downloadKeys=("bundle")
drupal_bundle_URL="https://ftp.drupal.org/files/projects/drupal-9.2.10.tar.gz"
drupal_bundle_downloadPath="/var/www/html"
drupal_bashfunctions=("silentFunction")
drupal_launcherkeynames="default"
drupal_default_exec="xdg-open http://localhost/drupal"
drupal_manualcontentavailable="0;0;1"
install_drupal_post()
{
  create_folder /var/www/html/drupal/sites/default/files/translations 777
}
uninstall_drupal_post()
{
  remove_folder /var/www/html/drupal/
}
