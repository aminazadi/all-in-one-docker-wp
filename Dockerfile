FROM php:8.1-apache

# نصب extension های مورد نیاز
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libzip-dev \
    zip \
    unzip \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install gd \
    && docker-php-ext-install mysqli \
    && docker-php-ext-install zip

# ایجاد دایرکتوری extensions در صورت عدم وجود
RUN mkdir -p /usr/local/lib/php/extensions/no-debug-non-zts-20200930/

# کپی و نصب ionCube Loader
COPY ioncube_loaders_lin_x86-64.tar.gz /tmp/
RUN tar -zxvf /tmp/ioncube_loaders_lin_x86-64.tar.gz -C /tmp \
    && mv /tmp/ioncube/ioncube_loader_lin_8.1.so /usr/local/lib/php/extensions/no-debug-non-zts-20200930/ \
    && echo "zend_extension=ioncube_loader_lin_8.1.so" > /usr/local/etc/php/conf.d/00-ioncube.ini \
    && rm -rf /tmp/ioncube*

# نصب SourceGuardian
RUN curl -o sourceguardian_loaders.tar.gz http://www.sourceguardian.com/loaders/download/loaders.linux-x86_64.tar.gz \
    && tar -zxvf sourceguardian_loaders.tar.gz \
    && mv ixed.8.1.lin /usr/local/lib/php/extensions/no-debug-non-zts-20200930/ \
    && echo "zend_extension=ixed.8.1.lin" > /usr/local/etc/php/conf.d/00-sourceguardian.ini \
    && rm -rf sourceguardian*

# فعال‌سازی mod_rewrite
RUN a2enmod rewrite

# تنظیمات apache
COPY ./000-default.conf /etc/apache2/sites-available/000-default.conf

# کپی فایل‌های وردپرس
COPY . /var/www/html/

# تنظیمات دسترسی‌ها
RUN chown -R www-data:www-data /var/www/html/ \
    && chmod -R 755 /var/www/html/

