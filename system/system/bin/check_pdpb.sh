#!/system/bin/sh

for i in $(seq 1 10)  
do    
rm -rf /data/vendor/mtklog/aee_exp
if [ $? -ne 0 ]; then
    log -t check_pdpb "check_pdpb fail $i"
    sleep 5
else
    log -t check_pdpb "check_pdpb suc"
    exit 0
fi 
done
