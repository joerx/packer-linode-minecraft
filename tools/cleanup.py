#!/usr/bin/env python3

# Utility script to clean up older images build from this repository.

import requests
import os
import logging
from datetime import datetime, timedelta
from urllib.parse import urlencode


STABLE_CHANNELS = ["stable", "edge"]
MAX_AGE_DAYS = 7
REPO="github.com/joerx/packer-linode-minecraft"
LINODE_TOKEN = os.getenv("LINODE_TOKEN")
DRY_RUN=os.getenv("DRY_RUN", "0") in ["1", "true", "True", "TRUE"]
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO").upper()


logging.basicConfig(level=LOG_LEVEL, stream=os.sys.stderr)


def main():
  for image in find_deprecated_images():
    delete_image(image, dry_run=DRY_RUN)


def find_deprecated_images(stable_channels=STABLE_CHANNELS, max_age=timedelta(days=MAX_AGE_DAYS), repo=REPO):
  """Find all image versions that are considered deprecated based on their channel and age."""

  images = find_images(repo=repo)
  image_versions = group_images_by_label(images)

  for image in image_versions:
    for version in image["versions"]:
      label = image["label"]
      channel = version["tags"].get("channel")
      age = datetime.now() - version["created"]

      # Only the latest version of each stable channel is retained
      if channel in stable_channels and version["is_latest"]:
        logging.debug(f"Image '{label}', channel='{channel}', skipping latest version of stable release")
        continue
        
      # All other image versions will be retained only if within max age
      if age <= max_age:
        logging.debug(f"Image '{label}', channel='{channel}', age {age}, within max age, retaining")
        continue

      logging.debug(f"Image '{label}', channel='{channel}', age {age}, marking as deprecated")
      yield version


def delete_image(image, dry_run=False):
    logging.info(f"Deleting image '{image['label']}' (ID: {image['id']})")
    if dry_run:
      logging.info(f"Image '{image['label']}' would have been deleted (dry run)")
    else:
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


def group_images_by_label(images):
  """Group images by their label, collecting all versions under each label."""

  image_map = dict()
  images = sorted(images, key=lambda i: i["created"], reverse=True)
  
  for image in images:
    label = image["label"]
    is_latest = False

    if label not in image_map:
      is_latest = True
      image_map[label] = {
        "label": label,
        "versions": []
      }

    image_map[label]["versions"].append({
      "label": image["label"],
      "id": image["id"],
      "created": image["created"],
      "status": image["status"],
      "tags": image["tags"],
      "is_latest": is_latest,
    })

  return image_map.values()


def find_images(repo):
  """Find all images matching the given repo tag. Images are grouped by label, with all versions included."""

  cur_page = 0
  images = []

  while True:
    body = linode_api_request("images", page=cur_page+1, page_size=50)
    
    num_pages = int(body["pages"])
    cur_page = int(body["page"])

    for image in body["data"]:
      # We only care about private images
      if image["is_public"]:
        continue

      # Make sure we only get images from this repo
      tags = map_tags(image["tags"])
      if tags.get("repo") != repo:
        logging.debug(f"Image '{image['label']}': repo tag '{tags.get('repo')}' does not match '{repo}', skipping")
        continue

      images.append({
        "label": image["label"],
        "created": datetime.strptime(image["created"], '%Y-%m-%dT%H:%M:%S'),
        "id": image["id"],
        "status": image["status"],
        "tags": map_tags(image["tags"]),
      })

    if cur_page >= num_pages:
      return images
    

def map_tags(tags):
  tags_dict = {}
  for tag in tags:
    if ":" in tag:
      k, v = tag.split(":")
    else:
      k, v = tag, True
    tags_dict[k] = v
  return tags_dict


if __name__ == "__main__":
  main()