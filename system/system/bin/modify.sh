change=$1
vgc_dir=$(getprop ro.vgc.config.rootdir)
if [ ! -f  ${vgc_dir}$change ];then
   echo "$change is not exist!"
   exit 0
fi
for line in `cat ${vgc_dir}$change`
do
    cmd=${line%%:*}
    tmp=${line:3}
    name=${tmp#*:}
    prop=${tmp%%:*}
    echo $line
    echo "$cmd,$prop,$name"
    if [ -z "$prop" -o -z "$name" -o -z "$cmd" -o "$name" = "$prop" ];then
       echo "continue"
       continue
    fi
    if [ `echo -e -n "${name:0-1}"` = `echo -e -n "\r"` ];then
       len=`echo $name|wc -c `
       name="${name:0:$((len - 2))}"
       echo "=="
    else 
       echo "!="
    fi
    if [ "$cmd" = "rm" ];then
           echo "rm"
           if [ "${prop:0:5}" = "/data" ];then
               filelist=$(find $prop -name $name)
               for file in $filelist
               do
                   mv -v "$file" "${file}_bak"
               done
           elif [ ! -z "$(getprop $prop)" ];then
               filelist=$(find $(getprop $prop) -name $name)
               for file in $filelist
               do
                   mv -v "$file" "${file}_bak"
               done
           fi
    fi
    if [ "$cmd" = "--" ];then

           if [ "${prop:0:1}" = "/" ];then

              filepath=$prop
              filename=${filepath##*/}
              filedir=${filepath%/*}
              filelist=$(find $filedir -name $filename)
              for file in $filelist
              do
                  sed -i "/$name/d" $file
              done
           elif [ ! -z "$(getprop $prop)" ];then
              filepath=$(getprop $prop)
              filename=${filepath##*/}
              filedir=${filepath%/*}
              filelist=$(find $filedir -name $filename)
              for file in $filelist
              do
                 sed -i "/$name/d" $file
              done
           fi
    fi
done
