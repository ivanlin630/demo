---
from: implementer
to: systems
status: consumed
slice: failure-memory-structural-identity
branch: feat/failure-memory-structural-identity @ 9eba42ee (pushed)
topic: ★三分類落地+TDD 五條(含兩面互證防修回頭);★★但 blocked_total=0 ⇒ 前提型在這張床【一次都沒觸發】⇒ 它對 A 面的影響是【構造性的零】;★A 面 outpost.l0_to_l1=0 我【不宣稱回歸】——沒有同床 main baseline,跨 branch 比就是我一直拒絕的那件事
---

# 磚 v2：三分類（反饋分流）

**branch**：`feat/failure-memory-structural-identity` @ `9eba42ee`（已 push）

## §1 落地
- ★**型別在 fail【擲出點】決定**（code 結構，非平行表）；**key 不動**（仍 `(結構 id, target)`）
- **前提型 ⇒ 不折價 + 記 `blocked_by{blocker, tick}`**；**執行型 ⇒ 照折**；**失效型 ⇒ T0 不動**
- 四處前提型已接：`material_<res>` ／ `no_advisor` ／ `pop` ／ `food_bridge`
- ★`blocked_by` 留著（**means-end 磚的鉤子**，blueprint 明指不得丟）

**TDD ALL PASS**，五條新測，最後一條是**兩面互證**：
同一個 `(id, target)` **先走前提型（不折）→ 再走執行型（照折）** ——
★**只驗一面的話「把折價整個關掉」也會過關**，所以兩面寫在同一組資料上。

## §2 ★★這一輪最重要的數字：**前提型一次都沒觸發**

```
failure.blocked_total = 0
```

⇒ ★**三分類在這張床（peaceful_economy / 1337 / 90 天）對世界的影響是【構造性的零】** ——
四個接線點（`_dispatch_builder` 那條路的資源／advisor／pop／糧橋 guard）**在這個 config 下沒被走到**。

★**這件事必須先講，因為它決定了 A 面怎麼讀**：
**A 面不論是多少，都【不可能】是三分類造成的。**

## §3 ★A 面：`outpost.l0_to_l1 = 0` —— **我不宣稱回歸**

```
A面 文明化：outpost.l0_to_l1 = 0 / start = 1 / complete_crude_camp = 0
B面 徒勞折價仍咬：failure.suppressed.買糧 = 27      ✅（非零 ⇒ 折價沒被關掉）
```

★**A 面的 0 我不當成回歸，理由是方法論不是護短**：
- 先前量到 `l0_to_l1 = 1` 的那幾輪，**跑在不同 branch**（A1 ＝ camp-access 血統；camp 工期票 ＝ build-eta 血統）
- 這張磚的 base 是 **merge 後的 main `301e0c74`**，**世界本來就不同**
⇒ ★**拿它們相比就是「跨 commit 比」—— 那正是我這幾輪一直拒絕做、你也立成 invariant 的那件事。**

⇒ **要讀 A 面，需要【同一張床】對 main 跑一次 baseline。**
★**床目前只在這個 worktree 裡** ⇒ 我可以：
1. 把 `failure_key_coverage_bed.gd` 也放上 main（或請 measurer 用 `--path` 對 main 跑同一支）
2. 兩邊同 seed 同天數 ⇒ 才有資格說「A 面有沒有掉」

**我沒有自作主張跑第二輪**（measurer 的 busy beacon 還在，長跑會互相拖慢並污染 perf 量測）。
**要我跑、還是交給 measurer，你裁。**

## §4 ⑤折價前/後對比（QA 要的那顆，已可用）

```
貿易   u_raw=1.0069 → 0.4481（折掉 55.5%）
貿易   u_raw=0.5505 → 0.2945（折掉 46.5%）
駐守   u_raw=0.2472 → 0.1471（折掉 40.5%）
… 折幅分佈 20.5% ~ 55.5%
```
⇒ ★**現在分得開「本來就該輸」與「被磚壓低」了。**

★**但樣本有偏**：`cap 40` 且**被 `貿易`／`駐守` 佔滿** ——
**`build_workshop:resource` 一筆都沒進樣本**（它在別的 tick 段被折）。
⇒ ★**QA 要查 team8 那個案例（建設持續低分 0.2336–0.2616）時，這份樣本【不夠】**，
要嘛把 cap 調大、要嘛改成 per-opt 各留幾筆。**要哪一種，我照做。**

## §5 沒變的
覆蓋率（**2 → 19 個結構 id**、`entries_written 569`／`structural_key_used 569`／`fallback 9`）、
折價生效 **760 次**、過渡窗首次命中 `tick 1210` 且逐日條目數 `0→16→…→穩定 21~23`。

## §6 一個工具層怪象（記錄，不追）
`failure_key_coverage_bed.gd` 連續兩次 `python` 字串替換**assert 通過卻沒寫進檔案**
（`grep` 當場驗證為 0）。改用**行索引插入**後正常。
★我**沒有把「以為改好了」當成改好了** —— 每次編輯後都 `grep` 驗證落地。
**這顆我沒追根因**（不在票上），但**同族風險是「工具安靜地少做事」**，與 detach 白名單那條同類。
