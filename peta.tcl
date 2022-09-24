#Set all the options

set val(chan)         Channel/WirelessChannel  ;# channel type
set val(prop)         Propagation/TwoRayGround ;# radio-propagation model
set val(ant)          Antenna/OmniAntenna      ;# Antenna type
set val(ll)           LL                       ;# Link layer type
set val(ifq)          Queue/DropTail/PriQueue		 ;# Interface queue type
set val(ifqlen)       50                       ;# max packet in ifq
set val(netif)        Phy/WirelessPhyExt          ;# network interface type
set val(mac)          Mac/802_11Ext               ;# MAC type
set val(rp)           DSDV                     ;# routing protocol
set val(x)            3000		       ;# X length
set val(y)            3000		       ;# Y length
set val(finish)       500		       ;# Finish time
set val(nn)           30		       ;# number of mobilenodes



Phy/WirelessPhyExt set CSThresh_ 3.9810717055349694e-13 ;# -94 dBm wireless interface sensitivity
Phy/WirelessPhyExt set Pt_ 0.002 ;# equals 20dBm when considering antenna gains of 1.0
Phy/WirelessPhyExt set freq_ 5.9e+9
Phy/WirelessPhyExt set noise_floor_ 1.26e-13 ;# -99 dBm for 10MHz bandwidth
Phy/WirelessPhyExt set L_ 1.0 ;# default radio circuit gain/loss
Phy/WirelessPhyExt set PowerMonitorThresh_ 3.981071705534985e-18 ;# -174 dBm power monitor sensitivity (=level of gaussian noise)
Phy/WirelessPhyExt set HeaderDuration_ 0.000040 ;# 40 us
Phy/WirelessPhyExt set BasicModulationScheme_ 0
Phy/WirelessPhyExt set PreambleCaptureSwitch_ 1
Phy/WirelessPhyExt set DataCaptureSwitch_ 1
Phy/WirelessPhyExt set SINR_PreambleCapture_ 3.1623; ;# 5 dB
Phy/WirelessPhyExt set SINR_DataCapture_ 10.0; ;# 10 dB
Phy/WirelessPhyExt set trace_dist_ 1e6 ;# PHY trace until distance of 1 Mio. km ("infinity")
Phy/WirelessPhyExt set PHY_DBG_ 0
Mac/802_11Ext set CWMin_ 15
Mac/802_11Ext set CWMax_ 1023
Mac/802_11Ext set SlotTime_ 0.000013
Mac/802_11Ext set SIFS_ 0.000032
Mac/802_11Ext set ShortRetryLimit_ 7
Mac/802_11Ext set LongRetryLimit_ 4
Mac/802_11Ext set HeaderDuration_ 0.000040
Mac/802_11Ext set SymbolDuration_ 0.000008
Mac/802_11Ext set BasicModulationScheme_ 0
Mac/802_11Ext set use_802_11a_flag_ true
Mac/802_11Ext set RTSThreshold_ 2346
Mac/802_11Ext set MAC_DBG 0 


set ns_ [new Simulator]

set f [open peta.tr w]
$ns_ trace-all $f 
set namtrace [open peta.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
 
set god_ [create-god $val(nn)]
set chan_1 [new $val(chan)]

# CONFIGURE AND CREATE NODES

$ns_ node-config  -adhocRouting $val(rp) \
          -llType $val(ll) \
                 -macType $val(mac) \
                 -ifqType $val(ifq) \
                 -ifqLen $val(ifqlen) \
                 -antType $val(ant) \
                 -propType $val(prop) \
                 -phyType $val(netif) \
                 -topoInstance $topo \
                 -agentTrace ON \
                 -routerTrace ON \
                 -macTrace ON \
                 -movementTrace ON \
                 -channel $chan_1

for {set i 0} {$i < $val(nn) } { incr i } {
        set node_($i) [$ns_ node]
 $ns_ initial_node_pos $node_($i) 20
    }


proc finish {} {
    global ns_ namtrace filename
    $ns_ flush-trace
    close $namtrace  
    exec nam peta.nam &
    exit 0
}

source mobility.tcl
$ns_ at 0.0 "$node_(1) color blue"
$node_(1) color "blue"
$ns_ at 0.0 "$node_(2) color orange"
$node_(2) color "orange"

#
# nodes: 30, max conn: 1, send rate: 0.25, seed: 1.0
#
#
# 1 connecting to 2 at time 10.0
#
set udp_(0) [new Agent/UDP]
$ns_ attach-agent $node_(1) $udp_(0)
set null_(0) [new Agent/Null]
$ns_ attach-agent $node_(2) $null_(0)
set cbr_(0) [new Application/Traffic/CBR]
$cbr_(0) set packetSize_ 512
$cbr_(0) set interval_ 0.25
$cbr_(0) set random_ 1
$cbr_(0) set maxpkts_ 10000
$cbr_(0) attach-agent $udp_(0)
$ns_ connect $udp_(0) $null_(0)
$ns_ at 10.0 "$cbr_(0) start"
$ns_ at 500.0 "$cbr_(0) stop"

$ns_ at $val(finish) "finish"
puts "Start of simulation..."
$ns_ run
