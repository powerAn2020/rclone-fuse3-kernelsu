#!/system/bin/sh

MODPATH=${MODPATH:-/data/adb/modules/rclone}

echo "Loading Environment Variables"
echo "  * 默认(Predefined): $MODPATH/env"
set -a && . "$MODPATH/env" && set +a
echo "  * 自定义(Customized): $RCLONE_CONFIG_DIR/env"
current_time=$(date +"%I:%M %P")
# 检查并停止正在运行的 RClone Web 进程
function check_stop_web_pid() {
  if [ -f "$RCLONEWEB_PID" ]; then
    PID=$(cat "$RCLONEWEB_PID")
    if ps -p "$PID" > /dev/null 2>&1; then
      echo "RClone Web GUI is already running with PID($PID). Stopping it..."
      pkill -P $PID
      rm -f "$RCLONEWEB_PID"
      echo "RClone Web GUI stopped successfully."
      echo "已成功关闭 RClone Web GUI"
      sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ $current_time | status:❌ ] /g" $MODDIR/module.prop
      return 1
    else
      echo "Found a stale PID file. Removing it..."
      rm -f "$RCLONEWEB_PID"
    fi
  fi
  return 0
}

function start_web() {
  # 构建 RClone Web GUI 的访问 URL
  if [[ "${RCLONE_RC_ADDR}" == :* ]]; then
    # LOCAL_IP=$(ip route get 1 | sed -n 's/^.*src \([0-9.]*\) .*$/\1/p')
    URL="http://${LOCAL_IP:-localhost}${RCLONE_RC_ADDR}"
    # 替换启动URL
  else
    URL="http://${RCLONE_RC_ADDR}"
  fi
  sed -i "s/\(document\.location = \)'[^']*'/\1'$URL'/g" ${RCLONEDIR}/webroot/index.html
  set -e
  echo "RClone Web GUI will start at: ${URL}"
  echo "Open the following URL in your browser to access the web GUI:"
  echo "浏览器访问: ${URL} 进行配置"
  nohup rclone-web > "$RCLONE_LOG_DIR/rclone-web.log" &
  pgrep -f "rclone-web" > "$RCLONEWEB_PID"
  # PID=$!
  # echo "$PID" > "$RCLONEWEB_PID"
  echo "RClone Web GUI started with PID($PID)."
  echo "网页已启动 $URL"
  sed -Ei "s/^description=(\[.*][[:space:]]*)?/description=[ $current_time | status:✅ ] /g" $MODDIR/module.prop
}

if check_stop_web_pid; then
  start_web
fi
