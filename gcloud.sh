#!/bin/bash

# Check if the .env_gcp file exists
if [ -f .env_gcp ]; then
  # If the .env_gcp file exists, source the environment variables from it
  source .env_gcp
  # Assign the environment variables from .env_gcp to the instance variable
  PROJECT="$PROJECT"
  INSTANCE="$INSTANCE"  
  # Display the contents of the instance variable
  echo "$PROJECT : VM $INSTANCE"
else
  echo "The .env_gcp file does not exist. you should create .env_gcp file."
  echo -e ".env_gcp file should be like this\n"
  echo "export PROJECT=\"###\""
  echo -e "export INSTANCE=\"###\"\n"
fi

# VM config
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
# "150GB""50GB"

# VM external ip address config
ACCESS_CONFIG_NAME="external-nat"
ADDRESS_NAME="static-ip-${INSTANCE}"
REGION="asia-northeast1"

# schedule for running and stopping VM
SCHEDULE_NAME="${INSTANCE}-schedule"


args=("create" "start" "stop" "ssh" "list" "describe" "ip" "ip_del" "schedule_add" "schedule_del" "schedule_lis")

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
elif [ "$1" = "${args[1]}" ]; then
  start_time=$(date)
  echo "Start ${INSTANCE} now(${start_time}) and this VM would stop in $2 hour $3 min"
  if [ $# -ne 3 ]; then
      echo -e "Error: $0 $1 command exactly 3 arguments are required. You wanna stop VM automatically. \nyou should execute like\n\n$0 $1 <hour> <min>\n\nVM automatically would stop after <hour> <min> time has exceeded."
      echo -e "\nExample: If you want to stop VM in 1hour 30min, execute like\n\n$0 $1 1 30"
      exit 1
  fi
  if [ "$2" = "0" ] && [ "$3" = "0" ]; then
      echo -e "Error: $0 $1 $2 $3\nboth $2 and $3 should be avoided, because this will stop immediately."
      echo -e "\nExample: If you want to stop VM in 1hour 30min, execute like\n$0 $1 1 30"
      exit 1
  fi
  gcloud compute instances start $INSTANCE
  echo "Do not stop this program! VM is running"
  # 時間と分を定義
  HOUR=$2
  MIN=$3
  # 時間を分に変換
  hours_to_minutes=$(($HOUR*60))
  # 分を秒に変換
  minutes_to_seconds=$(($hours_to_minutes*60))
  # 分を秒に変換
  min_to_seconds=$(($MIN*60))
  # 合計秒数を算出
  total_seconds=$(($minutes_to_seconds + $min_to_seconds))
  echo "sleep ${total_seconds} secs"
  # 計算した秒数だけ待つ
  sleep $total_seconds
  echo "$2 hour $3 min exceeded from when you start VM ${INSTANCE}"
  echo "Stopping automatically ${INSTANCE}"
  gcloud compute instances stop $INSTANCE
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
elif [ "$1" = ${args[6]} ]; then
    # https://cloud.google.com/compute/docs/ip-addresses/reserve-static-external-ip-address?hl=ja
    gcloud compute addresses create $ADDRESS_NAME \
      --region=$REGION
    #   --global \
    #   --ip-version IPV4
    # Get the external IP address
    IP_ADDRESS=$(gcloud compute addresses describe $ADDRESS_NAME --region $REGION --project $PROJECT --format="json" | jq -r .address)
    # IP_ADDRESS=$(gcloud compute addresses describe --global $ADDRESS_NAME --project $PROJECT --format="json" | jq -r .address)
    echo "Attach static external IP address ${ADDRESS_NAME} (${IP_ADDRESS}) to VM ${INSTANCE} for ssh"
    gcloud compute instances delete-access-config $INSTANCE \
      --access-config-name="${ACCESS_CONFIG_NAME}"
    gcloud compute instances add-access-config $INSTANCE \
      --access-config-name="${ACCESS_CONFIG_NAME}" --address=$IP_ADDRESS
elif [ "$1" = ${args[7]} ]; then
    gcloud compute addresses delete $ADDRESS_NAME
    # gcloud compute addresses delete $ADDRESS_NAME --global
# elif [ "$1" = ${args[8]} ]; then
#     # https://cloud.google.com/compute/docs/instances/schedule-instance-start-stop?hl=ja
#     echo "add schedule on VM"
#     if [ $# -ne 3 ]; then
#       echo -e "Error: $0 $1 command exactly 3 arguments are required. You wanna add VM automatically stop schedule. \nyou should execute like\n\n$0 $1 <hour> <min>\n\nVM automatically would stop <hour> everyday."
#       echo -e "\nExample: If you want to stop VM in 23:30 in 24 hours everyday, execute like\n\n$0 $1 23 30"
#       exit 1
#     fi

#     gcloud compute resource-policies create instance-schedule $SCHEDULE_NAME \
#       --description="stop at $2:$3 every day on ${INSTANCE}" \
#       --vm-stop-schedule="$3 $2 * * *" \
#       --timezone="Asia/Tokyo"
#       # "JST"
#       # cron : min hour day month week # https://www.kagoya.jp/howto/it-glossary/server/cron/
#     gcloud compute instances add-resource-policies $INSTANCE \
#       --resource-policies=$SCHEDULE_NAME
# elif [ "$1" = ${args[9]} ]; then
#     echo "gcloud compute resource-policies delete ${SCHEDULE_NAME}"
#     gcloud compute resource-policies delete $SCHEDULE_NAME
#     gcloud compute resource-policies list
# elif [ "$1" = ${args[10]} ]; then
#     echo "gcloud compute resource-policies list"
#     gcloud compute resource-policies list
else
  echo -e "Usage: $0 <arg1>\n<arg1> should be either one of the following option\n"
  for arg in "${args[@]}"
  do
    echo -e $0 $arg
  done
  exit 1
fi

# インスタンスへローカルのファイルをコピーする
# gcloud compute scp <local-path> <your-instance-name>:<remote-path> --zone <zone>

# インスタンスにあるファイルをローカルにコピーする
# gcloud compute scp <your-instance-name>:<remote-path> <local-path> --zone <zone>

# ディレクトリをコピーしたい時、--recurseオプション付ける
# gcloud compute scp --recurse