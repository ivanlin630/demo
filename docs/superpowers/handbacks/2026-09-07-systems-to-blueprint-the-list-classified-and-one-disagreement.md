---
from: systems
to: blueprint
status: consumed
slice: ★★★名單到了、我照【預註冊判準】機械分類完 —— 而有一格【我與 implementer 的證據不一致】，我不自己解決
topic: ★名單:26 支有直寫的床,runtime 真的踩到的【只有 10 支】(另 16 支是死碼);UNKNOWN=0(全有結束列=證人欄有效);★★我照你預註冊的三條機械對帳:(c)merge-gate 可達=【只有 headless_test】(9 處命中,而它只透過 hook 才跑得到);(a)意圖帳/判決引用=headless_test 25 筆、own_granary_null_caller_test 1 筆(它是 own-granary-29-recheck 那份判決的 target);★★★而 qa_probe 這一格【我與 implementer 不一致】:他說「它產的數字被寫進 QA 判決、也推過用戶」,而我掃整個 docs/ 只找到【2026-06 的 archive handback ×7 + 今天的掃描產物】,沒有任何現行判決/意圖帳引用 ⇒ 我【不自己選一邊】,把兩邊證據交給你;★而 (b)「推過用戶 TG」我【從 repo 查不到】——那是你的頻道,不是我能機械判的
---

# ★一、名單（★而最大的數字不是 10）
```
26 支有直寫的床 → ★runtime 真的踩到【只有 10 支】⇒ ★★另 16 支的直寫是【死碼】
UNKNOWN = 0（26 支全有結束列）⇒ ★★★陰性欄這次【可信】——證人欄起作用了
```
DIRTY 10 支：`headless_test` / `qa_probe` / `encounter_sim_test` / `map_render_test` /
`own_granary_null_caller_test` / `settlement_s2a_test` / `survival_layer_unify_test` /
`team_ui_test` / `ui_flow_test` / `ui_logic_test`

# ★★二、照你預註冊的三條機械對帳（★我沒有加判斷，只是跑對帳）
```
(c) merge-gate 可達  ⇒ ★【只有 headless_test】(9 處命中)
    —— ★★而它【只透過 hook 才跑得到】(headless-regression.sh);註冊表 11 支直接跑 .gd、19 支經 hook
(a) 意圖帳/判決引用  ⇒ headless_test【25 筆】
                      own_granary_null_caller_test【1 筆】
                        = docs/process/verdicts/own-granary-29-recheck-2026-09-02.measure.json 的 `target`
                        ⇒ ★一份判決【就是建在那支床上】
其餘 7 支            ⇒ 0/0 ⇒ 照裁定【記帳標記,不重跑】
```
⇒ ★★**必重跑 = `headless_test`（a+c）＋ `own_granary_null_caller_test`（a）**

# ★★★三、而 `qa_probe` 這一格：**我與 implementer 的證據不一致**
```
他寫:「它產的數字被寫進 QA 判決、也推過用戶」⇒ 落在 (a)(b)
★而我掃整個 docs/:qa_probe 出現在【8 個檔、16 次】,而內容是:
   ★★2026-06 的 archive handback ×7（session handoff 那批）＋ 今天的掃描產物本身
   ⇒ ★沒有任何【現行判決／意圖帳】引用它
⇒ ★★★兩種可能我都不排除:
   ①QA 判決不在我掃的那些路徑裡(那我的檢查有覆蓋缺口)
   ②他那句是【印象】而不是查證過的
⇒ ★而我【不自己選一邊】—— 今天我已經兩次把「數字不一致」用一個聽起來夠好的解釋處理掉,
   ★★所以這次我把【兩邊的證據】原樣交給你
```
★**要你回的**：**QA 的判決檔在哪？**（若不在 `docs/process/verdicts/`，我的 (a) 檢查對 QA 那條線是瞎的。）

# ★四、而 (b)「推過用戶 TG」：**我從 repo 查不到**
```
★那是你的頻道 —— repo 裡沒有 TG 的紀錄
⇒ ★★所以 (b) 這一條【只有你能對】,而我把 10 支的清單給你,由你比對
```

# ★五、順帶：**16/26 是死碼**這件事改變了 stage B 的形狀（★HOW 我已裁）
```
★那 16 支的修法【不是修,是刪】—— 一行【從來不執行】的 fixture setup,
   改成 add_anon 只是把死碼換成另一種死碼
★★而它們【沒有驗證方式】:改壞了也不會紅(因為它不執行)
⇒ ★★★「全部改」會產生一批【無法驗證的改動】,而那比留著更糟
```
