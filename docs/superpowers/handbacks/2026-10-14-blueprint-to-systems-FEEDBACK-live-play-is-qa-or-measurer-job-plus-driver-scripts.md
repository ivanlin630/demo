---
from: blueprint
to: systems
status: consumed
slice: 用戶裁 2026-10-14「下次讓量測或 QA 玩」＋藍圖真玩用的兩支小腳本交接（請入 memory／流程，腳本歸 tools 由你定）
topic: 真玩輪（邊看畫面邊按鍵）改由 QA 或量測員執行，藍圖只讀表；附 driver／step 兩支腳本原文與用法
---

# 用戶裁
藍圖今天自己玩了一局後，用戶：「下次讓量測或 QA 玩」。⇒ 規則：**真玩（非腳本、邊看畫面邊決定）由 QA 或量測員執行**，產物＝一張「看到的／判斷／歸哪」表＋原始畫面檔（同 `docs/playtest/2026-10-14-round5-blueprint-live-play.md` 形狀）；藍圖讀表裁 WHAT，不再自己玩。QA 讀故事與因果、量測員讀數字，誰玩由你派。請入 memory（單寫者）與 00_roles／04_qa 一行。

# 怎麼玩（今天用的法子，零改 code）
背景起 `python tools/play.py`（line mode），一支 driver 把「指令檔」新行餵進它的 stdin、畫面寫進 log；另一支 step 追加按鍵後印最新一幀（地圖可略）。每步讀幀再決定下一鍵。缺點：幀切割靠頂列時間戳，同一分鐘多幀會黏在一起（今天讓我誤判事件重複一次）；若要正式化，play.py 在 line mode 每幀尾印一個分隔符最乾淨（HOW 你定）。

## driver.py（放哪由你定；今天在 scratchpad live/）
```python
import subprocess, sys, time, os, io
ROOT = r"A:\GDS\demo"
LIVE = os.path.dirname(os.path.abspath(__file__))
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
```
## step.py（用法：`python step.py t tab 1 6`；環境變數 STEP_WAIT 秒、STEP_FULL=1 含地圖）
```python
import sys, io, time, os
LIVE=os.path.dirname(os.path.abspath(__file__)); CMD=os.path.join(LIVE,"cmd.txt"); LOG=os.path.join(LIVE,"screen.log")
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
```
# 本次真玩的覆蓋（給下一位當起點）
走得通：紮營／紮根／走路／互動選單／打聽／交換數量輸入／戰鬥六向＋R＋Space／找上門 A/B／收編／勢力面板／派子隊三步。
沒玩到：休息（隊伍從沒累）、子隊到場執行到完工、被 NPC 主動攻擊、市集買賣、勒索、同盟提議、第 3 天之後。
