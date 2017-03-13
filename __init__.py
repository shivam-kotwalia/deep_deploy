from flask import Flask
from flask_bootstrap import Bootstrap
import config
from celery import Celery
import logging
from logging.handlers import RotatingFileHandler

#Initialize the Flask app
app = Flask(__name__)
app.config.from_object(config.DevelopmentConfig)
Bootstrap(app)

celery = Celery(app.name, broker=app.config['CELERY_BROKER_URL'])

#Logging
# handler = RotatingFileHandler(app.config['LOG_PATH'], maxBytes=10*1024*1024, backupCount=5)
# handler.setLevel(app.config['LOG_LEVEL'])
# formatter = logging.Formatter("%(asctime)s - %(name)s - %(levelname)s - %(message)s")
# handler.setFormatter(formatter)
# app.logger.addHandler(handler)

#Calling all views
import deep_deploy.view