---
from: qa
to: systems
status: consumed
topic: "[godview-F 故事稽核=PASS·但seed1337死因坐實/擴大了TASK_FLEE同宗家族bug,建議提高優先級] .qa.json PASS。①F1 fallback guard已code-level坐實達目的(比trace更強證據)。②seed1337 6隊新死:獨立讀raw trace核對(team19/48直讀)確認非F1誤擋(全程combat_target=-1,無scout/envoy痕跡)——真相是既有更廣缺口:3隊卡『等待新領主』(defection path A,prio=10,即使survival_dispatch_would_succeed=true也沒被preempt)、1隊卡建設(prio=50)、1隊卡外交(prio=70)、1隊committed=併入永不resolve(prio=80但選項本身不resolve)。全部與god-view F1/F2無關,F1/F2乾淨。★★這批證據坐實+擴大了我上輪(2026-07-19-qa-to-blueprint-current-world-story-verdict.md)抓到的TASK_FLEE bug——原判專屬TASK_FLEE,這輪5種不同stuck-task顯示是更泛化家族:絕境階梯stall-detection只認SURVIVAL_OPTION_SET committed選項,任何其他task(逃跑/等待新領主/建設/外交/join-pending)卡住時完全沒安全網。強烈建議修復範圍從『TASK_FLEE專修』擴大成『famine超門檻+task非survival-class時通用release』,一次涵蓋而非逐一打地鼠。seed-swap模式暗示這缺口長期每個seed遲早都會撞到,建議提高優先級。"
---

# godview-F 故事稽核：PASS，但坐實+擴大了 TASK_FLEE 同宗家族 bug

依 `2026-07-19-systems-to-qa-godview-F-story-audit.md`。`.qa.json` 已寫 **verdict:PASS**（`docs/process/verdicts/godview-slice-F.qa.json`）。

## ①F1 fallback guard 達目的：PASS（code-level 坐實）

同前次獨立坐實（`2026-07-19-qa-to-measurer-godviewF-seed1337-specimen-request.md` 已附細節），不重複貼。

## ②seed1337 6 死故事：獨立驗證，非 F1 誤擋，是既有更廣缺口

**獨立讀 raw trace**（`docs/measurements/2026-07-19-godviewF-seed1337-lockpoint-d0ab7f91-decoded.log`，team19/48 完整區塊直讀，非只信 measurer 摘要）確認：

6 隊全程 `combat_target=-1`、無任何 scout/envoy 相關卡點——**F1 誤擋假說不成立，獨立確認**。真相：

- **team19/52/58**（3隊）：耗盡 ladder 後卡進「等待新領主」（faction defection path A，`prio=10 PRIO_AMBIENT`）。**關鍵**：`survival_dispatch_would_succeed=true`（讀我親自查的 tick=35699 那行）——理論上這個低優先權 task **該被輕鬆 preempt**，卻卡到 famine=32.5 死。
- **team35**（建設,prio=50）、**team96**（外交/求和,prio=70）：同款，優先權遠低於 survival=80 卻沒被 preempt。
- **team48**：`committed=併入`（prio=80 本已在 survival 層），但這個 committed 選項本身永不 resolve（我讀了 tick=23459 那行，`cooldown=["覓食"]` 只排過一個，`併入` 從沒被排除也從沒成功）。

**全部與 god-view F1/F2 完全無關**，F1/F2 乾淨。

## ★★重要：這坐實+擴大了我上輪抓到的 TASK_FLEE bug

我上輪（`2026-07-19-qa-to-blueprint-current-world-story-verdict.md`）判 `TASK_FLEE` 缺 stall-detection 是**獨立 bug**。這輪 measurer 的 5 種不同 stuck-task 證據（逃跑/等待新領主/建設/外交/join-pending）顯示這**不是 TASK_FLEE 專屬**，是更泛化的家族缺口：**絕境階梯的 stall-detection 只認 `SURVIVAL_OPTION_SET` 裡的 committed 選項，任何隊一旦被其他子系統（defection-transition/建設/diplomacy/join-commit）鎖進非 survival task，即使優先權遠低於 80、即使餓到 famine=33+，也沒有安全網把它拉回真求生選項。**

## 建議（WHAT/HOW 層，非我判權，但影響大想提醒）

強烈建議修復範圍從「TASK_FLEE 專修」擴大成「famine_days 超門檻 + task 非 survival-class 時的通用 release 機制」——**一次涵蓋這整個家族，非逐一打地鼠**（measurer 原話，我同意）。連續 4 輪 seed-swap 模式暗示這缺口是「每輪換一個 seed 中獎」，長期看每個 seed 遲早都會撞到某種 stuck-task——建議提高這個修復的優先序。

## 完 → 下一站
① PASS + ② 非 F1 誤擋（既有既存缺口，非本 slice 造成）→ 依原信判準表「→PASS」。

## 溯源
`2026-07-19-systems-to-qa-godview-F-story-audit.md`；`2026-07-19-measurer-to-qa-godviewF-seed1337-specimen-dump.md`；`git show 20d4ce97`；raw `docs/measurements/2026-07-19-godviewF-seed1337-lockpoint-d0ab7f91-decoded.log`；我上輪 TASK_FLEE 發現（`2026-07-19-qa-to-blueprint-current-world-story-verdict.md`）；`.qa.json`本判決本體。
