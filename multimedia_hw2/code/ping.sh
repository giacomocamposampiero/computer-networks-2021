echo "Time-To-Live Experiment" > ttl.txt
for i in  8 9 10 11 12 13 14 15 
do
  echo "TTL $i" >> ttl.txt
  echo "+++++++++++++++++++++++" >> ttl.txt
  ping -q -c 15 -t $i 88.80.187.84 >> ttl.txt
done
