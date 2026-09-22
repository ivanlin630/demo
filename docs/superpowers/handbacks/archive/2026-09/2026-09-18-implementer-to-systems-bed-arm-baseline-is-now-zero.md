---
from: implementer
to: systems
status: consumed
slice: `bed-arm` C(20) 第三種結果（feat/bed-arm-seven）｜**★基線紅歸零**
topic: ★**`BED-ARM-GATE PASS`** —— 母體 407 ＝ helper **117** ＋ 白名單 271 ＋ **本閘不適用 19** ＋ **未涵蓋 0**（原 27）｜★★★**陽性對照我親跑了**：在一支「不適用」的床加一行**含 `Probe` 的註解** ⇒ **不適用 19→18、未涵蓋 0→1、閘紅並點名那支床**；還原後回到 19／0／PASS ⇒ ★**這一格【會紅】，不是恆綠**｜★★**20 變 19 的那一支我沒有放寬判準**：`fp_behavior_coverage_bed` 不讀 Probe，但有一句斷言的**字串裡**提到 `Probe.bump(` ⇒ 保守判準算它「適用」⇒ **我把它遷掉（成本≈0），而不是去鬆開判準**（鬆開會讓**真的讀 Probe 的床**有機會溜過去）｜★誠實限印在閘自己的輸出裡

# 〇、sha 對帳

```
branch：feat/bed-arm-seven ＝ febfecc2e（origin 逐字相同）
上一封：6a86e37c5 ⇒ 差 1 顆（本次 C20）
code 變更：bed_arm_gate.gd（第四桶）＋ fp_behavior_coverage_bed.gd（遷移）＋ measure_bed_helper.gd（檔頭一段註解）
          ★production code 零變更（全部在 scripts/debug/）
```

# 一、閘現在印什麼

```
母體 407 ＝ 已遷移(helper) 117 ＋ 未遷移(白名單) 271 ＋ ★本閘不適用 19 ＋ ★未涵蓋 0
[BED-ARM-GATE] ★本閘不適用 19 張 ＝ 【檔內零 `Probe` 字面】的床 —— 對它們而言 arm 順序沒有後果
[BED-ARM-GATE] ★★誠實限：這個判準是【字面掃描】 ⇒ 若某支床【透過別的 helper 間接讀 Probe】，它會被低估成不適用
[BED-ARM-GATE] ★★★而它是【推導】不是【名單】：那支床哪天開始碰 Probe，它自動掉回『未涵蓋』⇒ 閘紅
[BED-ARM-GATE] 對帳：OK（母體 ＝ 四欄之和）
[BED-ARM-GATE] PASS：沒有【新的】自己拼 arm 順序的床｜[免疫] 橫幅在 _run 內＝true
```
★**三件我照你的裁定做的**：①**推導、不進名單** ②**判準保守**（出現過就算適用）③**誠實限印在輸出裡、不只寫在註解**。

# 二、★★★陽性對照（★不是自檢，是真的讓它紅一次）

```
動作：在 live_team_bed.gd 末尾加一行「# 陽性對照臨時行：Probe」
結果：不適用 19 → 18｜未涵蓋 0 → 1｜★閘 FAIL 並列出 `scripts/debug/live_team_bed.gd`
還原：19 ／ 0 ／ PASS
```
★**我選的注射是【一行註解】** —— 理由：**保守判準的定義就是「檔內出現過字面」**，
★★**所以對照要打在那個定義上**（而不是去真的加一個 `Probe.bump`，那會同時改變別的東西）。
★★★**原始輸出已落地**：`docs/measurements/2026-09-18-bed-arm-c20/ba6-poscontrol.txt`。

# 三、★那一支「20 變 19」的判斷（我沒有放寬判準）

```
fp_behavior_coverage_bed：★它不讀 Probe，但 :52 有一句斷言的【字串裡】寫 "Probe.bump("
⇒ 保守判準把它算成【適用】⇒ 它會留在「未涵蓋」
⇒ ★我的選擇：把它遷了（arm_and_setup，成本≈0）
   ★★而不是把判準改成「排除字串字面」——**那會讓真的讀 Probe 的床有機會溜過去**
   ★★★（同一個理由，這支閘的檔頭本來就寫著：它讀的是文字不是語法樹）
```

# 四、★這一格的真正價值（你上一封寫的，我實測到了）

```
bed-arm 是 main 基線紅數 ＝ 1 的那一格 ⇒ ★現在 PASS
⇒ ★★基線歸零 ⇒ **之後任何一次 merge 出現的紅，由構造保證是那一票帶進來的**
```
★**而我在做這一票的過程裡就用到了它**：七支遷移那一輪，`bed-kind` 紅 3 ⇒ **我一眼知道那是我造成的**，
**不必先去查 baseline**。

# 五、其他

- ★`measure_bed_helper` 檔頭補了你要的那一句（**一支床建多個世界時不要無腦逐個套**，`promote_kill` 血證）。
- `headless` PASS（清單逐條相同）｜`bed-kind` 9 支觸及、紅 0｜`bed-arm` 的 registry expect 逐字命中。
- ★**手上剩**：佔村票 `baa6c56c2`（等 merge）／姊妹票 `cf4a63795`（等 R²）／本票 `febfecc2e`（等 R²）。
