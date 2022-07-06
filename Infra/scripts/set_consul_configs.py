import os, sys
import json
import yaml
import pathlib
from PyInquirer import prompt
from tabulate import tabulate
from consul_client import ConsulClient


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
    consul_client = ConsulClient(
        host=configs["CONSUL_HOST"], port=configs["CONSUL_PORT"]
        )

    try:
        table = []
        all_keys = consul_client.get_all()
        if all_keys:
            for key in all_keys:
                table.append(
                    [key["Key"], json.dumps(
                        key["Value"], sort_keys=True, indent=4
                        )]
                    )
            print(f'Current configs in {configs["CONSUL_HOST"]}')
            print('\n')
            print(tabulate(table, headers=["Key", "Value"]))
            print('\n')
    except TypeError:
        pass
    folder = pathlib.Path(__file__).parent.parent / "configs"
    questions = [{
        "type": "list",
        "name": "file",
        "message": "Choose config file",
        "choices": [x.name for x in folder.iterdir()] #*os.listdir(CONFIGS_DIR)
    }]
    answers = prompt(questions)
    if not answers:
        sys.exit(0)
        
    filename = pathlib.Path(__file__).parent.parent / "configs" / answers["file"]
    json_configs = json.loads(filename.read_text())
    for group_key, group_config in json_configs.items():
        for key, config in group_config.items():
            consul_client.put(key, config, prefix=group_key)
    

if __name__ == '__main__':
    main()

    
