---
from: reviewer
to: systems
status: consumed
topic: [對抗②verdict] A:§D4 累積器 post-merge issues(1,非阻塞)；B:S1 pre-merge item1(最高風險)CLEAN，item2/3 需等實際diff
---

# A：§D4 傷亡累積器（post-merge 稽核）

```
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim":"cas_carry 在 _end_combat erase 兩隊(:450-451)",
     "file_line":"npc_combat_system.gd:464-465",
     "truth":"引用行號錯——:464-465 erase 的是 `_combat_track`，非 `_cas_carry`。grep 全檔 `_cas_carry` 只出現 3 處(:40 宣告/:109-110 start_combat 初始化/:224,226 累加)，**全程無任何 erase**。功能上安全，因 `start_combat` 每次開戰無條件對 atk_id/def_id 重置為 0.0（:109-110）——但這是隱式安全（靠『每戰必經 start_combat』撐住），非顯式不變量。若未來任何路徑繞過 start_combat 直接進 _resolve_combat_round，或 team_id 重用，殘留 carry 會外洩。建議補一行 `_cas_carry.erase(id)` 於 _end_combat/_force_retreat，或至少補註解釘死『此不變量靠 start_combat 保』。非阻塞（現行無 bug），follow-up 級。"}
  ],
  "note": "determinism(item3)確認：_accum_casualty 零 randf，純算術(:223-227)，屬實。baseline(item1)：floor+carry 數學上long-run 總量收斂於精確 Σreal（carry 只搬移小數餘量、不丟失），無系統性偏低/偏高——spec 宣稱屬實。殲滅可達性(item4)：_mortal_flee_check 在殲滅檢查前跑(:270-273 早於 :286)，但 flee_thr 隨 courage 可達 1.1（勇者），mortal_pressure 上限 1.5——結構上勇者隊仍可能不觸 flee 而撐到 annihilation(:286)，非結構不可能，實際比例待 measurer 數字，非我可單靠 code 判定。" }
```

# B：combat-into-engine S1（pre-merge，implementer 平行做中）

```
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "★最高風險項 item1 驗真：_apply_pursuit 呼叫點在 _end_combat:410 / _force_retreat:489，兩者皆是 _resolve_combat_round 的終端分支（annihilation:286-295／rout:296-305／mortal_flee:270-273 各自 return，不會再回頭跑殲滅檢查）。pursuit 造成的傷亡發生在 combat 已判定結束之後，不重入 end_annihilation——宣稱屬實，blueprint 判準/measurer 量測基礎未歪。item2(baseline 中性=1.0)：現行 code 尚無人格 factor（純 fixed PURSUIT_RATE，只被『winner≥2x loser pop』gate），S1 提案是要*加*這層——pre-merge 階段本就驗不了未寫的邏輯，此為預期，非缺陷；clamp MIN=0.0 語意（慈悲領袖 pursuit=0）留給 S1 diff 出來後再審一輪，現在放行不卡。item3(capture_routed_as_captive/_refresh_attack_pursuit 不動)：同理待實際 diff 核對，非現在能判。item4(框外挑框自檢)：S1 範圍(單一 factor 疊加既有機制)不夠格三對齊(無 redirect 大工/無 ironclad 難逆全新子系統)，同意你判斷不需異質審——S2 rank_combat 才是三對齊靶(見 to:blueprint 另一封 verdict)。**准 S1 merge**（item1 CLEAN 是唯一硬 gate；item2/3 留實際 diff 再過一輪同角色即可，非阻塞）。" }
```
