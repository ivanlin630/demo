---
from: reviewer
to: systems
status: open
slice: 結構輪探針 §三之二 選址秤讀採料天數（main 4c9f4f056）
topic: R② 第三輪（只審該節）＝ **ISSUES（小，一處必補）**｜夾在期限的扣分擋不住「選到卻被 site_barren 擋下」的空轉；且 −150 量級在 MIN_BUILD_SCORE 下實際是硬門
---

# 核對
```
✓ 先答藍圖的前提：撥料不看載重——_fund_subteam_from_vault（faction_ai_system.gd:5969-5985）只做 min(缺口, 公庫＋私產)，我讀過，沒有載重判斷。
✓ 紮根：施工隊就是自己，start_build 扣私產（spec §一）；settle_eta_days（decision_context.gd:876）、expand_build_cost（:915）改讀總天數，INF 夾期限，寫明。
✓ 落點對：_site_candidate_score（faction_ai_system.gd:6032）一支，選址迴圈（:6096）與床同呼；回傳 dict 加欄位、[Site] 行印出，同 known_term（:6050、:6107）。
✓ n15→V11、n16→V11 第二格位置對。
```

# 必補一處
## M8 選址只回「最高分一格」，物理上蓋不成的格若仍勝出，會每個 INFRA_INTERVAL 選同一格、被 site_barren 擋下、整個勢力的擴張空轉
```
答「想被挑的」第 2 點：會，而且不需要罕見條件。
  · _evaluate_new_outpost_location 只回 candidates[0]（faction_ai_system.gd:6102-6110）；:6441 _dispatch_builder 被 site_barren 擋下後，沒有任何東西讓下一輪改選次佳格。
  · 夾在期限的項 ＝ −30 × 5 × w ＝ −150w（w＝0.5＋野心；野心 0.5 時 −150，野心 0 時 −75）。
    平原分數 ＝ productivity×100(90-130) ＋ 20 ＋ 距離項 ＋ 資源加成。資源加成（faction_ai_system.gd:6026-6029）每個鄰格出現一次：herb 30、wild_horses 25、ore_iron 20。
    本格＋鄰六格內有兩三個 herb／鐵礦的平原格，加成 60-90 ⇒ 130＋20＋60−150 ≈ 60 > MIN_BUILD_SCORE(50，:6015) ⇒ 仍是候選，且可能是最高分。
    野心低的 leader（w＝0.5）更容易：−75 就壓不下去。
  · 這格 gather_days > 窗 ⇒ _dispatch_builder 回 site_barren ⇒ 下一輪（INFRA_INTERVAL）再選同一格。與「一個勢力的新點 81/81 倒在材料閘」是同一個形狀，只是閘換成 site_barren。
改法
  選址迴圈用【與 _dispatch_builder 同一個判準】先濾：gather_days > gather_window_days()（＝build_eta_total_days 回 INF）⇒ 該格不進候選（continue），並計 Probe「site.skip_barren」。
  這不是新硬門：它是 site_barren 這個物理的提前版，同一支函式、同一組 carried／site 輸入，選址與派遣不可能各說各話。
  可行格（天數 ≤ 窗）才吃 gather_term；那時夾在期限就沒必要了（天數本來就 ≤ 30）。
驗收補
  V11b：床內造一格平原（資源加成夠高，沒有 gather_term 也最高分）、母隊料 0 ⇒ 選址不回它；母隊料 ≥ need ⇒ 回它。
  n17：選址不濾 INF 格 ⇒ V11b 紅。
```

# 量級（答第 1 點，我不裁，請交件信印出來給藍圖）
```
項的單位是「分」：productivity×100（同一地形內分布約 ±20）、地形加成 平原+20／森林+10／山地−10、每格距離約 −3（−5＋(10−d)×2 的淨效果）。
5.0 對距離是「一天採料＝一格路」，合理；但採料天數遠大於距離（森林約 7、山地約 22、平原約 72）：
  · 森林 7 日 ⇒ −35w：productivity 0.7 的森林，距離 3：70＋10−15＋14−35 ＝ 44 < 50 ⇒ 被 MIN_BUILD_SCORE 剔掉；1.1 的過得去。
  · 山地 22 日 ⇒ −110w：除非礦加成（ore_here × 貪婪＋野心 × 2.5，faction_ai_system.gd:6045）撐住，基本全剔。
  · 母隊料 0 時，可行候選實質上收斂到「好森林」。若連好森林也都被扣到 50 以下 ⇒ loc.is_empty() ⇒ infra.stop.3_loc_empty（:6436）⇒ 該勢力不再擴張。
這個結果可以是對的（乙＋丙的字面：平原留給帶料的隊），但它是靠 MIN_BUILD_SCORE 這個既有門檻達成的，不是靠「價格」。
spec 用語「禁硬門」與實際不符：請在 §三之二 寫明「量級使母隊無料時候選收斂到好森林；非硬門但由 MIN_BUILD_SCORE 兌現」，
並在交件信印：每個勢力選址的 candidates 數、infra.stop.3_loc_empty 次數（修前修後）、各地形最後被選中的比例。
```

# 小項（不擋）
```
· V11 的「其他項床內設成相等」做不到：地形加成平原 20／森林 10（faction_ai_system.gd:6017-6019）是固定值。請改成：斷言回傳 dict 的 gather_term 欄位（森林項 > 平原項、料足時兩者為 0），
  再加一格「總分決勝」：平原的 productivity 調高到沒有 gather_term 時勝出，有項時森林勝出。
· 管線：gather_term 要的 carried（fundable_carry）是母隊級、gather_days 只隨地形變——請在迴圈外各算一次（fundable_carry 一次；三種地形的 gather_days 一張小表），
  不要在每個候選格內重算 build_eta_total_days（:6081 那圈是全圖掃，這裡正是註解 :6077 說過的 O(tiles²) 尖峰病歷）。
· 選址函式簽名要多收 野心 與 carried；現在只收 greed_ambition（貪婪＋野心的和，:6032）。w 要的是野心單獨一軸，請明寫從哪傳。
· 一個迴圈接線的負對照：n18 迴圈把 carried 恆傳 0（V11 直接呼 _site_candidate_score 看不出來）⇒ 用 V11b（走 _evaluate_new_outpost_location）抓。
```

# 判決
```
verdict: issues（小）
必補：M8（濾掉物理蓋不成的格＋V11b＋n17）；量級那段寫進 spec 並印數字
補完不需再審；其餘 dispatch 可進行
```
