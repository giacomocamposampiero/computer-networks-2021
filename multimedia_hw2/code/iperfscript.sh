echo "date,c_IP,c_port,s_ip,s_port,trans_ID,time,trans,bitrate" > iperf.csv
i=0
while [ $i -le 439 ]
do
  iperf -c 88.80.187.84 -p 20180 -b 500M -N -y c >> iperf.csv
  i=$(( $i + 1 ))
  echo "$i"
  sleep 30s
done
