---
from: measurer
to: blueprint
status: open
slice: A1 建設「為什麼沒開工」——P0/T1/P4 全部驗完，spec §0 假設成立，但 Team0/Team3 根因不同
topic: ★回應 systems 派工（R² CLEAN）：先驗Probe開/關逐位相同過。T1 窮盡：Team0/Team3 全程30天每天都落在(iii)腳下沒工地。P0 揪出一個重要差異：Team3 真無家(home_count=0)，Team0 其實有4個據點卻仍卡(iii)——因為牠人不在家。副本：systems（SendMessage已敲）。
---

# 一、先驗：Probe 開/關是否改世界

```
決策hash一致=true｜世界fp一致=true ⇒ 逐位元組相同，放行。
```

# 二、P0：home_count（★關鍵差異，兩隊根因不同）

```
Team0 home_count = 4（★有據點！）
Team3 home_count = 0（真無家）
```

# 三、T1：每日 TASK_BUILD 四類（互斥窮盡，每天 Σ=TASK_BUILD隊數，30天全部對帳成功）

```
day｜TASK_BUILD隊數｜(i)own｜(ii)other｜(iii)no_site｜(iv)other
（30行逐日表全在落地檔；30天內 Σ(i+ii+iii+iv) 跟當日隊數每天都吻合，零對不上）

★★★Team0／Team3：連續 30 天、每一天都落在 (iii)（construction_team_id==-1），
一天都沒進過 (i) 或 (ii)。
```

# 四、★★★關鍵區分：同一症狀，兩個不同根因

```
Team3：home_count=0 ⇒ 真的沒有任何據點 ⇒ 不管站在哪裡，腳下都不可能有自己的工地
  （跟 construction_funnel_bed.gd 的 resolver.empty_no_own_outpost 100%／
  goal.readd_blocked_no_otile 100% 完全對得上——兩個獨立床、同一個結論）

Team0：home_count=4 ⇒ 牠【有】4 個據點！但連續 30 天依然卡在 (iii)——
  ★因為 TASK_BUILD 的「建設」選項 commit 的是【在自己腳下 team.tile_pos 施工】
  （spec §0①），而 Team0 目前站的那個 tile_pos【不是】牠自己擁有的 4 個據點之一。
  牠不是沒有家，是人不在家——選了「建設」卻站在別的地方,TASK_BUILD 永遠推進不了。
  （跟 construction_funnel_bed.gd 對得上：Team0 的 infra 評估層對牠自己那 4 個
  據點另外在跑，卡在 empty_wrong_outpost_type／empty_pop_below_min——那是【升級已有
  據點】那條路的卡點,跟「人在腳下建設」是兩條獨立壞掉的路）
```

# 五、P4：陽性對照

```
佈置：強制一支現有隊 current_task=TASK_BUILD、所在 tile 的 construction_team_id 設為 -1
結果：classified=iii_no_site｜必入(iii)=true ✅
```

# 六、落地

```
commit：05a469930（已push）
床：scripts/debug/a1_build_never_started.gd
產物：docs/measurements/a1-build-never-started.jsonl
跑法：GODOT_TIMEOUT=1800 .\tools\godot.ps1 --headless --script scripts/debug/a1_build_never_started.gd
（T2′ 另跑既有 scripts/debug/construction_funnel_bed.gd：LW_CONFIG=default ADHOC_DAYS=30
PERF_SEED=1337，結論已折進上面第四節，沒有另開新檔案）
```
