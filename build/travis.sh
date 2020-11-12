#!/usr/bin/env bash

echo "Version of CI scripts:"
cd ecoci
git log | head -1
cd ..

phpenv config-add ./ecoci/build/travis.php.ini

echo "Moving module to subfolder..."
if [[ *$TRAVIS_EVENT_TYPE* = 'cron' ]]; then git checkout $(git tag | tail -n 1); fi
mkdir $MODULE_DIR
ls -1 | grep -v ^$MODULE_DIR | grep -v ^ecoci | xargs -I{} mv {} $MODULE_DIR

echo "Cloning $PRODUCT_NAME..."
git clone --branch 201907.0 https://github.com/spryker-shop/$PRODUCT_NAME.git $SHOP_DIR
cd $SHOP_DIR

composer self-update && composer --version
composer install --optimize-autoloader --no-interaction
composer require "ruflin/elastica:6.*" "spryker/elastica:5.*" --update-with-dependencies --optimize-autoloader --no-interaction

nvm install 8

mkdir -p shared/data/common/jenkins
mkdir -p shared/data/common/jenkins/jobs
mkdir -p data/DE/cache/Yves/twig -m 0777
mkdir -p data/DE/cache/Zed/twig -m 0777
mkdir -p data/DE/logs
chmod -R 777 data/
chmod -R 660 config/Zed/dev_only_private.key
chmod -R 660 config/Zed/dev_only_public.key
chmod -R a+x config/Shared/ci/travis/
./config/Shared/ci/travis/install_elasticsearch_6_8.sh
./config/Shared/ci/travis/install_mailcatcher.sh

cd ..

chmod a+x ./ecoci/build/configure_postgres.sh
./ecoci/build/configure_postgres.sh

chmod a+x ./ecoci/build/travis.sh

./ecoci/build/validate.sh
