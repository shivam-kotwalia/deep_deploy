#Contains all the Config and Global Varibales
import logging


class Config(object):
    LOG_PATH = 'logs/deep_deploy_log.log'
    LOG_LEVEL = logging.ERROR
    DEBUG = False
    TESTING = False
    CELERY_BROKER_URL = 'pyamqp://guest@localhost//'
    

class DevelopmentConfig(Config):
    DEBUG = True
    LOG_LEVEL = logging.INFO
    TESTING = True


class ProductionConfig(Config):
    LOG_LEVEL = logging.WARN
