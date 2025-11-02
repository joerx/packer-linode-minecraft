#!/usr/bin/env python3

# Utility script to clean up older images build from this repository.

import requests
import os
import logging
from datetime import datetime, timedelta
from urllib.parse import urlencode


log_level = os.getenv("LOG_LEVEL", "INFO").upper()
logging.basicConfig(level=log_level, stream=os.sys.stderr)


REPO="github.com/joerx/packer-linode-minecraft"
LINODE_TOKEN = os.getenv("LINODE_TOKEN")
DRY_RUN=os.getenv("DRY_RUN", "0") in ["1", "true", "True", "TRUE"]


def main():
  for image in find_deprecated_images():
    delete_image(image)


def map_tags(tags):
  tags_dict = {}
  for tag in tags:
    if ":" in tag:
      k, v = tag.split(":")
    else:
      k, v = tag, None
    tags_dict[k] = v
  return tags_dict


def find_deprecated_images(stable_channels = ["stable", "edge"], max_age = timedelta(days=7)):
  for image in find_images():
    channel = image["tags"].get("channel")
    label = image["label"]

    if channel in stable_channels:
      logging.debug(f"Image '{label}', channel='{channel}', skipping")
      continue
      
    age = datetime.now() - image["created"]

    if age <= max_age:
      logging.debug(f"Image '{label}', channel='{channel}', age {age}, within max age, retaining")
      continue

    logging.debug(f"Image '{label}', channel='{channel}', age {age}, marked deprecated")
    yield image


def delete_image(image):
    logging.info(f"Deleting image '{image['label']}' (ID: {image['id']})")
    linode_api_request(f"images/{image['id']}", method="delete")
    logging.info(f"Image '{image['label']}' deleted")


def linode_api_request(endpoint, method="get", **kwargs):
  query = urlencode(kwargs, doseq=True)
  
  url = f"https://api.linode.com/v4/{endpoint}?{query}"
  headers = {
    "accept": "application/json",
    "authorization": f"Bearer {LINODE_TOKEN}"
  }

  response = requests.request(method=method, url=url, headers=headers)
  logging.debug(f"Linode API {method.upper()} {url} -> {response.status_code}")
  
  response.raise_for_status()
  return response.json()


def find_images():
  cur_page = 0

  while True:
    body = linode_api_request("images", page=cur_page+1, page_size=50)
    
    num_pages = int(body["pages"])
    cur_page = int(body["page"])

    for image in body["data"]:
      # We only care about private images
      if image["is_public"]:
        continue

      tags = map_tags(image["tags"])
      if tags.get("repo") != REPO:
        logging.debug(f"Image '{image['label']}': repo tag '{tags.get('repo')}' does not match '{REPO}', skipping")
        continue

      yield {
        "created": datetime.strptime(image["created"], '%Y-%m-%dT%H:%M:%S'),
        "id": image["id"],
        "label": image["label"],
        "public": image["is_public"],
        "status": image["status"],
        "tags": map_tags(image["tags"]),
      }

    if cur_page >= num_pages:
      break
    

if __name__ == "__main__":
  main()