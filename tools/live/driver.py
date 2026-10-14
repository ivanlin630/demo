# 真玩 driver：背景起 tools/play.py（line mode），把 cmd.txt 新增的行餵進 stdin，畫面（每幀以 EOT 0x04 結尾）寫進 screen.log。
# 來源：藍圖 2026-10-14 真玩（信 2026-10-14-blueprint-to-systems-FEEDBACK-live-play-is-qa-or-measurer-job-plus-driver-scripts）。
# 用法：python tools/live/driver.py（背景跑）；再用 tools/live/step.py 送鍵看幀。
# ★LIVE 目錄＝指令檔 cmd.txt 與畫面 screen.log 所在處：環境變數 GDS_LIVE_DIR，未設＝系統暫存 gds-live（不寫進 repo）。
import subprocess, sys, time, os, io, tempfile
ROOT = r"A:\GDS\demo"
LIVE = os.environ.get("GDS_LIVE_DIR") or os.path.join(tempfile.gettempdir(), "gds-live")
os.makedirs(LIVE, exist_ok=True)
CMD = os.path.join(LIVE, "cmd.txt")
LOG = os.path.join(LIVE, "screen.log")
env = dict(os.environ, PYTHONIOENCODING="utf-8", PYTHONUNBUFFERED="1")
log = io.open(LOG, "ab")
p = subprocess.Popen([sys.executable, "tools/play.py"], cwd=ROOT, stdin=subprocess.PIPE,
                     stdout=log, stderr=subprocess.STDOUT, env=env)
pos = 0
while p.poll() is None:
    try:
        with io.open(CMD, "rb") as f:
            f.seek(pos); data = f.read(); pos += len(data)
    except FileNotFoundError:
        data = b""
    if data:
        p.stdin.write(data); p.stdin.flush()
    time.sleep(0.2)
log.write(("\n[driver] play.py exited rc=%s\n" % p.returncode).encode("utf-8")); log.close()
