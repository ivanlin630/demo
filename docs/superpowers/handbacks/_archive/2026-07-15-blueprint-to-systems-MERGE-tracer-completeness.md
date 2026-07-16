---
from: blueprint
to: systems
status: consumed
topic: [★批准 MERGE] tracer-completeness——全生命無洞+on/off byte-identical+try_set_noop活證+finder_miss code-verify同構→merge;誠實log(finder_miss未live);churn_tap_bed進repo;story-QA地基修好
---

# ★批准 merge：tracer-completeness（story-QA 地基）

用戶戳的「從沒量全程」→ 修好了。四項驗收：
1. **全生命無洞 ✅**（Team26 gap 1680→60tick=heartbeat cadence，時間維無洞）。
2. **★on/off byte-identical ✅**（零擾動硬紅線——觀測不變量破三次的核心，終於確認觀測不改世界；新 tap 零 state mutation 零 RNG）。
3. **try_set_noop churn tap ✅ 真實 code path 活證**（手構絕境隊撞同-prio→真 `_trigger_survival`→`TaskArbiter.try_set` false→`capture_decision(...,"try_set_noop")` @3235 真觸發捕捉，非手呼 API）。path 維機制活證。
4. **determinism byte-identical + 憲法/sanity 綠**。

**我批准 merge（tracer-completeness 分支，含 churn_tap_bed.gd）。**

## ★merge log 必含（誠實）
- **已修**：specimen 全生命（heartbeat cadence，無洞）+ 全路徑（attempt-tap 捕 commit-fail：try_set_noop 活證、finder_miss code-verified）+ **零擾動**（on/off byte-identical，觀測禁改世界達成）。story-QA 地基：往後 organic trace 可信、全生命全路徑、選讀有導航（heartbeat 骨架 + attempt-tap 細節）。
- **★finder_miss 未 live-demo（別吹）**：`faction_ai:3219-3223`,與 try_set_noop 同一 for 迴圈、緊鄰、同構＝code-verified 高信心,**但時限內未能構造 live 觸發**（罕見防禦分支：ctx 可行但 to_task 失敗的 race，organic 也從未撞到）。log 寫「finder_miss code-verified＋同構於 live-verified try_set_noop，live-demo 未達成（罕見 race）」，**不寫「已驗證」**。→ known_issues 留觀（若未來真 finder_miss 沒被捕→回頭查）。
- **churn_tap_bed.gd 進 repo**＝第二個 Tier1 控制場景床（pursuit_hiding_bed 後），收 `03b_measurer.md` 床庫。

## 影響：story-QA 地基修好
前面窗口 story-QA（Team20/26/18）信心打折不 un-merge；**往後 full-HD 觀察 + organic story-QA 有可信 tracer**（全生命+全路徑+零擾動）＝這正是為何 tracer-completeness 排在 full-HD 觀察前。

## 下一站
系統：merge tracer-completeness（含 churn_tap_bed）→ 誠實 log → progress.md → `to:implementer [DONE]`。
→ 序：desperation✅ / god-view✅(你執行中) / tracer-completeness✅ → **full-HD 觀察（下個大 slice，現在有可信 tracer 了）** → 照妖鏡。求和/外交 code-verify 平行收尾。

## 觀測不變量升條（承前討論，你 invariants owner）
三次同族破全修完（LOD-exemption 換世界 / RNG-confound / lifecycle 窗口+漏路徑）→ 收斂草擬觀測不變量段（specimen=全生命+全路徑+零擾動+禁燒 RNG，新決策/commit-fail 路徑必接 tap）+ 觀測盲點閘。這條可跟 tracer-completeness 一起落 invariants。
