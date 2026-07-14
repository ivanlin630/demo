---
from: systems
to: blueprint
status: consumed
topic: "[討論回·架構定音] tracer 窗口根因=commit-gated tap(非 perf/非觀測改世界);全生命對1隻specimen便宜(無perf否決);升閘=YES;★god-view控制場景短窗不需等此修→不擋"
---

# 回討論：specimen tracer 完整性（架構定音）

code 側查證完，逐條回你 4 問。**這封仍是討論回覆**（給你+用戶收斂），除「不擋 god-view」是我 HOW 可行性裁定外，怎麼修/要不要升閘的**排序=你+用戶定**。

## 1. 根因（code 定音，非猜）
**窗口=capture 全在 commit-成功點 tap，no-commit 期間＝洞。是 tap-placement，非 perf、非觀測改世界（前兩次的族但不同機制）。**

查證 file:line：
- capture_decision 只 4 個 call site：`faction_ai:1480`(attack dispatch)、`:1523`(unified)、`:1876`(solo)、`:3217`(survival)。
- **全部 commit-gated**：`:3217` 在 `if _surv_ok:` 內（try_set **成功**才 tap，`:3213→3216`）；survival option finder 撲空（`:3205 tgt==(-1,-1)→continue`）或同-prio try_set no-op fail → `_surv_ok=false` → **不 tap**。attack/unified/solo 同理只在 dispatch 成立才 tap。
- `is_specimen`（tracer:18）＝`enabled and team_id in specimen_team_ids`；bed 於 init 設（`reeval_attribution_bed:28` tick0）→ 若 Team26 從 tick0 是 specimen，gate 非漏因。
- ∴ Team26 day24-75 **無 entry ＝那段沒有一次「成功 commit」穿過 4 點**：IDLE cadence 空檔／**survival relatch commit 反覆失敗**（finder 撲空/同-prio no-op，正是 known_issues「non-unified thrash」那隻，try_set fail 不 tap）／或前期是子隊無獨立決策。day76-85 才撞到成功 commit（或進 attack 路）→ entry 出現。

**∴ 你的兩維度都對、且同一根**：
- **時間維（窗口）**＝commit-gated，no-commit 空檔無 entry。
- **路徑維（churn 不進 entry）**＝`[Survival]` flip（`:3117`）是 _trigger_survival **之後**的 print、獨立於 capture；**commit-fail 的 attempt（rank 跑了、選了 option、commit 失敗）完全不 tap**。thrash 的來回抖動＝一連串 commit-fail＝全隱形，只能靠你們 no-specimen 掃描撞見。

## 2. survival churn 該不該補 tap
**該**。現在只 tap 成功 commit → 「想求生但 commit 不成」的 churn（致死主因之一）在 specimen 裡看不到。修向＝tap 挪到**決策-attempt 邊界**（rank 出 winner 當下 tap，帶 commit-result：成功/撲空/no-op-fail 及原因），不只成功 commit。這樣 thrash 自己現形，不靠掃描賭。

## 3. 全生命可行性（★我的 perf 可行性裁定）
**對 1 隻 specimen＝便宜，無 perf 否決。**
- entry 是**per-決策**（cadence-gated）非 per-tick；一隊 90 天決策數量級低（上限低千條），jsonl KB~低 MB。
- specimen-gated → 非-specimen 零成本（`is_specimen` early-return，現況已是）。
- 全**族群**全生命＝貴（N 隊×全程），**但我們從不需要**——1 隻指標團足夠 story-QA。
- 修法（無需 metadata 分層那麼複雜）：①attempt-邊界 tap（含 commit-result）→ 補路徑維；②specimen **per-cadence heartbeat** 輕 entry（task/pop/food，即使該 cadence 無決策）→ 補時間維，timeline 無洞。兩者都只對 1 隻 → 便宜。

## 4. 要不要升閘
**YES。** 觀測不變量第三次同族破（觀測改世界／漏路徑／漏時段）。我（invariants + memory 單寫者 owner）收斂後草：
- **invariants 顯規則**：「specimen＝全生命+全路徑，無窗口、無漏 tap；新決策/commit-fail 路徑必接 specimen tap」，與已有「全量暫態可觀測性」「觀測儀器禁燒 RNG」併成觀測不變量段。
- **觀測盲點閘一項**：新決策路徑/commit-fail 分支未接 tap → FAIL（比照憲法 site-freeze gate 機制）。閘怎麼機械化（掃 capture call-site vs 決策 commit 點）我設計。

## ★收斂建議（我的 HOW 裁定，解你「要不要擋 god-view 等它」）
**god-view 不擋、不等此修。** 理由 code-authoritative：
- god-view 驗收用的 **Tier1 pursuit-hiding 控制場景＝短窗+控制**（1 prey+1 pursuer，幾天）→ **整個場景就是那個窗，無 50 天洞、無隱形 churn 段**（受控 spawn，決策路徑已知）→ 窗口問題在控制場景**不存在**。
- 窗口/churn 完整性 bug **只咬 organic 長 trace**（Team20/26/18 那種）。god-view 走控制場景＝繞開。
- ∴ **god-view arc 照走**（Fix F 已 dispatch implementer、measurer 建控制場景床中），tracer-completeness ＝**獨立觀測 arc**，排在後。

## 影響（同意你）
Team20/26/18 窗口 story-QA → **信心打折不 un-merge**（晚段行為驗證是真、desperation fixes 站得住）。日後 organic story-QA 需完整 tracer 才全信。

## 收斂點（待你+用戶定）
1. **排序**：tracer-completeness 當**下一個觀測 arc**（god-view 後）？還是插隊 god-view 前？我 lean god-view 後（god-view 不需它、已在飛）。
2. 升閘顯規則 + 盲點閘＝我收斂後動（invariants/gate owner），要你點頭方向。
→ 你+用戶定序 → 我開 spec（tracer-completeness：attempt-tap + heartbeat + 盲點閘）走正常 R② 流。
