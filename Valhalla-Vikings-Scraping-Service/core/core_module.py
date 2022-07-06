import os
from injector import singleton, provider, Module
from logging import get_logger, LoggingOutput, LoggingFormat
from consul_config import ConsulConfig
from utils import get_git_hash_version
from async_redis_client import AsyncRedisClient
from asyncio_postgres_client import AsyncPostgresClient
#, AsyncInfluxClient, AsyncAmqpConnection, AsyncMongoConnection
from config_service import ConfigService
#from core.logging import get_logger, LoggingOutput, LoggingFormat

#from core.config_service import ConfigService


class CoreModule(Module):
    @singleton
    @provider
    def provide_consul_client(self, config_service: ConfigService) -> ConsulClient:
        consul_client = ConsulClient(host=config_service.consul_host, prefix=config_service.consul_prefix)
        return consul_client
    
    @singleton
    @provider
    def provide_postgres_client(self, config_service: ConfigService, logger: Logger) -> AsyncPostgresClient:
        """innit postgres client"""      
        postgres_client = AsyncPostgresClient(address=config_service.postgres_url, logger=logger)
        return postgres_client
    

    @singleton
    @provider
    def provide_redis_client(self, config_service: ConfigService) -> AsyncRedisClient:
        redis_client = AsyncRedisClient(addr=config_service.redis_url)
        return redis_client

    
    @singleton
    @provider
    def provide_logger(self) -> Logger:
        logger = get_logger(
            logger_name='Valhalla-Vikings-Scraping-Service',
            logger_version=get_git_hash_version(),
            logger_format=LoggingFormat.JSON,
            logger_level=logging.INFO,
            logger_output=LoggingOutput.STDOUT,
        )
        return logger






    
if __name__ == "__main__":
    configer = ConfigService()
    con = CoreModule()


    print(con.provide_postgres_client(configer))
    log = get_logger(logger_name=__name__,
                         logger_version='0.0.0.1',
                         logger_format=LoggingFormat.JSON,
                         logger_level=logging.INFO,
                         logger_output=LoggingOutput.STDOUT)

    log.info("logging: info", extra={'test': __name__})
    log.debug("logging: debug", extra={'test': __name__})
    log.note("logging: note", extra={'test': __name__})
    log.warning("logging: warning", extra={'test': __name__})
    log.error("logging: error", extra={'test': __name__})
    log.critical("logging: critical", extra={'test': __name__})
    log.exception("logging: exception", extra={'test': __name__})