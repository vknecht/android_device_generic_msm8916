#!/system/bin/sh

# Adapted from
# https://gitlab.com/postmarketOS/pmaports/-/blob/master/modem/msm-modem/msm-modem-uim-selection.initd

case "$(cat /sys/devices/soc0/machine)" in
APQ*)
	# Skipping SIM configuration on APQ SoC.
	exit 0
esac

# libqmi must be present to use this script.
if ! [ -e "/vendor/bin/qmicli" ]
then
	# qmicli is not installed.
	exit 1
fi

# Prepare a qmicli command with desired modem path.
# The modem may appear after some delay, wait for it.
count=0
while [ -z "$QMICLI_MODEM" ] && [ "$count" -lt "45" ]
do
	# Check if legacy rpmsg exported device exists.
	if [ -e "/dev/modem" ]
	then
		QMICLI_MODEM="qmicli --silent -d /dev/modem"
		# Using /dev/modem
	# Check if the qmi device from wwan driver exists.
	elif [ -e "/dev/wwan0qmi0" ]
	then
		# Using --device-open-qmi flag as we may have libqmi
		# version that can't automatically detect the type yet.
		QMICLI_MODEM="qmicli --silent -d /dev/wwan0qmi0 --device-open-qmi"
		# Using /dev/wwan0qmi0
	# Check if QRTR is available for new devices.
	elif qmicli --silent -pd qrtr://0 --uim-noop > /dev/null
	then
		QMICLI_MODEM="qmicli --silent -pd qrtr://0"
		# Using qrtr://0
	fi
	sleep 1
	count=$((count+1))
done

if [ -z "$QMICLI_MODEM" ]
then
	# No modem available.
	exit 2
fi

QMI_CARDS=$($QMICLI_MODEM --uim-get-card-status)

# Fail if all slots are empty but wait a bit for the sim to appear.
count=0
while ! printf "%s" "$QMI_CARDS" | grep -Fq "Card state: 'present'"
do
	if [ "$count" -ge "$sim_wait_time" ]
	then
		# No sim detected after $sim_wait_time seconds.
		exit 4
	fi

	sleep 1
	count=$((count+1))
	QMI_CARDS=$($QMICLI_MODEM --uim-get-card-status)
done

# Clear the selected application in case the modem is in a bugged state
if ! printf "%s" "$QMI_CARDS" | grep -Fq "Primary GW:   session doesn't exist"
then
	# Application was already selected.
	$QMICLI_MODEM --uim-change-provisioning-session='activate=no,session-type=primary-gw-provisioning' > /dev/null
fi

# Extract first available slot number and AID for usim application
# on it. This should select proper slot out of two if only one UIM is
# present or select the first one if both slots have UIM's in them.
FIRST_PRESENT_SLOT=$(printf "%s" "$QMI_CARDS" | grep "Card state: 'present'" -m1 -B1 | head -n1 | cut -c7-7)
### Remove -m1 from grep command or get "Application" instead of AID
#FIRST_PRESENT_AID=$(printf "%s" "$QMI_CARDS" | grep "usim (2)" -m1 -A3 | tail -n1 | awk '{print $1}')
FIRST_PRESENT_AID=$(printf "%s" "$QMI_CARDS" | grep "usim (2)" -A3 | tail -n1 | awk '{print $1}')

# Finally send the new configuration to the modem.
$QMICLI_MODEM --uim-change-provisioning-session="slot=$FIRST_PRESENT_SLOT,activate=yes,session-type=primary-gw-provisioning,aid=$FIRST_PRESENT_AID" > /dev/null

ret=$?
exit $ret
