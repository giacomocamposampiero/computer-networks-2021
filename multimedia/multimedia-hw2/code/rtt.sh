echo "Round-Trip-Time Experiment" > rtt.txt
i=20
while [ $i -le 1460 ]
do
  ping -q -M do -s $i -c 100 88.80.187.84 >> rtt.txt
  echo "$i"
  i=$(( $i + 20 ))
done

