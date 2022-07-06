import asyncio
import json
import csv
import aiofiles
import yaml
import pathlib
from aiofile import AIOFile, Writer, Reader
import sys


def load_config_from_yaml(filename):
    """load configuration from yaml file"""
    with open(filename, "r", encoding="utf-8") as fd_reader:
        return yaml.full_load(fd_reader)


async def async_load_config_from_yaml(filename):
    async with aiofiles.open(filename, "r", encoding='utf-8') as fd_reader:
        return yaml.full_load(fd_reader)


def file_writer(filename, data):
    with open(filename, "w", encoding="utf-8") as fw:
        fw.write(data)
    return True


async def async_file_writer(filename, data):
    "file content writer"
    async with AIOFile(filename, "w", encoding="utf-8") as afp:
        await afp.write(data)
    return True


def file_read(filename):
    with open(filename, "r", encoding="utf-8") as file_reader:
        for row in file_reader.read().split():
            yield row


async def async_file_reader(filename, _):
    "file content reader"
    async with AIOFile(filename, "r", encoding='utf-8') as freader:
        return await freader.read()



def file_read_csv(filename):
    with open(filename,"r",encoding="utf-8", newline='') as csvfile:
        reader = iter(csv.DictReader(csvfile, restval=None))
        for row in reader:
            yield row

           
async def async_file_read_csv(filename):
    async with aiofiles.open(filename,"r",encoding="utf-8", newline='') as csvfile:
        return csv.DictReader(csvfile, restval=None)

# async def async_file_json_writer(file_path, data):
#     "file content writer"
#     async with AIOFile(file_path, "w", encoding="utf-8") as afp:
#         await afp.write(json.dumps(data))
#     return True
# 
# 
# async def async_file_content_json_reader(file_path):
#     "file content reader"
#     async with AIOFile(file_path, "r", encoding='utf-8') as afp:
#         return json.loads(await afp.read())






async def async_write_to_json_file(data_object, file_name):
    async with aiofiles.open(file_name, "w") as outfile:
        print(f'Writing "{data_object}" to "{file_name}"...')
        await outfile.write(json.dumps(data_object, indent=4))












