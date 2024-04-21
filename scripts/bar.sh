#!/bin/dash

# ^c$var^ = fg color
# ^b$var^ = bg color

interval=0

# load colors
. ~/projects/chadwm/scripts/bar_themes/onedark

cpu() {
	cpu_val=$(grep -o "^[^ ]*" /proc/loadavg)

	printf "^c$black^ ^b$green^ CPU"
	printf "^c$white^ ^b$grey^ $cpu_val"
}

pkg_updates() {
	#updates=$({ timeout 20 doas xbps-install -un 2>/dev/null || true; } | wc -l) # void
	updates=$({ timeout 20 checkupdates 2>/dev/null || true; } | wc -l) # arch
	# updates=$({ timeout 20 aptitude search '~U' 2>/dev/null || true; } | wc -l)  # apt (ubuntu, debian etc)

	if [ -z "$updates" ]; then
		printf "  ^c$green^    Fully Updated"
	else
		printf "  ^c$green^    $updates"" updates"
	fi
}

battery() {
	get_capacity="$(cat /sys/class/power_supply/BAT0/capacity)"
	status="$(cat /sys/class/power_supply/BAT0/status)"
	if [ "$status" = "Charging" ]; then
		printf "^c$blue^   $get_capacity"
		dunstify -C 100
	elif [ "$status" = "Full" ]; then
		printf "^c$green^ 󱟢  Full"
	else
		# if [ $get_capacity -eq 10 ] || [ $get_capacity -eq 5 ] || [ $get_capacity -leq 2 ]; then
		# 	$(sleep 10 && lowbatterynotify >>/dev/null &)
		# fi
		printf "^c$yellow^ 󱟞  $get_capacity"
	fi
}

brightness() {
	printf "^c$red^   "
	printf "^c$red^%.0f\n" $(mini-brightness -get)
}

mem() {
	printf "^c$blue^^b$black^  "
	printf "^c$blue^ $(free -h | awk '/^Mem/ { print $3 }' | sed s/i//g)"
}

wlan() {
	case "$(cat /sys/class/net/wl*/operstate 2>/dev/null)" in
	up) printf "^c$black^ ^b$blue^ 󰤨 ^d^%s" " ^c$blue^Connected" ;;
	down) printf "^c$black^ ^b$blue^ 󰤭 ^d^%s" " ^c$blue^Disconnected" ;;
	esac
}

clock() {
	printf "^c$black^ ^b$darkblue^ 󱑆 "
  printf "^c$black^^b$blue^ $(date '+%I:%M %P %d/%m(%a)')  "
}

volume() {
	get_volume="$(amixer sget Master | awk -F"[][]" '/Left:/ { print $2 }')"
	amixer sget Master | grep -q '\[on\]'
	is_muted=$(echo $?)
	if [ $is_muted -eq 1 ]; then
		printf "^c$mutedcolor^ 🔇 %s" $get_volume
	else
		printf "^c$green^ 󰕾 %s" $get_volume
	fi
}

keyboard() {
	kb_lang="$(setxkbmap -query | awk '/layout/{print $2}' | awk -F',' '{print substr($1,1,2)}')"
	if [ "$kb_lang" = "us" ]; then
		is_caps_active="$(xset -q | grep Caps | awk '{print $4}')"
		if [ "$is_caps_active" = "on" ]; then
			kb_lang="US"
		fi
	fi
	printf "^c$black^ ^b$white^ %s " "$kb_lang"
}

while true; do
	sleep 1 && xsetroot -name "$(battery) $(brightness) $(volume) $(cpu) $(mem) $(clock) $(keyboard)"
done
