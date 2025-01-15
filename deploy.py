from typing import Optional
from dotenv import dotenv_values
from pydantic import BaseModel, Field, ValidationError
from io import StringIO
import yaml
import os
import subprocess

class Service(BaseModel):
    name: str = Field(..., title="Name of the service", max_length=64)
    port: int = Field(..., title="Port of the service", ge=1, le=65535)
    domain: list[str] = Field(default_factory=list, title="Domain of the service")

class Config(BaseModel):
    services: list[Service] = Field(default_factory=list, title="List of services")
    config: list[dict] = Field(default_factory=list, title="List of configurations")

def main():
    read_config('config.yaml')


def read_config(path: str) -> Config:
    with open(path, 'r') as file:
        configs = yaml.safe_load(file)

    try:
        config = Config()
        config.services = [Service(**service) for service in configs['services']]
        # config.config = [dict(service) for service in configs['config']]
        for service in config.services:
            print(service)
        

    except ValidationError as e:
        print("Validation Error in config.yaml:")
        print(e)
        return

def read_template_as_string(path: str) -> dict:


    try:
        parsed_config = Config(**config_dict)
    except ValidationError as e:
        print("Validation Error in config.yaml:")
        print(e)
        return
    
    with open('docker-compose-template.yaml', 'r') as f:
        return f.read()

def docker_compose_up(env_data: str) -> None:
    env_dict = dict(os.environ)
    parsed = dotenv_values(stream=StringIO(env_data))
    env_dict.update(parsed)

    subprocess.run(["docker", "compose", "up", "-d"], check=True)

if __name__ == '__main__':
    main()