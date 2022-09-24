BEGIN{
recvd = 0;#################### to calculate total number of data packets received
rt_pkts = 0;################## to calculate total number of routing packets received
}

{
##### Check if it is a data packet
if (( $1 == "r") && ( $7 == "cbr" || $7 =="tcp" ) && ( $4=="AGT" )) recvd++;

##### Check if it is a routing packet
if (($1 == "s" || $1 == "f") && $4 == "RTR" && ($7 =="udp" || $7 == "DSR" || $7 =="message" || $7 =="" || $7 =="")) rt_pkts++;

}


END{

printf("\n");
printf("total no of data packets\t%d\n",recvd);
printf("\ntotal no of routing packets\t%d\n",rt_pkts);
printf("\nNormalized Routing Load         %.3f\n", rt_pkts/recvd);
printf("\n");

}
