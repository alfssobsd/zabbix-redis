#!/bin/bash

#Redis status

METRIC="$2"
SERV="$1"
DB="$3"

PORT="6379"

if [[ -z "$1" ]]; then
    echo "Please set server"
    exit 1
fi

CACHETTL="55" # Время действия кеша в секундах (чуть меньше чем период опроса элементов)
CACHE="/tmp/redis-status-`echo $SERV | md5sum | cut -d" " -f1`.cache"

if [ -s "$CACHE" ]; then
    TIMECACHE=`stat -c"%Z" "$CACHE"`
else
    TIMECACHE=0
fi

TIMENOW=`date '+%s'`

if [ "$(($TIMENOW - $TIMECACHE))" -gt "$CACHETTL" ]; then
    (echo -en "INFO\r\n"; sleep 1;) | nc -w1 $SERV $PORT > $CACHE || exit 1
fi

FIRST_ELEMENT=1
function json_head {
    printf "{";
    printf "\"data\":[";    
}

function json_end {
    printf "]";
    printf "}";
}

function check_first_element {
    if [[ $FIRST_ELEMENT -ne 1 ]]; then
        printf ","
    fi
    FIRST_ELEMENT=0
}

function databse_detect {
    json_head
    for dbname in $LIST_DATABSE
    do
        local dbname_t=$(echo $dbname| sed 's!\n!!g')
        check_first_element
        printf "{"
        printf "\"{#DBNAME}\":\"$dbname_t\""
        printf "}"
    done
    json_end
}

case $METRIC in
    'redis_version')
        cat $CACHE | grep "redis_version:" | cut -d':' -f2
        ;;            
    'redis_git_sha1')
        cat $CACHE | grep "redis_git_sha1:" | cut -d':' -f2
        ;;
    'redis_git_dirty')
        cat $CACHE | grep "redis_git_dirty:" | cut -d':' -f2
        ;;
    'redis_mode')
        cat $CACHE | grep "redis_mode:" | cut -d':' -f2
        ;;
    'arch_bits')
        cat $CACHE | grep "arch_bits:" | cut -d':' -f2
        ;;
    'multiplexing_api')
        cat $CACHE | grep "multiplexing_api:" | cut -d':' -f2
        ;;
    'gcc_version')
        cat $CACHE | grep "gcc_version:" | cut -d':' -f2
        ;;
    'uptime_in_seconds')
        cat $CACHE | grep "uptime_in_seconds:" | cut -d':' -f2
        ;;
    'lru_clock')
        cat $CACHE | grep "lru_clock:" | cut -d':' -f2
        ;;            
    'connected_clients')
        cat $CACHE | grep "connected_clients:" | cut -d':' -f2
        ;;
    'client_longest_output_list')
        cat $CACHE | grep "client_longest_output_list:" | cut -d':' -f2
        ;;
    'client_biggest_input_buf')
        cat $CACHE | grep "client_biggest_input_buf:" | cut -d':' -f2
        ;;
    'used_memory')
        cat $CACHE | grep "used_memory:" | cut -d':' -f2
        ;;
    'used_memory_peak')
        cat $CACHE | grep "used_memory_peak:" | cut -d':' -f2
        ;;        
    'mem_fragmentation_ratio')
        cat $CACHE | grep "mem_fragmentation_ratio:" | cut -d':' -f2
        ;;
    'loading')
        cat $CACHE | grep "loading:" | cut -d':' -f2
        ;;            
    'rdb_changes_since_last_save')
        cat $CACHE | grep "rdb_changes_since_last_save:" | cut -d':' -f2
        ;;
    'rdb_bgsave_in_progress')
        cat $CACHE | grep "rdb_bgsave_in_progress:" | cut -d':' -f2
        ;;
    'aof_rewrite_in_progress')
        cat $CACHE | grep "aof_rewrite_in_progress:" | cut -d':' -f2
        ;;
    'aof_enabled')
        cat $CACHE | grep "aof_enabled:" | cut -d':' -f2
        ;;
    'aof_rewrite_scheduled')
        cat $CACHE | grep "aof_rewrite_scheduled:" | cut -d':' -f2
        ;;
    'total_connections_received')
        cat $CACHE | grep "total_connections_received:" | cut -d':' -f2
        ;;            
    'total_commands_processed')
        cat $CACHE | grep "total_commands_processed:" | cut -d':' -f2
        ;;
    'instantaneous_ops_per_sec')
        cat $CACHE | grep "instantaneous_ops_per_sec:" | cut -d':' -f2
        ;;
    'rejected_connections')
        cat $CACHE | grep "rejected_connections:" | cut -d':' -f2
        ;;
    'expired_keys')
        cat $CACHE | grep "expired_keys:" | cut -d':' -f2
        ;;
    'evicted_keys')
        cat $CACHE | grep "evicted_keys:" | cut -d':' -f2
        ;;
    'keyspace_hits')
        cat $CACHE | grep "keyspace_hits:" | cut -d':' -f2
        ;;        
    'keyspace_misses')
        cat $CACHE | grep "keyspace_misses:" | cut -d':' -f2
        ;;
    'pubsub_channels')
        cat $CACHE | grep "pubsub_channels:" | cut -d':' -f2
        ;;        
    'pubsub_patterns')
        cat $CACHE | grep "pubsub_patterns:" | cut -d':' -f2
        ;;             
    'latest_fork_usec')
        cat $CACHE | grep "latest_fork_usec:" | cut -d':' -f2
        ;; 
    'role')
        cat $CACHE | grep "role:" | cut -d':' -f2
        ;;
    'connected_slaves')
        cat $CACHE | grep "connected_slaves:" | cut -d':' -f2
        ;;          
    'used_cpu_sys')
        cat $CACHE | grep "used_cpu_sys:" | cut -d':' -f2
        ;;  
    'used_cpu_user')
        cat $CACHE | grep "used_cpu_user:" | cut -d':' -f2
        ;;
    'used_cpu_sys_children')
        cat $CACHE | grep "used_cpu_sys_children:" | cut -d':' -f2
        ;;             
    'used_cpu_user_children')
        cat $CACHE | grep "used_cpu_user_children:" | cut -d':' -f2
        ;; 
    'key_space_db_keys')
        cat $CACHE | grep $DB:|cut -d':' -f2|awk -F, '{print $1}'|cut -d'=' -f2 
        ;;        
    'key_space_db_expires')
        cat $CACHE | grep $DB:|cut -d':' -f2|awk -F, '{print $2}'|cut -d'=' -f2 
        ;;
    'list_key_space_db')
        LIST_DATABSE=`cat $CACHE | grep '^db.:'|cut -d: -f1`
        databse_detect
        ;;                                                     
    *)   
        echo "Not selected metric"
        exit 0
        ;;
esac
