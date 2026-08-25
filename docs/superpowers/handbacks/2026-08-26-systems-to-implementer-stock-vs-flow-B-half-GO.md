---
from: systems
to: implementer
status: open
slice: stock-vs-flow-ruler
topic: ★reviewer CLEAN,不用拆票 ⇒ B 半(接線)GO,現在就做;★★接線點我定位好了=goal_resolver._resource_prereq_candidates 裡那個「stock 形狀只發 tap 不生 candidate」的 elif 分支;★★★死水兩欄你不用另開床——means_end.stock_seen.<res> 這顆 counter 已經在那裡了
---

# GO — reviewer 判 **CLEAN，不用拆第二張票**

**A（接線 in-scope）對；B（三條附帶要求）三條都留，都不是恆真式。**
★他對 `fp` 那條的論證比我寫的更準，抄過來當你的判準：
> **改前這條路根本不存在，沒有「等價」可言** ⇒ **接線後 `fp` 仍不動 ⇒ 唯一合理解釋是新路徑沒被走到。**

---

# ★★接線點：我定位好了，你不用再找

**語意錨（不是行號）**：`scripts/simulation/decision/goal_resolver.gd`
→ `static func _resource_prereq_candidates(...)`
→ 裡面那個 **`elif String(path.get("shape", "")) == "stock":` 分支**

```gdscript
# ★stock 形狀【不進價值比較】（systems 裁）：只發 tap，不生 candidate。
#   拿流的尺量存量會系統性高估，而且錯成一個看起來正常的數字。
elif String(path.get("shape", "")) == "stock":
    if Probe.enabled: Probe.bump("means_end.stock_seen." + res)
```

★**那個「systems 裁」就是我，而我當時之所以裁「不進價值比較」，理由只有一個：★★沒有正確的尺。**
⇒ **這張票就是把那把尺造出來** ⇒ ★**B 半 ＝ 讓這個分支開始生 candidate，用 `stock_utility` 定價。**
★★**所以它不是「新接一條手段」，是【解除一個因為缺尺而暫時封起來的出口】。**
（`elif` 上面兩個分支 —— `PREREQ_RESOURCE` 遞迴 與 `ready`→`TASK_MANUFACTURE` —— 就是你要照抄的形狀：
`_mk_candidate` ＋ `me_depth` ＋ `out.append`。★**別忘記 `out.append` 要在 `if` 內**——那行註解是上一顆 bug 的墓碑。）

---

# ★★★三條附帶要求裡的第 3 條（死水兩欄），**你不用另開床**

★**答案已經在 code 裡等你了**：那個分支現在就在 bump **`means_end.stock_seen.<res>`**。
⇒ **接線前先跑一次、把它印出來**，你就直接拿到「這張床上有沒有隊真的為 stock 資源定過價」：

| `means_end.stock_seen.*` | 意思 | 你要做什麼 |
|---|---|---|
| ★**非零** | 有隊走到過這個分支 ⇒ **接線後 candidate 會真的生出來** ⇒ ★**`fp` 必須變** | 照常做，`fp` 變是預期 |
| ★★**全 0** | ★**接線是活的但沒被走到** ⇒ 驗收③ 從未被行使（母體塌陷） | ★**照原樣回報，不要自己補床、不要改床去逼它 fire** |

★**這顆 counter 我在 `docs/measurements/` 全目錄 grep 過：一次都沒出現在任何輸出裡**
⇒ ★★**它從來沒被讀過** —— **這正是「儀器裝了但沒開」那一型**，順手把它讀出來。
★★★**逐 `res` 印，不要只印總數** —— `SHAPE_TABLE` 是 4 個成員（`ore_iron`／`ore_gold`／`ore_silver`／`gem`），
**總數非零但集中在 1 個成員，跟 4 個都有，是完全不同的兩件事。**

---

# ★交付要求（重貼，免得回頭返工）
- `tier: **behavior**`
- ★**呼叫點【報清單不報數字】**：貼出每一個 `檔:函式`，我對 4 個成員逐一核
- **驗收②**：`flow_utility` 的 4 個既有 caller **byte-identical**（再生路徑此票不得動）
- **驗收③**：`S / gain_daily ≥ H_eff` 時 `stock_utility ≡ flow_utility`
- **驗收④**：零新常數（`estimator-lineage-scan.sh` 綠）
- ★**merge 前用閘不用眼睛**：`bash .claude/hooks/test-ran-floor.sh <實跑輸出>`（baseline 現在是 7 條）
