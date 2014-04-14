pg="/home/randalltux/.xmonad/symbol/plug.xbm"

jam () {
	clock=$(date +%R)
	echo -n $clock
	return
}

while :; do
echo "^fg(#2d2d2d)^bg(#dedede)    \
^i($pg)   \
^fg()^bg()\
^bg(#444444) \
  $(jam)   \
^bg()"
sleep 1
done | dzen2 -p -ta r -e 'button3=' -fn 'Ubuntu-8' -fg '#ffffff' -bg '#2d2d2d' -h 24 -w 666 -x 700
