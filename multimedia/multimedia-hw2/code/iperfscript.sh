echo "date,c_IP,c_port,s_ip,s_port,trans_ID,time,trans,bitrate" > iperftime.csv
for i in  0.1 0.3 0.5 0.8 1 1.5 2 3 5 8 10 20 30 40 50 60
do
  iperf -c 88.80.187.84 -p 20180 -b 100M -N -y c -t $i >> iperftime.csv
done
