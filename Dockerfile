FROM php:8.4.7-apache-bookworm AS build

RUN sed -i '1s/^Types: deb$/Types: deb deb-src/' /etc/apt/sources.list.d/debian.sources && \
  echo "Acquire::Check-Valid-Until false;" | tee -a /etc/apt/apt.conf.d/no-check-valid-until && \
  sed -i 's|http://deb.debian.org/debian-security|http://snapshot.debian.org/archive/debian-security/20250717T060459Z|g' /etc/apt/sources.list.d/debian.sources && \
  sed -i 's|http://deb.debian.org/debian|http://snapshot.debian.org/archive/debian/20250718T082802Z|g' /etc/apt/sources.list.d/debian.sources && \
  apt-get update && apt-get build-dep -y sqlite3 && \
  apt-get install -y --no-install-recommends libicu-dev debmake && \
  cd /root && apt-get source sqlite3
COPY ./enable-icu.patch /root/enable-icu.patch
RUN cd /root/sqlite3-3.40.1 && \
  patch debian/rules < /root/enable-icu.patch && debuild -us -uc

###############################################################################

FROM php:8.4.7-apache-bookworm AS runtime
COPY --from=build /root/sqlite3*.deb /root/sqlite3.deb
COPY --from=build /root/libsqlite3*.deb /root/libsqlite3.deb
COPY docker-entrypoint.sh /bin/docker-entrypoint.sh
RUN sed -i 's|http://deb.debian.org/debian-security|http://snapshot.debian.org/archive/debian-security/20250717T060459Z|g' /etc/apt/sources.list.d/debian.sources && \
  sed -i 's|http://deb.debian.org/debian|https://snapshot.debian.org/archive/debian/20250718T082802Z|g' /etc/apt/sources.list.d/debian.sources && \
  echo "Acquire::Check-Valid-Until false;" | tee -a /etc/apt/apt.conf.d/no-check-valid-until && \
  apt-get update && apt-get install -y --no-install-recommends \
  libfreetype6-dev \
  libjpeg62-turbo-dev \
  libpng-dev \
  libonig-dev && \
  rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j$(nproc) gd \
  && docker-php-ext-install -j$(nproc) mbstring \
  && docker-php-ext-configure mssql --with-libdir=lib/x86_64-linux-gnu && \
  docker-php-ext-install -j$(nproc) mssql

RUN apt-get -y install /root/sqlite3.deb \
  /root/libsqlite3.deb \
  --no-install-recommends && rm -rf /root/*

RUN cd /usr/src/ && tar xaf php.tar.xz

# RUN ln -s "$PHP_INI_DIR/php.ini-development" "$PHP_INI_DIR/php.ini"
RUN ln -s "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"

###############################################################################
ENTRYPOINT ["docker-entrypoint.sh"]
