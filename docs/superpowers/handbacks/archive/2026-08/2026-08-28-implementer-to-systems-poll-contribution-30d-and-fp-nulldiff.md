---
from: implementer
to: systems
status: consumed
slice: poll-retire-precondition
tier: measure
topic: ★輪詢獨特貢獻率 30 日雙床完成 + 覆蓋 9×31 PASS(217/217);★★★而我預先聲明的「#3 fp 必變」【是錯的】——before/after 在 6000 與 20000 tick 完全相同，且「沒 fire」已被排除(seen=57/unseen=0) ⇒ 是【醒了但選一樣的東西】;★★GOAL 命中你的第四種結論(兜底)，STRATEGIC 像真冗餘，兩床答案相反
---

# ★★★①先講我錯的那件：**「fp 必變」是錯的**

我交件時**先聲明**：「多一條喚醒路徑 ⇒ 決策時序真的變了 ⇒ 世界分岔 ⇒ fp 必變」。

```
before = 455db60f^（rung_changed 落地【之前】），臨時 worktree 跑完即刪
after  = 本分支
   6000 tick ： 6eb9bec6a5a0f06a99eb3b02bcba34d2  ==  6eb9bec6a5a0f06a99eb3b02bcba34d2
  20000 tick ： 7c5687840c53a46f7b1dcff8df91d2d8  ==  7c5687840c53a46f7b1dcff8df91d2d8
```
★**完全相同。**

## ★★而「沒 fire」這個好聽的解釋【已經被排除】

```
rung_changed 在 2880 tick 的 smoke 就 emit 過 9 次
30 日 ⑦ 欄：rung_changed  seen=57 / unseen=0  ⇒ ★它【真的被看到】了
```
⇒ **是【醒了，但選一樣的東西】，不是【沒醒】。**

★★★**而它與 30 日的輪詢資料是同一件事**：
> **INTENT 的重評【從不改變選擇】——①改變 0 ／ ②維持 70 ／ 貢獻率 0.0%**

⇒ **提早叫醒它，它還是選一樣的 ⇒ 世界不分岔。**

## ★兩種讀法，我不替你選

```
甲：S3 開的反應性缺口【比想像小】—— 因為選擇函數本來就穩定
乙：選擇函數【太不敏感】—— rung 資格變了而意圖不動，那是另一個問題
★★同一組數字，指向完全不同的下一步。
```
★**而 #3 目前的定位要照實寫**：**喚醒路徑存在且被證明**（覆蓋 217/217、⑦ seen=57/unseen=0），
**但它在這張床上不改變任何決策** —— **「潛在正確性修補」不是「行為改變」。**

# ★②#3 三條驗收的最終狀態

| 條 | 結果 |
|---|---|
| ①新 kind 在覆蓋表裡 woken | **★PASS**：9×31 = 279/279，核心 **217/217**，NOT_WOKEN=0 / no_run=0 / no_actor=0 |
| ②rung 變動當 tick INTENT 醒 | **同 tick 44 ／ 之後才醒 3 ／ ★從此沒醒 0 ／ 獨立隊無勢力 89 ／ 樣本 136** |
| ③fp 必變 | **★不成立（見上）** —— 我先聲明過，所以我要明說它沒發生 |

★**②那 3 筆「之後才醒」我沒有併進「同 tick」** —— 它們是不同的事。

# ★★★③輪詢獨特貢獻率（30 日，兩床）

## warring_states（actor 母體：persons=159 factions=8 獨立隊=42 有領袖隊=105）
```
支別        分母  ①改變 ②維持 ③首次賦值 ④無選擇產出  貢獻率
GOAL         779     0    779      0        0        ★0.0%
LADDER       266    24    242      0        0         9.0%
STRATEGIC     67     0     67      0        0        ★0.0%
INTENT        78     0     70      8        0        ★0.0%
ALLIANCE/BETRAY/INFRA/FACTION_UPDATE/INDEP_INFRA ⇒ 量不到
★四欄殘差 ④ 全 0 ⇒ 你的四類在這張床上【窮盡】
```
★**INTENT 的 8 筆全在 ③（首次賦值）** —— 判準修訂之後它就歸位了，貢獻率 0.0%。

## peaceful_economy（actor 母體：persons=24 **factions=0** 獨立隊=12 有領袖隊=12）
```
GOAL   181 | 0 | 181 | 0 | 0 | 0.0%
LADDER  94 | 2 |  92 | 0 | 0 | 2.1%
STRATEGIC/ALLIANCE/BETRAY/INFRA/FACTION_UPDATE/INTENT ⇒ ★分母=0 ⇒ NO_ACTOR
INDEP_INFRA 107 ⇒ 量不到
```
★**分母=0 那六支是【NO_ACTOR】不是【NEVER_FIRED】** —— 這張床 factions=0（config 沒有 factions 鍵、全程也沒形成）。
★★**床自己分的，不是我口頭斷言**（`d81ad40f`：帶 actor 母體 + 二分）。

# ★★★★④延遲欄 —— 它把三支推向三種【不同】結論

```
支別        樣本   中位     平均      最大     ★之後再也沒醒
GOAL        632   2400    4408.9    28200        147
LADDER      200   3000    5040.6    24300         42
STRATEGIC    66    360     536.4     3900          1
INTENT       69    420     813.9    12840          1
（1440 tick = 1 日）
```

| 支別 | 落在你的哪一條 |
|---|---|
| **GOAL** | **★第四種**：貢獻率 0%，但中位 **1.7 日**、最大 **19.6 日**、**147 筆之後再也沒有事件喚醒** ⇒ **輪詢沒在改變決策，但它是兜底的時效保證** |
| **STRATEGIC** | **★比較像判準②（真冗餘）**：貢獻率 0%，延遲中位僅 **0.25 日**、只有 1 筆從此沒醒 |
| **LADDER** | **★判準③（分子 > 0 ⇒ 不退）**：9.0%，成因是真的 rung 升降（見下） |

★**「GOAL 147 筆之後再也沒醒」是這張表最硬的一格** —— 它直接反駁「砍掉輪詢只是慢一點」。

# ⑤③成因池（分子逐筆，母體 24 樣本 24，**未撞 cap**）
```
17 × LADDER｜0 → 1      4 × LADDER｜1 → 0
 1 × LADDER｜1 → 2      1 × LADDER｜2 → 0      1 × LADDER｜4 → 0
```
★**全部是 rung 升降** —— **而 rung 現在已經接了 T0（`rung_changed`）**。
⇒ ★★**這一欄目前【沒有】給出新的待補 kind 候選**：唯一的成因已經接上了。
★★★**而那正好解釋了 fp 零分岔**：輪詢在 LADDER 上做的事，事件現在也會做，而兩者選出來一樣。

# ⑦落空率（30 日）★★兩床答案相反，而你說過那本身是結果
```
                warring    peaceful
GOAL             24.1%      87.7%
LADDER           12.0%      87.5%
INDEP_INFRA      48.6%      87.6%
STRATEGIC/ALLIANCE 0.0%     n/a(NO_ACTOR)
BETRAY/INFRA/FACTION_UPDATE 5.3%   n/a
INTENT            7.3%      n/a
```
★**peaceful 幾乎全落空（~87.6%）而 warring 只有 12–48%** ——
★★**我不下因果結論**（peaceful 事件稀少、隊數 12，母體結構完全不同）。

# ⑥兩件我沒做
1. **不替你選修法**（(a)/(b)/(c)）—— 而 ⑦ 的 unseen / no_consumer 已分開，那格是你的。
2. **不替那五支「量不到」造代理指標**。★要它們進分母＝改 code 讓選擇落到可比較的地方，另一票。

# ⑦exact path（全部已 commit `2c5d55bf`）
```
docs/measurements/2026-08-28-poll-unique-value-warring_states.txt
docs/measurements/2026-08-28-poll-unique-value-peaceful_economy.txt
docs/measurements/2026-08-28-s4b-wake-coverage-warring_states.txt      （★PASS 217/217，判決句已修）
docs/measurements/2026-08-28-rung-wake-fp-nulldiff.txt                 （★fp 零分岔的證據與 repro）
scripts/debug/s5_poll_unique_value.gd ／ scripts/debug/s4b_wake_coverage.gd
```

# ⑧順帶三件工具面的錯（都已修，列出來免得別人重踩）
```
①/tmp 在 PowerShell 裡被解成 A:\tmp ⇒ Godot 有跑但輸出【全丟】（不是沒跑）
②until-loop 的退出碼被我結尾那行 grep 綁架 ⇒ 守衛報 failed 而它其實成功了
③trap EXIT 對 SIGKILL 不 fire ⇒ beacon 留在原地（已補 INT TERM，★但 SIGKILL 只能靠死線）
```
