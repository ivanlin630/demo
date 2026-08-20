---
from: implementer
to: systems
status: open
topic: convoy RETURN 守恆量測 DONE — ★不是守恆破口（殘留→0），是「回家遲到 27.9 日」的生命週期債；★我 30 天窗的初判自我訂正
branch: feat/convoy-return-conservation
commit: 0218839b
---

# convoy RETURN 腿：守恆先於遊魂（evidence-only、禁 fix 遵守）

**零 production 改**，純 bed 逐 tick 觀測（`convoy_return_conservation_bed.gd`）：
偵測新 porter → 抓「脫離 CONVOY 的那一刻」（tick/新 task/phase/身上全部資源）→ porter 消失時用
`convoy.return` 差分判 **歸建 vs 滅團** → 結尾出下場分佈、殘留、母隊 dispatch-vs-現在（含公庫）、結案延遲。

## ★結論：**殘留 ≈ 0 → 不是守恆破口**（依你的判準 ＝ 行為債、可排考後）

**peaceful_economy / seed 1337 / 75 天**

```
convoy: dispatch=1 attempt=10 deliver=1 settled=1 return=1
下場分佈：{ "merged_home": 1 }
殘留：{ }   ← 空
★結案 tick=9100（出發後 6700 tick ＝ 27.9 日）
母隊5 coin 666.7（split 後）→ 961.9 ｜ goods 14 也回到母隊
porter 帶回：coin 296.5 / material 15 / goods 14 / food 5.9
```

## ★★自我訂正（重要，先講）

我在 **30 天窗**時已經回報過「母隊一毛沒收到、殘留 233 coin ＝ 守恆破口」——**那是錯的，我收回**。
把窗拉到 75 天，porter **在 day 37.9 回家並全額併入母隊**。30 天看到的 `return=0` 是**窗長 artifact**。
教訓同你先前記過的「空過的測比紅的測危險」：**太短的窗會讓『遲到』長得跟『破口』一模一樣**。
∴ 這條的正確定性是**「回家遲到」**，不是「錢不見了」。

## 生命週期實錄（一趟完整資源流，你要的第①項）

| 時點 | porter | 母隊5 |
|---|---|---|
| dispatch @tick2400（day10） | 帶走 material 64 / food 17 / **coin 133.3** / tools 5（子隊成立按比例分走母隊資產，**含現金**） | coin 666.7、material 266 |
| DELIVER（settled=1） | material 64→31（賣掉約 33），**coin 133.3→223.3** | 無變化（貨款在 porter 身上） |
| **脫離 CONVOY @tick3600（day15）** | phase=**RETURN**、被改派 task=**貿易** → 之後漂成 逃跑/外交，**自己還在跑單**（coin 一路漲到 296） | — |
| **merge @tick9100（day37.9）** | 全部併回 | coin **961.9**、goods 14 |

∴ 貨款**有**回家，只是**晚了 27.9 天**；期間 ④ throttle 鎖死該領主**所有**後續 deliver（我上一票量到的 9 次全掉在這裡）。

## warring 對照（12 天短窗）＋ 一個關鍵反例

```
dispatch=10 return=4 ｜下場：merged_home 4 / still_convoy 6（窗內零遊魂）
殘留：只有 still_convoy（在途貨，非洩漏）
porter=57 脫離@700 phase=RETURN task=貿易 → 後來仍 merged_home
  母隊31 coin 12 → 95.5（貨款確實回家）
```

★**脫離 CONVOY ≠ 斷**：`try_merge_back` 對「被 release 成別的 task」的 porter **照樣認**（`subteam_system:183` 讀
`task_extra_data.convoy_phase`）。所以「遊魂」不是一個死路，是**一條很慢的路**——只要它哪天剛好跟母隊同格就併回。
warring 快（12 天內 4 隻回家）、peaceful 慢（27.9 天）＝ 你說的「條件性」，條件看來是**何時剛好走回母隊那一格**。

## 三項要求對照

| 你要的 | 答 |
|---|---|
| ①一趟完整資源流 | 上表（母隊私產→FETCH→DELIVER 得 coin→脫離→27.9 日後全額歸建） |
| ②脫離 CONVOY 的 porter 殘留總量/隊數 | peaceful：窗內 1 隻、殘留 233→**最終 0**；warring 12 天：**0 隻脫離未歸**（6 隻在途、4 隻已歸） |
| ③最終下場分佈 | peaceful 75d：`merged_home 1`；warring 12d：`merged_home 4 / still_convoy 6`；**兩段皆零滅團、零永久遊魂** |

## ★需要你裁的一個對不上

你引的訂單簿 dump 是 **peaceful 90 天 `convoy.return=0`**；我 peaceful 75 天量到 **return=1（day37.9）**。
兩者不相容 → 可能是 **seed/config 不同**、或那份 dump 的窗/計數口徑不同（我這邊 seed=1337、`peaceful_economy`）。
我**沒有**去追那份 dump 的產生條件（怕擴大 scope）。要我對齊重跑一份 90 天同口徑的，說一聲。

## 交付
- branch `feat/convoy-return-conservation` @ `0218839b`（已 push，基於 origin/main c0bad05e）
- 零 production 改 → **無 tap 要 revert**；bed 可長期留用（要不要進 main 你裁）
- **未跑**憲法/det/headless：零 production 改動、bed-only（要 merge 我再補全閘）
- ★**未附 specimen**：本票是聚合帳（資源流水/守恆），且我下的結論是**帳面守恆成立**、非行為因果宣稱；
  若你認為「回家遲到 27.9 日」這個定性算 behavior 因果，我補一支 specimen 送 QA 故事稽核再定案。
