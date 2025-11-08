#!/system/bin/sh

MODPATH=${MODPATH:-0%/*}

set_permissions() {
  set_perm_recursive $MODPATH 0 0 0755 0644
  chmod +x $MODPATH/bin/*
  set_perm_recursive $MODPATH/bin/ 0 0 0755 0755
  chmod +x $MODPATH/sync.service.sh
}

set_permissions

RCLONEPROP="${MODPATH}/module.prop"
MODULE_CONFIG="/data/adb/modules/rclone/conf"

if [ -d "$MODULE_CONFIG" ] ; then
  ui_print "✅ 已检测到配置目录 ${MODULE_CONFIG}，已复制到模块目录"
  cp -r "$MODULE_CONFIG" "$MODPATH/"
  sed -i 's/^description=\(.\{1,4\}| \)\?/description=✅| /' "$RCLONEPROP"
else
  ui_print "⚙️ 未检测到配置文件，通过命令行或者web进行配置"
  ui_print " Web GUI: 点击 Action 访问对应端口"
  ui_print " su命令行(root): rclone-config 开始配置"
  sed -i 's/^description=\(.\{1,4\}| \)\?/description=⚙️| /' "$RCLONEPROP"
fi
