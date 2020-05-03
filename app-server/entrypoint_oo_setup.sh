#!/bin/sh
set -eu

run_as() {
  if [ "$(id -u)" = 0 ]; then
    su - www-data -s /bin/sh -c "$1"
  else
    sh -c "$1"
  fi
}

while [ ! -f /var/www/html/config/config.php ]
do
    echo 'Config not present yet, sleeping...'
    sleep 10
done

if [ ! -f /var/www/html/oo_setup ]; then
    echo "starting openoffice app setup"
    max_retries=20
    try=0
    until run_as 'php /var/www/html/occ --no-warnings app:enable onlyoffice' || [ "$try" -gt "$max_retries" ]
    do
        echo "retrying app enable..."
        try=$((try+1))
        sleep 3s
    done

    if [ "$try" -gt "$max_retries" ]; then
      echo "enabling of nextcloud openoffice failed!"
      exit 1
    fi

    echo "setting ${NEXTCLOUD_HOST} as trusted domain"
    run_as "php /var/www/html/occ --no-warnings config:system:set trusted_domains 0 --value=${NEXTCLOUD_HOST}"
    run_as 'php /var/www/html/occ --no-warnings config:system:set trusted_domains 1 --value="web-server"'
    echo "configuring openoffice app settings..."
    run_as 'php /var/www/html/occ --no-warnings config:system:set onlyoffice DocumentServerUrl --value="/ds-vpath/"'
    run_as 'php /var/www/html/occ --no-warnings config:system:set onlyoffice DocumentServerInternalUrl --value="http://onlyoffice-document-server/"'
    run_as 'php /var/www/html/occ --no-warnings config:system:set onlyoffice StorageUrl --value="http://web-server/"'
    run_as 'php /var/www/html/occ --no-warnings background:cron '
    touch /var/www/html/oo_setup
fi

exit 0