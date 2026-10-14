# 真玩 step：追加按鍵到 cmd.txt，等新幀，印最新一幀（預設略地圖）。
# 用法：python tools/live/step.py t tab 1 6｜環境變數 STEP_WAIT 秒、STEP_FULL=1 含地圖。
# ★LIVE 目錄＝指令檔 cmd.txt 與畫面 screen.log 所在處：環境變數 GDS_LIVE_DIR，未設＝系統暫存 gds-live（不寫進 repo）。
import sys, io, time, os
import tempfile; LIVE=os.environ.get("GDS_LIVE_DIR") or os.path.join(tempfile.gettempdir(),"gds-live"); CMD=os.path.join(LIVE,"cmd.txt"); LOG=os.path.join(LIVE,"screen.log")
keys=sys.argv[1:]; wait=float(os.environ.get("STEP_WAIT","2.5")); full=os.environ.get("STEP_FULL")=="1"
def frames():
    t=io.open(LOG,encoding='utf-8',errors='replace').read()
    return [f for f in t.split('\x04') if f.strip()]
n0=len(frames())
with io.open(CMD,"ab") as f:
    for k in keys: f.write((k+"\n").encode("utf-8"))
deadline=time.time()+max(wait, 1.2*len(keys)+1.5)
while time.time()<deadline:
    if len(frames())>=n0+len(keys): break
    time.sleep(0.3)
time.sleep(0.4)
t=io.open(LOG,encoding='utf-8',errors='replace').read(); i=t.rfind('> 第'); last=t[i+2:] if i>=0 else t[-4000:]; fr=frames()
lines=last.splitlines()
if not full:
    out=[]; skip=False
    for L in lines:
        if L.startswith("┌─ 地圖"): skip=True; out.append("[地圖略]"); continue
        if skip and L.startswith("└"): skip=False; continue
        if skip: continue
        out.append(L.rstrip())
    lines=out
print("frames %d→%d"%(n0,len(fr)))
print("\n".join(lines)[-4500:])
