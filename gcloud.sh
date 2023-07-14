#!/bin/bash

# Check if the .env file exists
if [ -f .env ]; then
  # If the .env file exists, source the environment variables from it
  source .env
  # Assign the environment variables from .env to the instance variable
  PROJECT="$PROJECT"
  INSTANCE="$INSTANCE"  
  # Display the contents of the instance variable
  echo "$PROJECT : VM $INSTANCE"
else
  echo "The .env file does not exist. you should create .env file"
fi

ZONE="asia-northeast1-a"
MACHINE_TYPE="n1-standard-2"
# "n1-standard-4"
IMAGE_PROJECT="deeplearning-platform-release"
# $ gcloud compute images list --project deeplearning-platform-release
IMAGE_FAMILY="pytorch-latest-gpu-ubuntu-2004-py310"
# IMAGE_FAMILY="ubuntu-2204-lts"
# https://cloud.google.com/compute/docs/gpus?hl=ja#introduction
GPU="type=nvidia-tesla-t4,count=1"
BOOT_DISK_TYPE="pd-balanced"
BOOT_DISK_SIZE="100GB"
# BOOT_DISK_SIZE="150GB"
# BOOT_DISK_SIZE="50GB"

args=("create" "start" "stop" "ssh" "list" "describe")

# create VM instance on GCE
if [ "$1" = ${args[0]} ]; then
	echo "Create ${INSTANCE}"
	gcloud compute --project=$PROJECT instances create $INSTANCE \
	  --zone=$ZONE \
	  --machine-type=$MACHINE_TYPE \
	  --accelerator=$GPU \
	  --image-project=$IMAGE_PROJECT \
	  --image-family=$IMAGE_FAMILY \
	  --metadata="install-nvidia-driver=True" \
	  --subnet=default \
	  --maintenance-policy=TERMINATE \
	  --boot-disk-size=$BOOT_DISK_SIZE \
	  --boot-disk-type=$BOOT_DISK_TYPE
	  #  \
	  # --preemptible
elif [ "$1" = ${args[1]} ]; then
  echo "Start ${INSTANCE}"
  gcloud compute instances start $INSTANCE
elif [ "$1" = ${args[2]} ]; then
  echo "Stopping ${INSTANCE}"
  gcloud compute instances stop $INSTANCE
elif [ "$1" = ${args[3]} ]; then
	# https://memo.koya-it.com/cloud_serverless/gcp_gce.html
	# 22番が開くまで待つ
	IP=$(gcloud compute instances list | awk '/'${INSTANCE}'/ {print $5}')
	if nc -w 5 -z $IP 22; then
	    echo "OK! Open port 22 for ${INSTANCE}"
	else
	    echo "5secs exceeds. Maybe VM ${INSTANCE} not started yet?"
	    exit 1
	fi
	gcloud compute ssh $INSTANCE
elif [ "$1" = ${args[4]} ]; then
	gcloud compute instances list
elif [ "$1" = ${args[5]} ]; then
	gcloud compute instances describe $INSTANCE
elif [ "$1" = "-h" ]; then
  echo "Usage: $0 <arg1>"
  echo "<arg1> should be either one of <${args[@]}>"
  exit 1
else
  echo "Usage: $0 <arg1>"
  echo "<arg1> should be either one of <${args[@]}>"
  exit 1
fi

# インスタンスへローカルのファイルをコピーする
# gcloud compute copy-files <local-path> <your-instance-name>:<remote-path> --zone <zone>

# インスタンスにあるファイルをローカルにコピーする
# gcloud compute copy-files <your-instance-name>:<remote-path> <local-path> --zone <zone>
# gcloud compute scp --recurse $INSTANCE: