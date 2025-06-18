import logging

logging.basicConfig()
log=logging.getLogger("pympsim")

def setInfoLevel():
    """Set logging level to INFO severity"""
    log.setLevel(logging.INFO)

def setDebugLevel():
    """Set logging level to DEBUG severity"""
    log.setLevel(logging.DEBUG)


def setWarningLevel():
    """Set logging level to WARNING severity"""
    log.setLevel(logging.WARNING)

def setErrorLevel():
    """Set logging level to ERROR severity"""
    log.setLevel(logging.ERROR)


setInfoLevel()
