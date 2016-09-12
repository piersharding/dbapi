import os

class Config(object):
    DEBUG = False
    TESTING = False
    CSRF_ENABLED = True
    SECRET_KEY = 'this-really-needs-to-be-changed'
    SQLALCHEMY_BINDS = {
        'maharadev': 'postgresql://postgres:password@localhost/maharadev',
        'kong': 'postgresql://postgres:password@localhost/kong',
        'test': 'postgresql://postgres:password@localhost/test',
        'foodmart': 'postgresql://postgres:password@localhost/foodmart',
      }


class ProductionConfig(Config):
    DEBUG = False


class StagingConfig(Config):
    DEVELOPMENT = True
    DEBUG = True


class DevelopmentConfig(Config):
    DEVELOPMENT = True
    DEBUG = True
    SQLALCHEMY_ECHO = True


class TestingConfig(Config):
    TESTING = True
