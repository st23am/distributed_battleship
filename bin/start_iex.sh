# ################################################
# Player
# ###############################################

if [[ $# -ne 2 ]]; then
  echo "usage: `basename $0` commander_ip playername"
  exit 2
fi

commander_ip=$1
playername=$2

iex --erl '-kernel inet_dist_listen_min 9000' --erl '-kernel inet_dist_listen_max 9100' --name $playername@$commander_ip 
