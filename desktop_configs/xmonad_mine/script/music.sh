while true
do
MUS=$(mpc -f "%title%" current | toilet -f pagga)
PLY=$(mpc -f "%artist%" current | toilet -f pagga)
BY=$(echo "by - " | toilet -f pagga)
tput civis
clear
echo "$MUS 
$PLY"
sleep 1
done
