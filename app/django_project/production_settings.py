from .settings import *

ALLOWED_HOSTS.append("3.250.238.204")

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql', 
        'NAME': os.getenv("MARIADB_DATABASE", "bd_name"),
        'USER': os.getenv("MARIADB_USER", "bd_user"),
        'PASSWORD': os.getenv("MARIADB_PASSWORD", "bd_pwd"),
        'HOST': os.getenv("MARIADB_HOST", "bd_host"),         # nome del servizio del DB specificato nel Docker Compose
        'PORT': int(os.getenv("MARIADB_PORT", "bd_port")),    # porta specificata nel servizio del DB nel Docker Compose
    }
}