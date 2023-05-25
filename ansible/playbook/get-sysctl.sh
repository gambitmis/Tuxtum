#!/bin/bash

# Function to retrieve the value of a sysctl parameter
get_sysctl_value() {
    parameter="$1"
    sysctl_value=$(sysctl -n "$parameter" 2>/dev/null)

    if [[ $? -eq 0 ]]; then
        echo "$sysctl_value"
    else
        echo "Error: Failed to retrieve the value of $parameter."
    fi
}

# Array of sysctl parameters and descriptions (one parameter per line)
read -r -d '' parameters << EOM
net.core.somaxconn "Increase the maximum number of allowed pending connections"
net.core.netdev_max_backlog "Max all network queue"
net.ipv4.tcp_max_syn_backlog "Max tcp queue"
net.ipv4.tcp_syncookies "Enable TCP SYN cookies to prevent SYN flood attacks"
net.ipv4.tcp_synack_retries "Number of times to retransmit SYNACK packets for a passive TCP connection before aborting"
net.ipv4.tcp_abort_on_overflow "Abort the connection when TCP memory is exhausted instead of sending a RST packet"
net.ipv4.tcp_tw_reuse "Enable or disable the reuse of TIME_WAIT sockets. A value of 1 enables reuse, while 0 disables it"
net.ipv4.tcp_fin_timeout "Time (in seconds) that a TCP connection in the FIN-WAIT-2 state remains open before being closed."
net.ipv4.tcp_keepalive_time "Time (sec) between TCP keepalive probes to check the status of idle connections.The default value is 7200 sec(2 Hrs)"
net.ipv4.tcp_keepalive_intvl "Time (sec) between individual keepalive probes after the initial probe is sent.The default value is 75 seconds."
net.ipv4.tcp_keepalive_probes "The max number of keepalive probes to be sent before considering the connection as idle or closed.The default is 9"
net.ipv4.ip_local_port_range ""
net.ipv4.udp_mem ""
net.ipv4.udp_rmem_min ""
net.ipv4.udp_wmem_min ""
fs.file-max "Increase the maximum number of open files"
fs.nr_open "Increase the maximum number of file handles per process"
net.ipv4.tcp_mem "Range of memory(byte) allocated for TCP buffers"
net.ipv4.tcp_rmem "Range of memory(byte) allocated for the receive buffer used by TCP sockets"
net.ipv4.tcp_wmem "Range of memory(byte) allocated for the send buffer used by TCP sockets"
kernel.shmmax "Max size (in bytes) of a shared memory segment that can be created"
kernel.pid_max "Max value for PIDs on the system. PIDs are unique identifiers assigned to each running process. The default value is typically 32768"
kernel.threads-max "Max number of threads (also known as tasks) that can be created on the system"
kernel.randomize_va_space "Virtual memory address space layout randomization (ASLR) feature. ASLR randomizes the memory addresses used by processes to make it more difficult for attackers to exploit vulnerabilities. A value of 0 disables ASLR, while a value of 2 enables full ASLR."
vm.dirty_ratio "Max % of system memory that can be filled with dirty pages (modified data waiting to be written to disk) before the kernel starts to write them to disk. The value is specified as a percentage of the total system memory. The default value is typically 20%."
vm.dirty_background_ratio "% of system memory that must be filled with dirty pages before the kernel starts background writeback. Background writeback occurs while the system is relatively idle. The default value is usually half of the dirty_ratio"
vm.max_map_count "Max number of memory map areas a process can have. It is used to prevent resource exhaustion caused by excessive memory mapping. The default value is typically 65536"
vm.swappiness "This parameter controls the tendency of the kernel to swap out memory pages to disk. It ranges from 0 to 100. A higher value means the kernel is more likely to swap, while a lower value means it tries to avoid swapping. The default value is usually 60"
vm.overcommit_memory "The kernel's memory overcommit policy. It controls how the kernel handles memory allocations when there is not enough physical memory available. The default value is 0"

EOM

# Split the parameters into an array
IFS=$'\n' read -d '' -r -a parameters_array <<< "$parameters"

# Loop through the array and retrieve the values
for parameter_info in "${parameters_array[@]}"; do
    IFS=' ' read -r parameter description <<< "$parameter_info"
    value=$(get_sysctl_value "$parameter")
    parameter_value=$(printf "%-40s%s" "$parameter =" "$value")
    printf "%-70s%s\n" "$parameter_value" "$description"
done
