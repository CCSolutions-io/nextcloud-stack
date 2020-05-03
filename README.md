# nextcloud-stack
Nextcloud Stack

# Web Server
## Variables and Settings
### [Nginx Configuration](web/nginx.conf)
1. Upstream

    Upstream configuration for Nginx, in this case our Upstream is called backend.
    Please don't use IP-Adresses in this Configuration, because the app container (probably) gets a new ip on the next restart.

```
    upstream backend {
        app-server:9000
    }
```

2. Log Configuration

    The format for the Logs files in Nginx, we use our standard Output.
    
```
    log_format  main    '{"@timestamp":"$time_iso8601",'
                        '"@source":"$server_addr",'
                        '"hostname":"$hostname",'
                        '"ip":"$http_x_forwarded_for",'
                        '"client":"$remote_addr",'
                        '"request_method":"$request_method",'
                        '"scheme":"$scheme",'
                        '"domain":"$server_name",'
                        '"referer":"$http_referer",'
                        '"request":"$request_uri",'
                        '"args":"$args",'
                        '"size":$body_bytes_sent,'
                        '"status": $status,'
                        '"responsetime":$request_time,'
                        '"upstreamtime":"$upstream_response_time",'
                        '"upstreamaddr":"$upstream_addr",'
                        '"http_user_agent":"$http_user_agent",'
                        '"https":"$https"'
                        '}';
```
   
3. Headers

    We have included the security headers recommended by Nextcloud in the configuration, as well as the headers required by using Traefik.
    
```
    # Add headers to serve security related headers
    add_header Strict-Transport-Security "max-age=15768000; includeSubDomains; preload;";
    add_header Referrer-Policy "no-referrer" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Download-Options "noopen" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Permitted-Cross-Domain-Policies "none" always;
    add_header X-Robots-Tag "none" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Remove X-Powered-By, which is an information leak
    fastcgi_hide_header X-Powered-By;
``` 
   
4. Other Configuration

    We've resized the upload size to 10 GB and set rewrite rules to improve the use with the Nextcloud Apps (IOS and Android).
    
```
    rewrite ^/.well-known/host-meta /public.php?service=host-meta last;
    rewrite ^/.well-known/host-meta.json /public.php?service=host-meta-json last;
    rewrite ^/.well-known/webfinger /public.php?service=webfinger last;

    location = /.well-known/carddav {
        return 301 $scheme://$host:$server_port/remote.php/dav;
    }
    location = /.well-known/caldav {
        return 301 $scheme://$host:$server_port/remote.php/dav;
    }

    client_max_body_size 10G; # 0=unlimited - set max upload size
``` 
   
### [Enviroment File](.env)

We use the Environment File to centrally manage the Nginx and Nextcloud versions. The variables are then passed to the respective Dockerfiles via the docker-compose.yml.

```
    # Nextcloud Version to Build
    NEXTCLOUD_VERSION=18.0.3
    # Nginx Version to Build
    NGINX_VERSION=1.16
```

### [Redis Configuration](app-server/redis.config.php)

The Redis configuration for PHP is also loaded during build. Redis has no security configured. Nextcloud only stores cache files, but we recommend to configure Redis with authentication.

```
<?php
$CONFIG = array (
  'memcache.locking' => '\OC\Memcache\Redis',
  'redis' => array(
    'host' => 'redis',
    'port' => 6379,
  ),
);
```

# App Server
## How to update Onlyoffice

To update Onlyoffice, we have to update the sources, just make a `git pull` in the `app-server/onlyoffice` directory.
The sources will be loaded around App Container during build. When deploying Nextcloud we will use the Onlyoffice container, so we have to make sure that the sources and containers have the same version.
Therefore we use the Master Repository and the Docker latest Image.

To understand, the Onlyoffice Document Server is the application or services to process the documents and the repository is the Nextcloud application that we copy during the build process.

This application could also be installed and configured in the webui, but we do not want to do everything by hand ;).