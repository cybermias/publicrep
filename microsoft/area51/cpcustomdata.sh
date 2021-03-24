#!/bin/bash

# all set to admin123 (replaced later)
SIC_KEY='admin123'
ADMIN_HASH='$6$0rVzHRkDOMwsB9cP$dm60oGLtEfgNGZK.WiiECa4FP3MPBbhob.oG.a33LyoEZvlbfL.5AFRzKmzRB4OQq0rgDF4JymvibXz3hNB2z/'
ADMIN_PW='admin123'

FTW_LOG=/var/log/ftw.log
BLINK_CONF=/home/admin/blink.conf
#cpprod_util FwSetStandAlone 1
NEWSYS_CONF=/home/admin/blink2.conf

# Gaia first time wizard
if [ -e "/bin/blink_config" ]; then
  echo "Prefered to use blink" >> /home/admin/trueblink
  echo "Configuring Image Using Blink_Config" | tee /dev/console >> $FTW_LOG
  blink_config -t $BLINK_CONF
#  sed -i 's:download_info=".*":download_info="true":g' $BLINK_CONF
#  sed -i 's:install_security_managment=".*":install_security_managment="true":g' $BLINK_CONF
#  sed -i 's:upload_info=".*":upload_info="false":g' $BLINK_CONF
#  sed -i "s:ftw_sic_key='':ftw_sic_key='$SIC_KEY':g" $BLINK_CONF
#  sed -i 's:upload_info=".*":upload_info="true":g' $BLINK_CONF
#  sed -i "s:admin_hash='':admin_hash='$ADMIN_HASH':g" $BLINK_CONF
#  #sed -i "s:admin_password_regular='':admin_password_regular='$ADMIN_PW':g" $BLINK_CONF
#  echo "install_security_managment=\"true\"" >> $BLINK_CONF
#  config_system -t $BLINK_CONF
  sed -i 's:install_security_gw=:install_security_gw="true":g' $BLINK_CONF
  # IMPORTANT: There is a typo in the template file so don't change the next line
  sed -i 's:install_security_managment=:install_security_managment="true":g' $BLINK_CONF
  sed -i 's:install_mgmt_primary=:install_mgmt_primary="true":g' $BLINK_CONF
  sed -i 's:download_info=".*":download_info="true":g' $BLINK_CONF
  sed -i 's:upload_info=".*":upload_info="true":g' $BLINK_CONF
  sed -i 's:mgmt_admin_radio=:mgmt_admin_radio="gaia_admin":g' $BLINK_CONF
  sed -i 's:mgmt_gui_clients_radio=:mgmt_gui_clients_radio="any":g' $BLINK_CONF
  sed -i "s:admin_hash='':admin_hash='$ADMIN_HASH':g" $BLINK_CONF
  sed -i 's:reboot_if_required=:reboot_if_required="false":g' $BLINK_CONF
  echo "##### BLINK CONF #####" >> $FTW_LOG
  cat $BLINK_CONF >> $FTW_LOG
  echo "##### END BLINK CONF #####" >> $FTW_LOG
  blink_config -f $BLINK_CONF --dry-run >> $FTW_LOG 2>&1
  blink_config -f $BLINK_CONF >> $FTW_LOG 2>&1
else
  echo "Prefered to use clish" >> /home/admin/trueclish
  echo "Configuring Image Using Config_System" | tee /dev/console >> $FTW_LOG
  config_system -s "install_security_gw=true&install_ppak=true&gateway_cluster_member=false&install_security_managment=true&ftw_sic_key=$SIC_KEY" >> $FTW_LOG 2>&1
  clish -c "lock database override"
  clish -c "set user admin password-hash $ADMIN_PW_HASH" -s
fi

# more clish customization below
#clish -c "lock database override"
#clish -c "set user admin shell /bin/bash" -s
