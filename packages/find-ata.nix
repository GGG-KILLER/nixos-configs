{ pog, coreutils }:
pog.pog {
  name = "find-ata";
  description = "Find the device assigned the ATA ID provided";
  runtimeInputs = [ coreutils ];
  arguments = [
    {
      name = "ATA_ID";
      required = true;
    }
  ];
  strict = true;
  script = ''
    shopt -s nullglob

    if [[ $# -lt 1 ]]; then
      die "usage: $0 ATA_ID"
    fi

    ATA_ID="$1"
    echo "ATA_ID: $ATA_ID"

    if ! [[ $ATA_ID =~ ^[0-9]+$ ]]; then
      die "error: ATA_ID must be a number"
    fi

    ATA_HOST=""
    for unique_id in /sys/class/scsi_host/host*/unique_id; do
      if [[ $(cat "$unique_id") == *"$ATA_ID"* ]]; then
        ATA_HOST=$(basename "$(dirname "$unique_id")")
        break
      fi
    done

    if [[ -z $ATA_HOST ]]; then
      die "error: ATA_ID host not found"
    fi

    ATA_DEVICE=""
    for device in /sys/block/*; do
      if [[ $(readlink "$device") == */"$ATA_HOST"/* ]]; then
        ATA_DEVICE=$(basename "$device")
        break
      fi
    done

    if [[ -z $ATA_DEVICE ]]; then
      die "error: ATA_ID device not found"
    fi

    for device in /dev/disk/by-id/*; do
      if [[ $(readlink "$device") == */"$ATA_DEVICE" ]]; then
        echo "ata$ATA_ID: $device"
        break
      fi
    done
  '';
}
