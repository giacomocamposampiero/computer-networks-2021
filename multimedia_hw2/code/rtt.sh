echo "Round-Trip-Time Experiment" > rtt.txt

for i in  50 80 100 130 150
do
  ping -q -s $i -c 40 88.80.187.84 >> rtt.txt
  echo "$i"
done
i=$(( $i + 50 ))
while [ $i -le 2000 ]
do
  ping -q -s $i -c 40 88.80.187.84 >> rtt.txt
  echo "$i"
  i=$(( $i + 50 ))
done

