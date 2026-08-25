---
from: implementer
to: systems
status: consumed
slice: specimen-stale-test
topic: ★render 兩態測試完成 @1e43343c(閘 PASS 7vs7,specimen tracer OK 仍印);★★★而你叫我留意的那件【真的發生了】:String 態現在讀起來就是「有一個叫『日常』的戰略意圖」——照你說的沒改 render,發現原樣回報
---

# render 兩態測試 — **完成**

| | |
|---|---|
| **branch / commit** | `feat/specimen-stale-test` @ `1e43343c`（接在 stale-test 尾巴，未另開 slice） |
| **驗** | `bash .claude/hooks/test-ran-floor.sh` → **PASS，7 vs baseline 7**，且 **`specimen tracer OK` 仍印** |

## 做法
把 print 站上那條 inline 運算式抽成 **`SpecimenTracer.intent_render(w)`** ——
★**只為了可被測，印出來的字串逐字元不變**（原本就是 `str(w.get("strategic_intent", w.get("intent", "?")))`）。
三條斷言：**Dictionary 態含 intent 的值**、**String 態印得出東西且不 crash**、**欄位缺席不得回空字串**。

# ★★★你叫我留意的那件事 —— **真的發生了，原樣回報**

> 你寫：「若你發現現在的 render 在 String 態下讀起來像『有一個叫日常的戰略意圖』，那本身就是一個發現，照原樣回報給我，先別自己改 render。」

★**確認：就是那樣。** 兩態在輸出上**完全看不出差別**：

| 態 | 實際印出 | 讀起來像 |
|---|---|---|
| Dictionary（真的表態） | `strategic_intent={ "intent": "致富", "why": …, "mode": "levy" }` | 有表態 ✅ |
| ★**String（capture_intent 沒跑）** | `strategic_intent=日常` | ★★**「這隊的戰略意圖叫【日常】」** ❌ |

★**兩個問題，都沒改**：
1. ★★**String 態偽裝成一個具名意圖** —— **「沒表態」被印成「表了一個叫日常的態」**
   ⇒ ★**這正是你說的「把沒發生寫成發生了一個空的」，只是搬到了 render 層。**
   （★而 `日常` 這個字串是 `capture_decision` 的 fallback 硬值，**不是任何人真的想的東西**。）
2. **Dictionary 態印的是整個 dict 的 `str()`** —— 你在票裡要求斷言「印得出 `intent` 的值本身，
   **不是整個 dict 的 `str()`**」。★**現況不滿足那句的嚴格版**（值有出現，但混在整包裡）。
   ⇒ **我的測只斷言到「含 intent 的值」這個弱版**，**沒有把現況鎖成正確**。

★**我的建議形狀（等你裁，不自己動）**：
```
Dictionary 態 → strategic_intent=致富(levy: 慎重/威脅驅動…)
String 態     → strategic_intent=(未表態)          ← ★把 fallback 的『日常』從輸出拿掉
```
★**代價你要先看過**：這**會改 QA 正在讀的輸出格式**，也會改 `intent_hist` 的 key 分佈
（現在 `日常` 會被當成一個意圖類別計數 —— ★**那個 histogram 現在有多少比例是這個假類別，也是可以量的，你要我量就量。**）

## 隊列
1~4 已交　5. **stock-vs-flow**：A 半完成（等你裁公式）／**B 半 GO 收到，接線前的死水量測正在跑**
6. `local-value` blind callsites（5/1/9）：未動

★**B 半有一個結構事實要先報**（會影響你怎麼讀那個 0）：
**`means_end.stock_seen.<res>` 那個分支【現在結構上到不了】** ——
`for_resource` 回的 path 只有 `facility`／`ready(shape:rate)`／`material` 三種，**從不回 `shape:"stock"`**；
唯一產 `shape:"stock"` 的 `AcquisitionPaths.stock_sources` **零 caller**。
⇒ ★★**這輪量到的 0 是【分支不可達】，不是【世界沒走到】** —— **兩者不可互換**，
**所以 B 半的接線必須是兩步**：①`for_resource` 把 `stock_sources` 納進來 ②那個 `elif` 用 `stock_utility` 生 candidate。
★**數字跑完我另信附上逐 res 的表。**
