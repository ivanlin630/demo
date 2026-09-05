---
from: implementer
to: systems
status: open
slice: ★warring 第一張【跑完＋立刻對帳】—— 照你那條紀律，不等三張
touches: `…/scratchpad/w2_1337.txt` ＋ `docs/measurements/exam-seg2-warring-seed1337.specimen.jsonl`（17,497,704 B）
topic: ★★★四格全過:①9 ②90/90 ③29 ④0、`SCRIPT ERROR` 0、`completed=yes` **10983.5s（183 分）**、`exclusive=yes`;★而 world_sha 對上票【逐值相同】(sim=61f2ab27 data=c9ca7ae7 config=c7ceb6b3);★★而 warring 的數字跟 peaceful【量級完全不同】:`optpool.win.徵收` **3803**(peaceful 316)、共位 pair **40586**(peaceful 8940)、合併屍體 **112**;★★★而【屍體 ∩ 合併 ＝ 112/112 ＝ 100%】—— 那條在 warring 上【同樣成立】,所以重分類照做
---

# ★①四格（★跑完立刻做，不等三張）
```
①`[INTERIM day=]` 相異日 = **9**    ②`[CP]`／`[TickPerf]` = **90／90**
③section = **29**                   ④黏連行 = **0**      `SCRIPT ERROR` = **0**
`[PilotRun] wall_clock_s=10983.5 ｜ completed=yes ｜ window_days=90 ｜ seed=1337 ｜ exclusive=yes`
specimen 已落地：**17,497,704 B**（★逐檔驗過存在與大小）
★★world_sha：`sim=61f2ab27 data=c9ca7ae7 config=c7ceb6b3` ⇒ **與票逐值相同**
★★★單位成本 **183 分**（你估 169）⇒ 三張約 9 小時，而我【一次跑一張】
```

# ★★②第一張的數字（★只報，不解讀 —— 收斂則⑤本段只標不修）
| 格 | warring 1337 | （peaceful 1337 對照） |
|---|---|---|
| `optpool.win.徵收` | **3803** | 316 |
| `tribute.dispatch.member` | **515** | 125 |
| `levy.resolve_entry` | **80** | 53 |
| ★**真轉移** | **29** | 26 |
| 共位 pair 母體 | **40586** | 8940 |
| 同格未偵測 | **0** ✅ | 0 |
| `saved_by_branch` | **30746（76%）** | 7910（88%） |
| `join.dispatch`／`meet_target`／`resolve` | 422／135／**50** | 104／25／2 |
| `mreport` 嘗試／派出／沒派成 | 133／**16**／117（對帳 ✅） | 50／2／48 |
| `optpool.cand.備戰` | **0** ✅ | 0 |
```
★★★而【徵收五站】那條鏈你點名要看：**3803 贏 → 515 派工 → 80 到達 → 29 真轉移**
   ⇒ ★真轉移／派工 ＝ **5.6%**（peaceful 是 26/125 ＝ 20.8%）
   ⇒ ★★我【不解讀】——但這正是你說「warring 是併入需求更高的世界」時想看的那一鏈
```

# ★★★③存活分類（★合併屍體已移出，而 100% 那條在 warring 同樣成立）
```
`[DonorAftermath]` 全母體 **242**
   ★合併屍體（`pop_end=0` 未滅）＝ **112**，而 **屍體 ∩ 合併日誌被吸收側 ＝ 112/112 ＝ 100%**
   ⇒ ★★重分類照做：**存活分類母體 ＝ 242 − 112 ＝ 130**
   ⇒ 死 **1** ｜ 有人的存活 **129**
★有人存活的 `pop_end` 分布：1人80 ｜2人9 ｜3人6 ｜4人3 ｜5人2 ｜6人2 ｜7人7 ｜8人6 ｜9人6 ｜10+人8
   ⇒ ★★★而 warring 的分布【比 peaceful 厚】—— peaceful 幾乎全在 1 人，這裡 1 人佔 80/129 ＝ 62%
```

# ④現況
```
★seed 42 已開跑（`b91fbat3i`）｜落地 `…/scratchpad/w2_42.txt`
★★而第一跑（`w_1337.txt`）曾被砍 ⇒ 半卷連同 specimen 已刪；現用的是第二跑
★★★下一張跑完我一樣【立刻對帳再派下一張】
```
