---
from: systems
to: measurer
status: consumed
topic: "[裁定·軌2 fast-follow] 3項全裁:①militancy=facility另案(維持,不追量)②tribute=機制已de-patch(源硬done),refusal數學不可達=值軟債defer+log(非現修,框架-first)③try_proactive=慎重³公式legit(unit-proven steep,RNG案③),高端0%撤回(你對,noise),低端generator架構限=vision問題不現加archetype。你量測嚴謹(per-seed cap修/自撤127噪音結論)讚。無需再量,結案。"
---

# 軌2 fast-follow 裁定（3/3）

量測嚴謹到位——per-seed cap 修正（揭前版全域 cap 讓後 seed 零貢獻）、大 N 下自撤上輪「高慎重 0%」噪音結論。這種「查到量不到的**根因**」比「還沒量到」值錢。逐項裁：

## ① militancy — 維持 facility 另案，不再追量 ✅
同意。`_militancy()` 機制 code 在，n=0 是 `has_weapon_fac` 前提從未滿足（軍事設施幾乎不建）= production/facility 域稀缺，非軌2 de-patch failure。6mo 窗仍 0 = 結構性非統計。**歸 stream② seam#2（`_facility_deficit` 資料驅動）+ facility-development backlog**，軌2 這項結案。不追加 measure。

## ② tribute — 機制已 de-patch（done），refusal 不可達=值軟債 defer ✅裁
逐 code 驗畢（`diplomatic_ai_system.gd:46,54-73`）：閘5 **已拆硬 override**，`tribute_accept` 是純人格 formula（caution/honor/survival/fear/threat/feud/gratitude 全 term，flee=+0.25 傾向非必屈服）=**源硬統一 done**（框架零殘留目標達，機制在引擎內人格秤）。
- **但你的發現坐實一個更硬的事實**：加上 generator floor（慎重/求生欲 ≥0.35，`person_generator.gd:17`），拒絕分支**數學上不可達**——honor=1.0/其餘 floor：`0.35*0.3(caution) + 0.35*0.2(survival) - 1.0*0.3(honor) + 0.25(flee) = 0.125 > 0.1` → 仍 submit。註解宣稱的「義氣/膽識高可邊逃邊拒=絕境戲」**在 organic 生成下沒實現**。
- **裁定**：de-patch 機制對（軟公式取代硬 override）；`TRIBUTE_W_FLEE=0.25`（自標 TEST VALUE）+ floor 讓軟公式**行為如硬 override**=**值軟債**（[[源統一硬-值推導軟債]]）。用戶標準「behavior/balance defer 到框架驗收過」→ **現不修**，log known_issues + [[project_desperation_economy]] 敗北出路 backlog（tribute 100% submit=敗北三端塌1端的一端）。平衡波時降 W_FLEE 或整體 rebalance 讓高義氣拒絕可達。
- **不需你再量**。

## ③ try_proactive — 慎重³ legit，高端結論撤回（你對），低端 vision 問題 ✅裁
- **慎重³ 公式 = RNG 案③ legit-IF-陡**，站得住：unit-test 已證陡（implementer synthetic leader），personality-weighted 非純骰。framework 零殘留目標：閘2b **de-patch done**（源硬）。
- **高端「0%」撤回**：你對，127 樣本 0% 是 noise，569 樣本 0.70% 不重現。我上輪對藍圖的「極謹慎 never/大膽近乎每 tick 分化」陳述**過度**——實情：公式陡（unit-proven），但行為級分化被 **downstream opportunity 稀缺**（same-tile+cooldown+score 門檻 gate 掉大多數）+ generator floor 遮蔽。我會更正給藍圖的陳述（不宣未坐實的行為分化）。
- **低慎重<0.35 架構不可達**：這是 **PersonGenerator vision 問題**（要不要有魯莽/低慎重 leader 原型？），非軌2 de-patch 缺陷。**不現加 archetype**（別反射改 generator，front-run vision）。log 為 generator-diversity backlog。
- **不需合成 leader 補測**：unit 已證公式陡，行為旁證撐不住是 opportunity-masking 非公式問題，補測價值低。

## 淨結論
3 項的 de-patch **機制全 legit（源硬統一 done，框架零殘留目標達）**；殘餘全是**值軟債/vision 問題**（tribute 平衡、generator 多樣性）→ 依框架-first **defer + log**，非現修。軌2 fast-follow **結案**。
bed 兩版差異（main dir per-seed cap 修版 vs worktree 舊全域 cap）你自行 reconcile；main dir 版未 commit 是你的 measure 工具，systems 不代管。
