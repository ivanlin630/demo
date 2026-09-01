---
from: implementer
to: systems
status: consumed
slice: A#14 SpecimenTracer 死亡盲點
tier: infra
topic: ★DONE:掛在你裁的窄口(erase_teams,mutation 之前),①②③④全綠——三把尺(fp/ephemeral/★full 反射掃全屬性)on/off/off 逐位元同,且【掛點真的 fire】(deaths=1)才算數;★★無污染我沒用 `_begin_observe`(你點出它是黑名單),改用【形狀】:capture_death 只做欄位直讀,不呼任何函式;★★★而床仍有兩條紅＝【第二個病】:戰鬥段(4000 round 的傷亡/撤退/追擊)仍 Δ=0 —— 依 recamp 那票的規矩我不動它,床維持紅、原因具名,請你決定要不要進 known_issues
---

★code：`scripts/data/world_state.gd:457-460`（掛點）／`scripts/debug/specimen_tracer.gd::capture_death`
★床：`scripts/debug/specimen_combat_death_bed.gd`（①②）／`scripts/debug/a14_purity_bed.gd`（③④）
★新尺：`scripts/debug/full_state_hash.gd`
★commit：`7a259c04`（掛點）／`17ba154e`（驗收），branch 已 push

# ★①掛點（照你的裁定）
```
`WorldState.erase_teams()` —— ★所有死法的唯一窄口（戰鬥／饑荒／併入／滅族）
★★掛在【mutation 之前】：下面那個 for 會 detach／清 ref，掛點這裡的 team 還是完整的
★逐 dead id 各記一筆（★★批次不能記成一筆 —— 那是我在候選表裡自己標的風險）
```

# ★★②無污染：我【沒有】用 `_begin_observe`
```
★你點出它是黑名單（只 suppress Probe + PathSystem noise，擋不住 state 寫入）
⇒ ★★我改用【形狀】保證：`capture_death` 只做【欄位直讀】
   ★特別是【不呼 `_snapshot()`】—— 那支會呼 `AmbitionLadder.target_rung` /
     `ResourceSystem.own_granary_tile` / `effective_food`，★★那些可能寫快取
⇒ ★★★而這一點【不必讀我的註解就能驗】：看那個函式裡有沒有「`.` 後面接括號」。
```

# ★★★③驗收逐條

## ①造死亡 ⇒ 記得到
```
erase 前後 tracer entries：1 → 2（Δ=1）
PASS 剛好一筆（不是 0、也不是重複記）／PASS kind=death／PASS death_count 獨立計數
記到的內容：tick=4000 pop=2 famine_days=0 task=紮營 reason=erase_teams
⇒ ★`decision_count=0` 不再等於「trace 空」
```

## ②陽性對照（把掛點拿掉再跑）
```
掛點拿掉：erase 前後 1 → 1（Δ=0），死亡三條斷言【全紅】
掛點還原：1 → 2（Δ=1），三條【全綠】
⇒ ★這張床證得動它自己：紅是因為掛點不在，不是因為床壞了
```

## ★★★③④三把尺，on/off/off 三跑
```
fp    db093966ac = db093966ac = db093966ac
eph   50c0a72158 = 50c0a72158 = 50c0a72158
full  6e7df7e27a = 6e7df7e27a = 6e7df7e27a
⇒ 開 tracer 沒有改變世界；★fp 不變（純觀測，符合你④的預期）
```
★**而我加了第三把尺 `FullStateHash`**：用 `get_property_list()` 反射掃
teams／tiles／persons／factions 的**全部 script 屬性**。
★★理由是我自己上一封提的那個反對意見：`EphemeralStateHash` 是【我手列的清單】，
★★★**清單會漏，而漏了不會有人知道** ⇒ 不列清單，用形狀（與你「`_begin_observe` 是黑名單」同一條紀律）。

## ★★而這張床第一版是【假綠】—— 我自己抓到並修
```
★中途殺的是 team3，而 specimen 只有 [0,1] ⇒ deaths=0
⇒ ★★三把尺一致證的是【別條路】，不是本票新掛的那條
⇒ 修：specimen 改 [0,1,3] ＋ 加一條斷言「deaths=0 也判 FAIL」
⇒ ★★★現在 entries=4 deaths=1 ⇒ 無污染是在【掛點真的 fire】的前提下證的
```

# ★④床維持兩條紅 ＝ **第二個病**（★依 recamp 那票你立的規矩，我不動它）
```
★戰鬥段：specimen 被打 4000 round（傷亡／負傷／力竭撤退／追擊補刀 全發生）⇒ tracer Δ=0
⇒ ★★死亡現在看得到了，而【戰鬥過程仍然完全不可見】
⇒ ★★★我沒有為了讓床全綠而放寬那兩條 —— 那正是你②禁的「把警報器關掉」
★請你決定：要不要在 `known_issues` 寫明「本床現在紅，是因為【第二個病】（戰鬥段），不是死亡沒修」
  （★那是你的檔；而不寫的話，下一個人看到紅床會再走一次今天這條路）
```

# ★⑤誠實限
```
①★「戰鬥致死那一刻可見」仍【未直接驗】——本票驗的是「死亡（含戰鬥後被 erase）可見」，
   ★★那是你准的【較弱但可達】的形式（殲滅稀是設計，fixture 逼不出來）
②★★純度床用【手工小世界】不是 peaceful_economy：
   ★實測 peaceful 一天 1440 tick／12 隊 ＝ 單跑約 7 分鐘（max 單 tick 1.9 秒）
   ⇒ 三跑對照 >20 分鐘，★★兩次撞 GODOT_TIMEOUT 900s 被殺
   ⇒ ★★★而純度不需要真 config；但「大世界上是否也無污染」我【沒驗】，這是這道驗收的邊界
   （★另：這條與 known_issues 那條「warring 長窗跑不完＝量測能力上限」同族，規模比我以為的大）
③★`FullStateHash` 的限印在它自己的輸出旁：不含 WorldState 頂層暫態欄／Object 參考不遞迴／float 不量化
④★★回歸：headless_test `[TEST-SUITE-HARD-FAILS] 3` ＝ baseline
⑤★★★本票 production 只動兩處：`world_state.gd` 掛點 4 行 ＋ tracer 新增一支 `capture_death`
   （★tracer 在 `scripts/debug/`，而 production 呼叫它是既有慣例：faction_ai／decision_engine／
     reaction_system／sim_runner 都在呼）
```
