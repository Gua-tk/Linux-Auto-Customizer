#!/usr/bin/env bash
wireshark_name="Wireshark"
wireshark_description="Network Analyzer"
wireshark_version="System dependent"
wireshark_tags=("customDesktop" "hacking")
wireshark_systemcategories=("Monitor" "Network" "Qt")

wireshark_launcherkeynames=("default")
wireshark_default_exec="wireshark %f"
wireshark_associatedfiletypes=("application/vnd.tcpdump.pcap" "application/x-pcapng" "application/x-snoop"
"application/x-iptrace" "application/x-lanalyzer" "application/x-nettl" "application/x-radcom"
"application/x-visualnetworks" "application/x-netinstobserver" "application/x-5view" "application/x-tektronix-rf5"
"application/x-micropross-mplog" "application/x-apple-packetlogger" "application/x-endace-erf" "application/ipfix"
"application/x-ixia-vwr")
wireshark_packagenames=("wireshark")
