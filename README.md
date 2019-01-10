# Magento-multiphp
based on https://github.com/leymannx/apache-multiphp

Debian 9 - Apache 2.4 - PHP 5.6, PHP 7.1 and PHP 7.2

1. `$ docker run -p 8856:8856 -p 8871:8871 [-v c:/xampp/htdocs:/var/www] dockserver-multiphp`
2. In your browser visit
   - [http://localhost:8856](http://localhost:8856) for PHP 5.6
   - [http://localhost:8871](http://localhost:8856) for PHP 7.1
   - [http://localhost:8872](http://localhost:8856) for PHP 7.2
3. Break stuff! :)

## Magento

I use this image to test Magento (and others) on different PHP versions

Following tools will also be provided:

- Composer
- npm
- ssh access (default root/root)

For more info see [Dockerix](https://github.com/leymannx/dockerix) on GitHub.

## Multiple PHP versions in parallel

This image uses Apache's [`mod_proxy_fcgi`](https://httpd.apache.org/docs/2.4/mod/mod_proxy_fcgi.html) and loads the right PHP version with `ProxyPassMatch`. You don't have to do anyting as I already incorporated into Apache's `000-default.conf`:

```
Listen 8856
Listen 8871
Listen 8872

<VirtualHost *:8856>

    ServerName localhost
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/php56

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

	ProxyPassMatch "^/(.*\.php(/.*)?)$" "unix:/var/run/php/php5.6-fpm.sock|fcgi://localhost/var/www/php56"
	<Directory "/var/www/php56">
		Order allow,deny
		Allow from all
		AllowOverride FileInfo All
		Require all granted
	</Directory>

</VirtualHost>

<VirtualHost *:8871>
	
    ServerName localhost
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/php71

	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined

	ProxyPassMatch "^/(.*\.php(/.*)?)$" "unix:/var/run/php/php7.1-fpm.sock|fcgi://localhost/var/www/php71"
	<Directory "/var/www/php71">
		Order allow,deny
		Allow from all
		AllowOverride FileInfo All
		Require all granted
	</Directory>

</VirtualHost>
....etc :)
```
