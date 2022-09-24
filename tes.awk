#!/usr/bin/awk -f
BEGIN {
sendPacket = 0;
recvPacket = 0;
RTRsend = 0;
cbrRecv = 0;
# e2e
seqNo = -1;
count = 0;
}
$0 ~/^s.*AGT.*/ {
sendPacket++;
}
$0 ~/^r.*AGT.*/ {
recvPacket++;
}
$0 ~/^[sf].*RTR.*DSR/ {
RTRsend++;
}
$0 ~/^r.*AGT.*cbr/ {
cbrRecv++;
}
# e2e
{
if($19 == "AGT" && $1 == "s" && seqno < $47){
seqNo = $47;
}
if($19 == "AGT" && $1 == "s"){
start_time[$47] = $3;
}else if ($19 == "AGT" && $1 == "r"){
end_time[$47] = $3;
}else if($19 == "AGT" && $1 == "d"){
72
end_time[$47] = -1;
}
}
END {
packetDelivery = 0.0;
routingOverhead = 0.0;
packetDelivery = (recvPacket/sendPacket) * 100.00
routingOverhead = (RTRsend/cbrRecv)
printf "Total Packet Sent : %d\n",sendPacket;
printf "Total Packet Received : %d\n",recvPacket;
printf "Packet Delivery Ratio : %s\n",packetDelivery;
printf "Routing Overhead %s\n",routingOverhead;
for(i=0; i<= seqNo; i++){
if(end_time[i]>0){
delay[i] = end_time[i] - start_time[i];
count++;
}else{
delay[i] = -1;
}
}
for(i=0;i<=count;i++){
if(delay[i]>0){
e2edelay = (e2edelay + delay[i]) # get total delay
}
}
e2edelay = e2edelay / count ; # calculate avg end to end delay
printf "End to End Delay : %s s\n",e2edelay;
}