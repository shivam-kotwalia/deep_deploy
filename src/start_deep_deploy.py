#!../../venvs/main/bin/python
#Start the Deep Deploy by python start_deep_deploy
import os 
#When running from outside of Deep Deploy project
#os.chdir("deep_deploy")

#When running from src directory
os.chdir("..")
os.system("gunicorn --workers 1 -b 127.0.0.1:5001 wsgi:app")
os.system("celery -A tasks worker --loglevel=info")
