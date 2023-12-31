import logging
import sys
import  os
import datetime
from logging.handlers import RotatingFileHandler
def log_init(log_file,level):
    # logging.basicConfig(level=logging.DEBUG,
    #                     #format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
    #                     format='%(asctime)s %(filename)s[line:%(lineno)d][%(funcName)s] %(levelname)s %(message)s',
    #                     # datefmt='%a, %d %b %Y %H:%M:%S.%f',
    #                     filename=log_file,
    #                     filemode='w')


    #formatter = logging.Formatter('%(name)-12s: %(levelname)-8s %(message)s')
    formatter = logging.Formatter('%(asctime)s %(filename)s[line:%(lineno)d][%(funcName)s] %(levelname)s %(message)s')
    

    logger = logging.getLogger('')
    logger.handlers.pop()


    handler = RotatingFileHandler(log_file, maxBytes=102400000, backupCount=5)
    handler.setLevel(level)
    handler.setFormatter(formatter)
    logger.setLevel(level)
    logger.addHandler(handler)
    
    logging.info("handlers={}".format(logger.handlers))
    # console = logging.StreamHandler()
    # console.setLevel('ERROR')
    # console.setFormatter(formatter)
    # logging.getLogger('').addHandler(console)

    # logging.Formatter(fmt='%(asctime)s',datefmt='%Y-%m-%d,%H:%M:%S.%f')
