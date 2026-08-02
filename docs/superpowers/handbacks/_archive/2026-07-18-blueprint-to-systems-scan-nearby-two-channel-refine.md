---
from: blueprint
to: systems
status: consumed
topic: "[掃近隊 refinement·用戶戳出漏洞] 遠方高危險不得隱形。分兩 channel:①掃近隊=直接感知(bound perf) ②belief/情報網=遠方危險傳到你(獨立於直接掃)。硬約束+sharpen 你的 R①。你的 position-landmine 只蓋近隊脫視野;此蓋遠隊從沒掃過怎麼進 awareness。"
---

# 掃近隊 refinement：兩 channel + 遠方危險必傳（用戶戳出漏洞）

## 背景
你 lod-drop-documented 已落檔 + 加 nearby-scan landmine（近隊脫視野→belief last-seen 非 live pos）＝**近隊 position** 對齊感知鐵律，✓。**但用戶戳出更前的漏洞，你的 landmine 沒蓋**：遠方一支強敵朝你推進，在進掃描半徑前**完全隱形**＝盲區（既不真實、戰略上崩=沒時間備戰）。你的 landmine 管「近隊脫視野用 last-seen」；此 refinement 管「**遠隊從沒被直接掃過，怎麼進你的 awareness**」。

## WHAT refinement（blueprint 鎖）——分兩 channel，別混

**① 掃近隊 = 直接感知（空間、即時、精確）**
你當下物理看得到的鄰隊。O(N²) 成本所在 → **bound 這個省 perf**。即時戰術畫面。

**② belief / 情報網 = 你知道的（近+遠、延遲、不確定、decay）**
遠方危險**經情報網傳到你**（斥候 / 逃難者〔從強敵那逃出〕/ 商旅帶「大軍壓境」）→ 落進 belief store → 你對 **belief** 反應（備戰/結盟/逃）。非 god-view＝有霧降級延遲情報，比現行瞬間精確 god-view **更真實**。

**「近vs遠」非懸崖**＝belief `uncertainty`（隨距離/時效 decay）的 confidence 梯度。反應 scale：模糊遠聞→派斥候/開始武裝；確認近敵→全面動員。

## ★硬約束（整方法成敗前提）
**掃近隊絕不能讓遠方高危險隊消失。** 設計硬要求：**危險必須經情報網傳到你，獨立於直接掃**。
- 若 belief **只從直接掃填** → bound 掃＝盲區＝方法破 → 得**先建「危險會傳播」**才能 bound 掃。
- 若情報網**真的帶**「遠方強敵擴張」awareness 且**夠早** → 掃近隊安全。

## Sharpen 你的 R①（原「scan-nearby 可行性」加一問，這是 make-or-break）
你原 R① 三問（LOD 現態 / O(N²) 確切點 / scan-nearby 可行）**加第四且最關鍵**：
- **④ 情報網現在到底有沒有帶「遠方威脅擴張」awareness，且早於強敵進掃描半徑？** 具體：belief/message/inquiry 骨架在（我 session 都看到），但 populate 路徑是「只近距離直接掃填」還是「斥候/難民/商旅真的把遠方 threat 傳過來」？
  - **這決定序**：若情報網已帶遠方威脅 → 掃近隊直接做（bound scan + 決策讀 belief）。**若沒帶 → 「危險傳播」是掃近隊的前置 slice，先建再 bound**（否則放大規模=放大盲區）。
- 別憑舊 memory 假設情報網夠力；grep 坐實 belief populate 路徑（本 arc 教訓）。

## 序不變
落檔=你已做✅；此 refinement 併入同一「掃近隊」thread（Tier2、經濟後）；spec 前 R① 含上④。position-landmine（近隊 last-seen）留用，此為其前補（遠隊入 awareness）。

## 溯源
本 session 對話（用戶：「近隊怎麼掃怎麼定義 遠隊高危險就不管嗎」）；game-design per-tick 有界底線「兩 channel」段（本 session 加）；你 lod-drop-documented + nearby-scan landmine；[[project_time_scale_wave]]。
