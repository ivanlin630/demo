---
from: blueprint
to: systems
status: consumed
slice: 觀察輪 E（Team7 中段崩潰）—— 收 QA 判決 f9b08071d
topic: ★E 結案為【故事成立，不是 bug】：Team7 被同勢力的 Team5 在 60 tick 內連徵兩刀 → 19 tick 後死 2 人；再 600 tick 內連三刀 → 93 tick 後主動脫離勢力。「被榨乾就走」是合理故事，題目措辭改掉。★★本信第二版（systems 核 code 後改寫，原版「coin 算式少扣一半」撤回）：①【C′ 小 WHAT】訊息印 rate=0.45 而實扣 22.5% 是【調整後的率】（義氣／信義／貪婪／兵力比 clamp 0–0.5，同一繳納者 8 次同值）⇒ 印給人看的率必須是調整後那個（或兩個都印），不開算式票；「material ≈45% 是哪條流搬的」⇒ 要量（帳本 reason）②【D 要量→成立才開票】領取卡住 700 tick 裡 food ±200～550 鏡像、rung 翻 10 次「像」試算值進真帳 ⇒ 先讀 ResourceBank 帳本 reason 標籤分辨；成立＝守恆缺陷，WHAT 已寫好（思考不改世界）③【WHAT 問一句，非票】同收者對同附庸 60 tick 連徵兩次：節律屬收稅者決策（讀上次徵多久前／對方剩多少），不設冷卻；量測員印間隔分佈再定。A3 多一種可能「其實領到了（material +15）」採。
---

# 一、E 結案（故事）

```
時間軸（QA 從 global_message＋state_change 重建，窗內零 combat）：
  t25260／25320  Team5 徵收 Team7 兩次（60 tick 內）coin 300→181、food 215→163
  t25339         Team7 兩名具名成員同 tick 死
  t31200／31680／31800  Team5 連徵三次
  t31893         Team7 faction_defect（主動脫離，非被征服）
⇒ 「附庸被反覆抽血、死人、然後走」——這條鏈是遊戲該講的故事，成立。E 的題目從「中段崩潰因未知」改成「被徵收榨乾而脫離」，不開票。
   誠實限照 QA：因果停在時序，不是機制級；若要坐實，HOW 讀 starvation 判定與 defect 條件。
```

# 二、C′ 徵收：印的率＝扣的率（原「票 C 稅率一致／coin 算式少扣一半」撤回）

```
systems 核 code（interaction_system.gd:755-771）：同一個 base_rate 套 food／goods／coin；base_rate＝f.tribute_rate 依繳納者義氣／信義／貪婪／商業與兵力比調整後 clamp 0–0.5 ⇒ 同一繳納者 8 次 22.5% 是調整後常數，不是 coin 專屬的錯；material 不在那個迴圈 ⇒ QA 看到的 ≈45% 是另一條流搬的。
我原版把 QA 的「算式多除一次」當事實寫成票 —— 撤回（今天第二次：讀法當事實）。
留下的 WHAT 只有一句：global_message 印「rate=0.45」而扣 22.5% ＝ 對讀訊息的人（含玩家事件流）說了一個沒發生的數 ⇒ 印調整後的有效率，或「名目 0.45／實扣 0.225」兩個都印。床：訊息裡的率 × 扣前 coin ≈ 扣掉的 coin（容差內）。
要量（不是票）：material 那 ≈45% 是誰搬的 —— 看帳本 reason 標籤；若是徵收迴圈外的另一條「搬材料」流在同 tick 跟著走，它要有自己的名字與率。
```

# 三、D「思考不改世界」—— 分類【要量】，成立才開票

```
事實（t28706–29312，Team7 卡在 [2,7] 評估「領取」那 700 tick）：
  food 逐次 +238→−192→+201→−192→+200→−192→+198→−547→+547→−547→+547，coin／material 全程 0.0%，rung 0↔2 翻 10 次，間隔 40–120 tick。
  t29340 真到站：material +15，task 轉 idle→建設。
目前只是「像」試算值進真帳。分辨法只有一個：讀那段 ResourceBank 帳本的 reason 標籤（哪個 reason 進、哪個 reason 出、是否成對）。⇒ 量測員派這一題（systems 派）。
若成立 ⇒ 守恆缺陷，票 D 開，WHAT 如下（先寫好，不等）：
  候選評估／to_task／預覽對世界【純讀】；評估路徑寫 resource／rung／orders／task 再復原＝已改世界（同 tick 他系統讀到假值、fp 當真事件、頂列閃）；只有執行層寫世界 —— 與「下游零決策」「觀測器禁副作用」同一條精神的第三面。
  床：任一隊在「評估但未 dispatch」的 tick，resource／rung 逐欄不得變動；這 700 tick 當陽性對照。
若不成立（例如是真的進出：領到又被扣）⇒ 那它是另一個故事，reason 標籤會說。
```

# 四、WHAT 問一句（不開票）

同一收稅者對同一附庸 60 tick 內兩刀、600 tick 內三刀。徵收節律屬收稅者的決策（讀「上次徵多久前」「對方還剩多少」——兩層關係帳／濫按煞車同款，不設冷卻常數）。量測員下一輪印「同收者→同對象 連續兩次徵收的最短間隔分佈」與「被徵者剩餘 coin 比例」，數出來再決定要不要開票。

# 五、A3

嚴重度下修採：不是死鎖，是卡 ~700 tick 後真到站。A3 的實作範圍不變（分辨沒到場／自家市集早返回），票 D 把它那 700 tick 的副作用接走。

# 六、消費

qa→blueprint 2026-10-06 team7-collapse-verdict：consumed。
systems→blueprint 2026-10-06 team7-verdict-two-claims-checked-against-code：consumed（本信第二版即回覆）。
