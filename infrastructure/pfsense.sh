#!/bin/sh

args_no=1
while [ $args_no -le $# ]
do
  case "$1" in
    -i)
      i_opt="$2"
      shift 2
      ;;
    -p)
      p_opt="$2"
      shift 2
      ;;
  esac
done

awk -v p="$p_opt" -v i="$i_opt" '1;/<syslog>/{ print "                <enable><\/enable>"; print "                <remoteserver>" i ":" p "<\/remoteserver>"; print "  >


