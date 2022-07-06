import os
from logging import Logger
from injector import singleton, inject
from consul_config import ConsulConfig


import os
import pathlib
import yaml

from injector import singleton
from yaml import Loader
from common.files_lib import load_config_from_yaml
PROJ_ROOT = pathlib.Path(__file__).parent.parent
SERVICE_CONF = pathlib.Path(__file__).parent / "config.yml"

@singleton
class ConfigService:
    """config parameters"""
    def __init__(self):
        self.conf = {}
        if os.getenv('RUNS_IN_DOCKER'):

            self.conf['JOB_INTERVAL'] = os.environ['JOB_INTERVAL']
            self.conf['POSTGRES_DB_URL'] = os.environ['POSTGRES_DB_URL']
            self.conf['HOME_DIR'] = os.environ['HOME_DIR']
            self.conf['DATA_STORAGE'] = os.environ['DATA_STORAGE']
            self.conf['ARCHIVE_STORAGE'] = os.environ['ARCHIVE_STORAGE']

        else:
            self.conf = load_config_from_yaml(SERVICE_CONF) #str(f"{PROJ_ROOT}/configs/config.yml"))
            







@singleton
class ConfigService:
    @inject
    def __init__(self):
        self.conf = load_config_from_yaml(SERVICE_CONF) 
        # connect to consul
        self.consul_client = ConsulConfig(host=conf.get('CONSUL_HOST', '127.0.0.1'))
        

        # production
        if os.getenv("RUNS_IN_DOCKER"):
            self.postgres_url = self.consul_client.get('postgres_url', prefix='local')
            self.redis_url = self.consul_client.get('redis_url', prefix='local')
            
        # debug
        else:
            self.postgres_url = self.consul_client.get('postgres_url', prefix='glogal')
            self.redis_url = self.consul_client.get('redis_url', prefix='global')
            #self.imu_service_base_url = self.consul_client.get('imu_service_base_url', prefix='shared')
            #self.gps_service_base_url = self.consul_client.get('gps_service_base_url', prefix='shared')
            #self.ais_service_base_url = self.consul_client.get('ais_service_base_url', prefix='shared')
        
        # CI
        if os.getenv("RUNS_IN_CI"):
            pass


if __name__ == "__main__":
    print(f"PROJ_ROOT: {PROJ_ROOT}")
    print(SERVICE_CONF)
    configer = ConfigService()

    print(configer.conf)
    #asyncio.get_event_loop().run_until_complete(main())