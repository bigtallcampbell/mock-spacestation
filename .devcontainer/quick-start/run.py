import os
import time
import json
from datetime import datetime

print("Starting up Container")

print("Retrieving Configuration File")
config_path = "./config/config.json"
print(f"Getting from file path - {config_path}")

try:
    print(f"Loading configuration from file = {config_path}")
    config_file = open(config_path)
    config = json.load(config_file)
    config_file.close()
    print(f"Configuration File Retrieved - {config_path}")
except IOError:
    print("ERROR - Config File Not Found")

message = config["test"]
location = "space"
message = message.replace("__token__",location)

print("Setting Output Directory")
folderVal = datetime.now().strftime("%y%m%d%H%M%S")
outputDir = f"./output/{folderVal}"
os.mkdir(outputDir)
print(f"Output Directory Set - {outputDir}")

print("Write output to folder")
outputFile = open(f"{outputDir}/test.txt","w+")
outputFile.write(message)
outputFile.close()

print("Completed Container Execution")