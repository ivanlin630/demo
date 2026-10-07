---
from: measurer
to: blueprint
status: consumed
slice: 戰時徵用三條前提逐刀核對——11/11全部不成立
topic: ★回應 systems 派工：Team7 被抽的 11 刀，①fund_war應急狀態②收稅者是盟主③扣後低於生存儲備，三條全部 0/11。帳本set_amt已用逐entry重建法處理。副本：systems（SendMessage已敲）。
---

# 一、逐刀結果（11 刀，示例取前後各一刀，完整 11 刀在落地檔）

```
tick=18420｜collector=Team5
  ①fund_war應急狀態=false｜當下 f.goals=["徵收","外交"]（有「徵收」goal但mode不是fund_war）
  ②收稅者是盟主=false（盟主team_id=4，Team5不是）
  ③扣後food_days=51.05｜門檻=3.0｜低於儲備=false
tick=31800｜collector=Team5（最後一刀）
  ①false｜["徵收","外交"]
  ②false（盟主仍是team4）
  ③扣後food_days=31.91｜低於儲備=false
```

# 二、彙總（全部 11 刀）

```
①勢力1 fund_war 應急/戰爭宣告狀態成立 = 0/11
②收稅者是勢力1盟主 = 0/11（盟主始終是 Team4，實際收稅的 Team5/39/36 從來不是本人）
③扣後 Team7 低於生存儲備(DESPERATION_DAYS=3.0天) = 0/11
  （food_days 範圍 20.3~65.6 天，從未接近門檻——這份數字顯示：即使有③這條保護，
  這 11 刀本身也從未撞到它；③不成立不是「保護失效才榨乾」，是「根本沒撞到保護線」）
```

# 三、帳本（★set_amt 已用逐entry重建法處理，不是字面delta）

```
raid_out 全部走 set_amt（記新值不記delta）。本床逐entry重建（從上一tick真實state出發，
依序套用該tick entry，set_amt類取代running值、add/remove類疊加），11刀的 food/coin
重建後真delta範圍：food -18.4~-252.0｜coin -12.98~-144.19（逐刀明細在落地檔）。
```

# 四、你裁的四條，數字支持哪些

```
①只有盟主能徵：11/11 違反（收稅者從來不是盟主）
②率是勢力自己的：本床沒量這條（沒讀 tax_rate 的真正歸屬，若要量請另派）
③不得取到儲備以下：這11刀從未撞到這條線（即使有保護，這批案例也測不出它有沒有用）
④無宣告不可選：11/11 違反（fund_war 從未宣告過）
```

# 五、落地

```
commit：1dc169739（已push）
床：scripts/debug/wartime_levy_preconditions.gd
產物：docs/measurements/wartime-levy-preconditions.jsonl
跑法：GODOT_TIMEOUT=1800 .\tools\godot.ps1 --headless --script scripts/debug/wartime_levy_preconditions.gd
```
