#!/bin/bash


# TESTED WITH BLINK - Apperantly CPMGMT rpm isn't available under /sysimg/CPwrapper/linux this it doesn't get installed.
# Even azure GUI deployment, once "BYOL" is specified, places isblink=false and does it the old fashioned way (config_system)

# all set to admin123 (replaced later)
SIC_KEY='!2#4%6'
ADMIN_HASH='$6$0rVzHRkDOMwsB9cP$dm60oGLtEfgNGZK.WiiECa4FP3MPBbhob.oG.a33LyoEZvlbfL.5AFRzKmzRB4OQq0rgDF4JymvibXz3hNB2z/'
ADMIN_PW='cmtsAdmin12#'

FTW_LOG=/var/log/ftw.log
NEWSYS_CONF=/home/admin/blink.conf

# Gaia first time wizard
  echo "Configuring Image Using Config_System" | tee /dev/console >> $FTW_LOG
  config_system -t $NEWSYS_CONF
  sed -i 's:install_security_gw=:install_security_gw="true":g' $NEWSYS_CONF
  # IMPORTANT: There is a typo in the template file so don't change the next line
  sed -i 's:install_security_managment=:install_security_managment="true":g' $NEWSYS_CONF
  sed -i 's:install_mgmt_primary=:install_mgmt_primary="true":g' $NEWSYS_CONF
  sed -i 's:download_info=".*":download_info="true":g' $NEWSYS_CONF
  sed -i 's:upload_info=".*":upload_info="true":g' $NEWSYS_CONF
  sed -i 's:mgmt_admin_radio=:mgmt_admin_radio="gaia_admin":g' $NEWSYS_CONF
  sed -i 's:mgmt_admin_user=:mgmt_admin_radio="admin":g' $NEWSYS_CONF
  sed -i 's:mgmt_admin_passwd=:mgmt_admin_radio="admin123":g' $NEWSYS_CONF
  sed -i 's:mgmt_gui_clients_radio=:mgmt_gui_clients_radio="any":g' $NEWSYS_CONF
  sed -i "s:admin_hash='':admin_hash='$ADMIN_HASH':g" $NEWSYS_CONF
  sed -i 's:reboot_if_required=:reboot_if_required="false":g' $NEWSYS_CONF
  echo "##### NEWSYS CONF #####" >> $FTW_LOG
  cat $NEWSYS_CONF >> $FTW_LOG
  echo "##### END NEWSYS CONF #####" >> $FTW_LOG
  config_system -f $NEWSYS_CONF --dry-run >> $FTW_LOG 2>&1
  config_system -f $NEWSYS_CONF >> $FTW_LOG 2>&1


# more clish customization below
#clish -c "lock database override"
#clish -c "set user admin shell /bin/bash" -s
