import os, sys
import subprocess
from PyInquirer import prompt
from postgres_client import PostgresClient

import yaml
import pathlib
from PyInquirer import prompt


SERVICE_CONF = pathlib.Path(__file__).parent.parent / "configs" /os.getenv(
    "CONFIGS_FILE", "config.yml"
)


def load_config_from_yaml(filename):
    """load configuration from yaml file"""
    with open(filename, "r", encoding="utf-8") as fd_reader:
        return yaml.full_load(fd_reader)
    Path.iterdir()

def main():
    configs = load_config_from_yaml(SERVICE_CONF)
    pg_client = PostgresClient(dsn=configs["POSTGRES_URL"])
    filename = pathlib.Path(__file__).parent.parent / configs["POSTGRES_SCHEMAS"]
    
    if pg_client.create_db(
        configs["POSTGRES_DBNAME"], configs["POSTGRES_USERNAME"]
        ) is True:
        try:
            pg_url = str(f'{configs["POSTGRES_DBURL"]}')
            query = filename.read_text()
            subprocess.run(["psql", pg_url, "-X", "--quiet", "-c", query])
        except Exception:
            pass
        
        
            #subprocess.run(["psql", pg_url, "-X", "--quiet", "-c", line])
    


if __name__ == '__main__':
    main()