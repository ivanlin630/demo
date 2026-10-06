---
from: measurer
to: blueprint
status: open
slice: Team7 coin/food 對帳（兩錨點）＋11筆「空轉」徵收重新核
topic: ★回應 systems 派工（tax-reconcile-and-strength-ratio）：對帳用逐entry重建法處理掉set_amt缺陷，不用等R²merge。結論：(a) QA歸因錯，真因是raid_out不是tribute_out。★★★附帶：我自己上一輪T分析漏掃了raid_out/raid_in這條管道，11筆「空轉」事件全部其實有真轉移，零真空轉——自我更正。副本：systems（SendMessage已敲）。
---

# 一、先處理 set_amt 缺陷（不等 R² merge）

```
方法：逐 tick、逐 entry 重建——從上一 tick 真實 state 出發，依序套用這一 tick 的帳本 entry：
  add/remove 來源 reason → entry 的 delta 就是真delta
  set_amt 來源 reason（窮舉全庫 24 種：loot_mounts_out/loot_horses_out/equip_named/
    unequip_named/weapon_recover_anon/auto_withdraw_mounts/npc_withdraw_vault/
    npc_deposit_vault/init_starting/init_preset/readiness_food/raid_out/aid_out/
    deposit_storage/recruit_anon_pay/recruit_named_pay/player_take/overflow_split/
    eat_team/eat_depleted/provision_carry/spend_holding_team/subteam_split_in/
    merge_absorb_out）→ entry 記的是新絕對值，重建時直接取代running值
套到最後，拿重建出的最終值跟當tick真實state比對。

★★★全程 30 天、43199 個可比對 tick，重建值跟真實 state 100% 吻合（不吻合=0）
⇒ 沒有不經 ResourceBank 的寫入（排除 (c)），帳本本身（校正 set_amt 後）是完整的。
```

# 二、兩個錨點：(a) QA 歸因錯，真因是 raid_out

```
tick=25260：coin −67.65（state）＝ −67.65（重建）✓｜entry: reason=raid_out（set_amt，已重建校正）
tick=25320：coin −52.43（state）＝ −52.43（重建）✓｜entry: reason=raid_out（set_amt，已重建校正）
food 同一 tick 同一 reason，同樣吻合。

四格判讀：★(a) 有條目、reason 不是 tribute_out ⇒ QA 歸因錯——
QA 把這兩筆算進「tribute_out/tribute_in」的配對統計，但帳本真正的 reason 是 raid_out
（interaction_system.gd:698，PRODUCE/居民那條稅，不是 faction tribute 那條）。
```

# 三、★★★自我更正：11 筆「空轉」徵收重新核，全部有真轉移

```
上一輪我交的 T 分析（team7_ledger_reasons_and_tax_interval.gd）只掃了 reason="tribute_out"/
"tribute_in"，结论「Team5×9/Team39×1/Team36×1 共11筆徵收訊息，ledger配對法找不到對應
轉移=空轉」——★★★這個結論錯了，漏掃了 raid_out/raid_in 這條管道。

本次用同一套逐tick對帳法重查全部11筆事件的tick，結果：
  11 筆全部查到 reason=raid_out 的真實條目（coin+food各一筆，皆已逐entry重建校正）
  0 筆是真空轉

⇒ 正確結論：Team7 全程 16 筆徵收訊息，全部有真實資源轉移，沒有一筆是空的。
  差別只是走哪條管道：早期5筆（Team4，tick<14000）走 tribute_out/in（faction成員稅）；
  晚期11筆（Team5/39/36，tick>18000）走 raid_out/in（PRODUCE/居民稅）。
★★待查但本床沒追：Team7 從「faction成員」變成「被當居民徵稽」是什麼時候、怎麼發生的——
  這本身可能是故事的一部分（它什麼時候掉出faction保護變成被當居民徵稽？）。
```

# 四、11 筆的兵力比（既然不是空轉，這個假設前提不成立，但數字照給）

```
tick=18420/20160/20220/25260/25320（collector=5）：Team7戰力1.52｜Team5戰力1.56｜ratio=0.97
tick=26640（collector=39）：Team7戰力0.56｜Team39戰力0.50｜ratio=1.13
tick=27360（collector=36）：Team7戰力0.56｜Team36戰力0.80｜ratio=0.71
tick=27660/31200/31680/31800（collector=5）：Team7戰力0.56｜Team5戰力1.56｜ratio=0.36

全部 < 3（甚至大多 < 1.2），「≥3⇒效率0」這個假設沒有一筆踩到門檻——
但既然這11筆根本不是空轉，str_ratio 不是解釋「為何沒轉移」的答案，這個問題本身不成立了。
```

# 五、落地

```
commit：b58746191（已push）
床：scripts/debug/team7_tax_reconcile_strength_ratio.gd
產物：docs/measurements/team7-tax-reconcile-strength-ratio.jsonl
跑法：GODOT_TIMEOUT=1800 .\tools\godot.ps1 --headless --script scripts/debug/team7_tax_reconcile_strength_ratio.gd
```
