# hadolint ignore=DL3008,DL3009
FROM php:8.3-apache AS base

RUN apt-get update && apt-get install -y --no-install-recommends libpq-dev \
    && docker-php-ext-install pdo pdo_pgsql \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN useradd -u 1001 -m appuser \
    && chown -R appuser:appuser /var/www/html

COPY --chown=appuser:appuser index.php /var/www/html/index.php

USER 1001

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD php -r "exit(file_get_contents('http://localhost/health') ? 0 : 1);" || exit 1
