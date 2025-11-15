# -*- coding: UTF-8 -*-

# Build paths inside the project like this: BASE_DIR / "subdir"
import os
import json
from pathlib import Path
from datetime import timedelta
import requests
import logging

logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Fail-fast conversion helpers replace django-environ parsing so configuration errors
# are caught during startup rather than at runtime.

def get_str(key, default=None, *, required=False):
    value = os.environ.get(key, default)
    if required and not value:
        raise ValueError(f"{key} is required but not set")
    return value


def get_bool(key, default=False):
    value = os.environ.get(key)
    if value is None:
        return default
    return value.strip().lower() in {"true", "1", "yes", "on"}


def get_int(key, default=None):
    value = os.environ.get(key)
    if value is None:
        return default
    try:
        return int(value)
    except ValueError:
        raise ValueError(f"{key} must be an integer")


def get_list(key, default=None):
    value = os.environ.get(key)
    if not value:
        return list(default) if default is not None else []
    value = value.strip()
    if value.startswith("["):
        try:
            parsed = json.loads(value)
            if isinstance(parsed, list):
                return parsed
        except json.JSONDecodeError:
            pass
    return [item.strip() for item in value.split(",") if item.strip()]


def get_dict(key, default=None):
    value = os.environ.get(key)
    if not value:
        return dict(default) if default is not None else {}
    try:
        parsed = json.loads(value)
        if isinstance(parsed, dict):
            return parsed
    except json.JSONDecodeError:
        pass
    raise ValueError(f"{key} must be valid JSON representing a dict")


BASE_DIR = Path(__file__).resolve().parent.parent

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = get_str(
    "SECRET_KEY", default="CHANGE_ME_TO_A_LONG_RANDOM_SECRET_KEY_32_CHARS_MIN"
)

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = get_bool("DEBUG", default=False)

ALLOWED_HOSTS = get_list("ALLOWED_HOSTS", default=["*"])

# https://docs.djangoproject.com/en/4.0/ref/settings/#csrf-trusted-origins
CSRF_TRUSTED_ORIGINS = get_list(
    "CSRF_TRUSTED_ORIGINS", default=["https://mysqlstudio.example.com"]
)

# Avoid nginx reverse-proxy redirect 404 issues
USE_X_FORWARDED_HOST = True

# Request size limit
DATA_UPLOAD_MAX_MEMORY_SIZE = 15728640

AVAILABLE_ENGINES = {
    "mysql": {"path": "sql.engines.mysql:MysqlEngine"},
    "cassandra": {"path": "sql.engines.cassandra:CassandraEngine"},
    "clickhouse": {"path": "sql.engines.clickhouse:ClickHouseEngine"},
    "goinception": {"path": "sql.engines.goinception:GoInceptionEngine"},
    "mssql": {"path": "sql.engines.mssql:MssqlEngine"},
    "redis": {"path": "sql.engines.redis:RedisEngine"},
    "pgsql": {"path": "sql.engines.pgsql:PgSQLEngine"},
    "oracle": {"path": "sql.engines.oracle:OracleEngine"},
    "mongo": {"path": "sql.engines.mongo:MongoEngine"},
    "phoenix": {"path": "sql.engines.phoenix:PhoenixEngine"},
    "odps": {"path": "sql.engines.odps:ODPSEngine"},
    "doris": {"path": "sql.engines.doris:DorisEngine"},
    "elasticsearch": {"path": "sql.engines.elasticsearch:ElasticsearchEngine"},
    "opensearch": {"path": "sql.engines.elasticsearch:OpenSearchEngine"},
}

ENABLED_NOTIFIERS = get_list(
    "ENABLED_NOTIFIERS",
    default=[
        "sql.notify:DingdingWebhookNotifier",
        "sql.notify:DingdingPersonNotifier",
        "sql.notify:FeishuWebhookNotifier",
        "sql.notify:FeishuPersonNotifier",
        "sql.notify:QywxWebhookNotifier",
        "sql.notify:QywxToUserNotifier",
        "sql.notify:MailNotifier",
        "sql.notify:GenericWebhookNotifier",
    ],
)

ENABLED_ENGINES = get_list(
    "ENABLED_ENGINES",
    default=[
        "mysql",
        "clickhouse",
        "goinception",
        "mssql",
        "redis",
        "pgsql",
        "oracle",
        "mongo",
        "phoenix",
        "odps",
        "cassandra",
        "doris",
        "elasticsearch",
        "opensearch",
    ],
)

CURRENT_AUDITOR = get_str("CURRENT_AUDITOR", default="sql.utils.workflow_audit:AuditV2")

PASSWORD_MIXIN_PATH = get_str("PASSWORD_MIXIN_PATH", default="sql.plugins.password:DummyMixin")

# Application definition
INSTALLED_APPS = (
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
    "django_q",
    "sql",
    "sql_api",
    "common",
    "rest_framework",
    "django_filters",
    "drf_spectacular",
)

MIDDLEWARE = (
    "django.middleware.security.SecurityMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
    "django.middleware.gzip.GZipMiddleware",
    "common.middleware.check_login_middleware.CheckLoginMiddleware",
    "common.middleware.exception_logging_middleware.ExceptionLoggingMiddleware",
)

ROOT_URLCONF = "archery.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [BASE_DIR / "common" / "templates"],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.debug",
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
                "common.utils.global_info.global_info",
            ],
        },
    },
]

WSGI_APPLICATION = "archery.wsgi.application"

# Internationalization
LANGUAGE_CODE = "zh-hans"

TIME_ZONE = "UTC"

USE_I18N = True

USE_TZ = False

# Date/time formatting
DATETIME_FORMAT = "Y-m-d H:i:s"
DATE_FORMAT = "Y-m-d"

# Static files (CSS, JavaScript, Images)
STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "static"
STATICFILES_DIRS = [
    BASE_DIR / "common" / "static",
]
STORAGES = {
    "staticfiles": {
        "BACKEND": "django.contrib.staticfiles.storage.ManifestStaticFilesStorage",
    }
}

# Extend Django admin to use the custom user model defined in sql/models.py
AUTH_USER_MODEL = "sql.Users"

# Password validators
AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
        "OPTIONS": {
            "min_length": 9,
        },
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]

############### Update the following settings to match your environment ###############

# Session configuration
SESSION_COOKIE_AGE = 60 * 300  # 300 minutes
SESSION_SAVE_EVERY_REQUEST = True
SESSION_EXPIRE_AT_BROWSER_CLOSE = True  # Expire cookies when the browser closes

# Primary MySQL connection used by this project
DATABASES = {
    "default": {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': 'mysqlstudio',
        'USER': 'mysqlstudio',
        'PASSWORD': 'MySQLStudio1.13.1',
        'HOST': '172.18.0.31',
        'PORT': '3306',
    }
}

# Django-Q
Q_CLUSTER = {
    "name": "MySQL Studio",
    "workers": get_int("Q_CLUISTER_WORKERS", default=4),
    "recycle": 500,
    "timeout": get_int("Q_CLUISTER_TIMEOUT", default=60),
    "compress": True,
    "cpu_affinity": 1,
    "save_limit": 0,
    "queue_limit": 50,
    "label": "Django Q",
    "django_redis": "default",
    "sync": get_bool("Q_CLUISTER_SYNC", default=False),  # Set True during local debugging to run in sync mode
}

# Cache configuration
CACHES = {
    "default": {
        "BACKEND": "django_redis.cache.RedisCache",
        "LOCATION": "redis://172.18.0.32:6379/13",
        "OPTIONS": {
            "CLIENT_CLASS": "django_redis.client.DefaultClient",
            "PASSWORD": "MySQLStudio1.13.1"
        }
    }
}

# https://docs.djangoproject.com/en/3.2/ref/settings/#std-setting-DEFAULT_AUTO_FIELD
DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"

# API Framework
REST_FRAMEWORK = {
    "DEFAULT_SCHEMA_CLASS": "drf_spectacular.openapi.AutoSchema",
    "DEFAULT_RENDERER_CLASSES": ("rest_framework.renderers.JSONRenderer",),
    # Authentication
    "DEFAULT_AUTHENTICATION_CLASSES": (
        "rest_framework_simplejwt.authentication.JWTAuthentication",
        "rest_framework.authentication.SessionAuthentication",
    ),
    # Permissions
    "DEFAULT_PERMISSION_CLASSES": ("sql_api.permissions.IsInUserWhitelist",),
    # Rate limits (anon = unauthenticated, user = authenticated)
    "DEFAULT_THROTTLE_CLASSES": (
        "rest_framework.throttling.AnonRateThrottle",
        "rest_framework.throttling.UserRateThrottle",
    ),
    "DEFAULT_THROTTLE_RATES": {"anon": "120/min", "user": "600/min"},
    # Filtering
    "DEFAULT_FILTER_BACKENDS": ("django_filters.rest_framework.DjangoFilterBackend",),
    # Pagination
    "DEFAULT_PAGINATION_CLASS": "rest_framework.pagination.PageNumberPagination",
    "PAGE_SIZE": 5,
}

# Swagger UI
SPECTACULAR_SETTINGS = {
    "TITLE": "MySQL Studio API",
    "DESCRIPTION": "OpenAPI 3.0",
    "VERSION": "1.0.0",
    "ENUM_NAME_OVERRIDES": {
        "WorkflowTypeEnum": "common.utils.const.WorkflowType",
        "WorkflowExecuteModeEnum": [("auto", "auto"), ("manual", "manual")],
        "InstanceModeEnum": [("standalone", "单机"), ("cluster", "集群")],
        "InstanceTypeEnum": [("master", "主库"), ("slave", "从库")],
        "CloudProviderEnum": [("aliyun", "aliyun")],
        "ArchiveModeEnum": [("file", "文件"), ("dest", "其他实例"), ("purge", "直接删除")],
        "BooleanYesNoEnum": [(0, "否"), (1, "是")],
    },
}

# API Authentication
SIMPLE_JWT = {
    "ACCESS_TOKEN_LIFETIME": timedelta(hours=4),
    "REFRESH_TOKEN_LIFETIME": timedelta(days=3),
    "ALGORITHM": "HS256",
    "SIGNING_KEY": SECRET_KEY,
    "AUTH_HEADER_TYPES": ("Bearer",),
}

# OIDC
ENABLE_OIDC = get_bool("ENABLE_OIDC", default=False)
if ENABLE_OIDC:
    INSTALLED_APPS += ("mozilla_django_oidc",)
    AUTHENTICATION_BACKENDS = (
        "common.authenticate.oidc_auth.OIDCAuthenticationBackend",
        "django.contrib.auth.backends.ModelBackend",
    )

    OIDC_RP_WELLKNOWN_URL = get_str(
        "OIDC_RP_WELLKNOWN_URL", required=True
    )  # e.g. https://keycloak.example.com/realms/<realm>/.well-known/openid-configuration
    OIDC_RP_CLIENT_ID = get_str("OIDC_RP_CLIENT_ID", required=True)
    OIDC_RP_CLIENT_SECRET = get_str("OIDC_RP_CLIENT_SECRET", required=True)

    response = requests.get(OIDC_RP_WELLKNOWN_URL)
    response.raise_for_status()
    config = response.json()
    OIDC_OP_AUTHORIZATION_ENDPOINT = config["authorization_endpoint"]
    OIDC_OP_TOKEN_ENDPOINT = config["token_endpoint"]
    OIDC_OP_USER_ENDPOINT = config["userinfo_endpoint"]
    OIDC_OP_JWKS_ENDPOINT = config["jwks_uri"]
    OIDC_OP_LOGOUT_ENDPOINT = config["end_session_endpoint"]

    OIDC_RP_SCOPES = get_str("OIDC_RP_SCOPES", default="openid profile email")
    OIDC_RP_SIGN_ALGO = get_str("OIDC_RP_SIGN_ALGO", default="RS256")

    LOGIN_REDIRECT_URL = "/"

# Dingding
ENABLE_DINGDING = get_bool("ENABLE_DINGDING", default=False)
if ENABLE_DINGDING:
    INSTALLED_APPS += ("django_auth_dingding",)
    AUTHENTICATION_BACKENDS = (
        "common.authenticate.dingding_auth.DingdingAuthenticationBackend",
        "django.contrib.auth.backends.ModelBackend",
    )
    AUTH_DINGDING_AUTHENTICATION_CALLBACK_URL = get_str(
        "AUTH_DINGDING_AUTHENTICATION_CALLBACK_URL", required=True
    )
    AUTH_DINGDING_APP_KEY = get_str("AUTH_DINGDING_APP_KEY", required=True)
    AUTH_DINGDING_APP_SECRET = get_str("AUTH_DINGDING_APP_SECRET", required=True)

# LDAP
ENABLE_LDAP = get_bool("ENABLE_LDAP", default=False)
if ENABLE_LDAP:
    import ldap
    from django_auth_ldap.config import LDAPSearch

    AUTHENTICATION_BACKENDS = (
        "django_auth_ldap.backend.LDAPBackend",  # Try LDAP first; stop if it succeeds
        "django.contrib.auth.backends.ModelBackend",  # Fallback to local users (order matters)
    )

    AUTH_LDAP_SERVER_URI = get_str("AUTH_LDAP_SERVER_URI", default="ldap://xxx")
    AUTH_LDAP_USER_DN_TEMPLATE = get_str("AUTH_LDAP_USER_DN_TEMPLATE", None)
    if not AUTH_LDAP_USER_DN_TEMPLATE:
        del AUTH_LDAP_USER_DN_TEMPLATE
        AUTH_LDAP_BIND_DN = get_str(
            "AUTH_LDAP_BIND_DN", default="cn=xxx,ou=xxx,dc=xxx,dc=xxx"
        )
        AUTH_LDAP_BIND_PASSWORD = get_str(
            "AUTH_LDAP_BIND_PASSWORD", default="***********"
        )
        AUTH_LDAP_USER_SEARCH_BASE = get_str(
            "AUTH_LDAP_USER_SEARCH_BASE", default="ou=xxx,dc=xxx,dc=xxx"
        )
        AUTH_LDAP_USER_SEARCH_FILTER = get_str(
            "AUTH_LDAP_USER_SEARCH_FILTER", default="(cn=%(user)s)"
        )
        AUTH_LDAP_USER_SEARCH = LDAPSearch(
            AUTH_LDAP_USER_SEARCH_BASE, ldap.SCOPE_SUBTREE, AUTH_LDAP_USER_SEARCH_FILTER
        )
    AUTH_LDAP_ALWAYS_UPDATE_USER = get_bool(
        "AUTH_LDAP_ALWAYS_UPDATE_USER", default=True
    )  # Sync user info from LDAP on every login
    AUTH_LDAP_USER_ATTR_MAP = get_dict(
        "AUTH_LDAP_USER_ATTR_MAP",
        default={"username": "cn", "display": "displayname", "email": "mail"},
    )

# CAS authentication
ENABLE_CAS = get_bool("ENABLE_CAS", default=False)
if ENABLE_CAS:
    INSTALLED_APPS += ("django_cas_ng",)
    MIDDLEWARE += ("django_cas_ng.middleware.CASMiddleware",)
    AUTHENTICATION_BACKENDS = (
        "django.contrib.auth.backends.ModelBackend",
        "django_cas_ng.backends.CASBackend",
    )

    # CAS server URL
    CAS_SERVER_URL = get_str("CAS_SERVER_URL", required=True)
    # CAS protocol version
    CAS_VERSION = get_str("CAS_VERSION", required=True)
    # Persist all user attributes returned by CAS
    CAS_APPLY_ATTRIBUTES_TO_USER = True
    # End the session when the browser closes
    SESSION_EXPIRE_AT_BROWSER_CLOSE = True
    # Optionally skip SSL certificate validation
    CAS_VERIFY_SSL_CERTIFICATE = get_bool(
        "CAS_VERIFY_SSL_CERTIFICATE", default=False
    )
    # Ignore referer validation
    CAS_IGNORE_REFERER = True
    # Handle HTTPS callback issues
    CAS_FORCE_SSL_SERVICE_URL = get_bool(
        "CAS_FORCE_SSL_SERVICE_URL", default=False
    )
    CAS_RETRY_TIMEOUT = 1
    CAS_RETRY_LOGIN = True
    CAS_EXTRA_LOGIN_PARAMS = {"renew": True}
    CAS_LOGOUT_COMPLETELY = True

SUPPORTED_AUTHENTICATION = [
    ("LDAP", ENABLE_LDAP),
    ("DINGDING", ENABLE_DINGDING),
    ("OIDC", ENABLE_OIDC),
    ("CAS", ENABLE_CAS),
]
# Count enabled external authentication methods
ENABLE_AUTHENTICATION_COUNT = len(
    [enabled for (name, enabled) in SUPPORTED_AUTHENTICATION if enabled]
)
if ENABLE_AUTHENTICATION_COUNT > 0:
    if ENABLE_AUTHENTICATION_COUNT > 1:
        logger.warning(
            "系统外部认证目前支持LDAP、DINGDING、OIDC、CAS四种，认证方式只能启用其中一种，如果启用多个，实际生效的只有一个，优先级LDAP > DINGDING > OIDC > CAS"
        )
    authentication = ""  # Default to empty
    for name, enabled in SUPPORTED_AUTHENTICATION:
        if enabled:
            authentication = name
            break
    logger.info("当前生效的外部认证方式：" + authentication)
    logger.info("认证后端：" + AUTHENTICATION_BACKENDS.__str__())

# Logging configuration
LOGGING = {
    "version": 1,
    "disable_existing_loggers": False,
    "formatters": {
        "verbose": {
            "format": "[%(asctime)s][%(threadName)s:%(thread)d][task_id:%(name)s][%(filename)s:%(lineno)d][%(levelname)s]- %(message)s"
        },
    },
    "handlers": {
        "default": {
            "level": "DEBUG",
            "class": "logging.handlers.RotatingFileHandler",
            "filename": str(BASE_DIR / "logs" / "mysqlstudio.log"),
            "maxBytes": 1024 * 1024 * 100,  # 100 MB
            "backupCount": 180,
            "formatter": "verbose",
        },
        "django-q": {
            "level": "DEBUG",
            "class": "logging.handlers.RotatingFileHandler",
            "filename": str(BASE_DIR / "logs" / "qcluster.log"),
            "maxBytes": 1024 * 1024 * 100,  # 100 MB
            "backupCount": 180,
            "formatter": "verbose",
        },
        "console": {
            "level": "DEBUG",
            "class": "logging.StreamHandler",
            "formatter": "verbose",
        },
    },
    "loggers": {
        "default": {  # Default logger
            "handlers": ["console", "default"],
            "level": "DEBUG",
        },
        "django-q": {  # django-q module logs
            "handlers": ["console", "django-q"],
            "level": "DEBUG",
            "propagate": False,
        },
        "django_auth_ldap": {  # django-auth-ldap module logs
            "handlers": ["console", "default"],
            "level": "DEBUG",
            "propagate": False,
        },
        "mozilla_django_oidc": {
            "handlers": ["console", "default"],
            "level": "DEBUG",
            "propagate": False,
        },
        'django.db': {  # Print SQL statements to aid debugging
            'handlers': ['console', 'default'],
            'level': 'DEBUG',
            'propagate': False
        },
        'django.request': {  # Log request stack traces for easier debugging
            'handlers': ['console', 'default'],
            'level': 'DEBUG',
            'propagate': False
        },
    },
}

# Optional suffix shown in the site title and login page to distinguish deployments.
# If also configured in the MySQL Studio backend UI, the backend setting takes precedence.
CUSTOM_TITLE_SUFFIX = get_str("CUSTOM_TITLE_SUFFIX", default="")

MEDIA_ROOT = BASE_DIR / "media"
MEDIA_ROOT.mkdir(parents=True, exist_ok=True)

PKEY_ROOT = MEDIA_ROOT / "keys"
PKEY_ROOT.mkdir(parents=True, exist_ok=True)

try:
    from local_settings import *
except ImportError:
    print("import local settings failed, ignored")
