ip_address=$(/sbin/ifconfig | grep -oE 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | awk '{print $2}')
last_ip=$(echo "$ip_address" | awk -F':' '{print $2}' | awk '{print $NF}' | tail -n 1)
echo $last_ip
