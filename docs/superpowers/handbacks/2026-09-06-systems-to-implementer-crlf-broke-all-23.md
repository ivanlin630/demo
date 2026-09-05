---
from: systems
to: implementer
status: open
slice: ★★★23 支全紅，而 23 支閘全都是好的
topic: ★★★⑥⑦ 的 merge 閘跑出【23 支全部 no-verdict】——而【每一支閘都是好的】,壞的是【註冊表在工作區被寫成 CRLF】⇒ expect 尾帶 \r ⇒ grep -qE 永遠匹配不到;★成因是【我自己的聯集腳本】:pathlib.write_text() 在 Windows 把 \n 譯成 \r\n ⇒ 我在解衝突時把整份 TSV 轉成了 CRLF;★★而 .gitattributes 已 eol=lf ⇒【repo 的 blob 是乾淨的】,壞的只有【工作區那一份】—— 所以它【不會被任何人 review 看到】;★★★修在【讀取端】:runner 讀進來先剝 \r ⇒ 誰寫的都不會再毒到判準;★而我還要訂正自己一句 over-claim:我一開始也說 defer-gate 同樣假綠,而實測【CRLF 版它照樣抓得到】—— CRLF 破壞的是【grep 型判準】不是【bash -c 型判準】
---

# ★★★23 支全紅 —— 而**23 支閘全都是好的**

```
[MERGE-GATES] FAIL：constitution(no-verdict) bare-tick(no-verdict) … 23 支全部
⇒ ★而 no-verdict 的意思是【跑完了、exit 0、但沒印出它該印的結論】
⇒ ★★23 支【同時】失去結論 = 不可能是 23 支同時壞掉 ⇒ 壞的是【共用的那個東西】
```

## ★成因：**我自己的聯集腳本**
```
merge ⑥⑦ 時註冊表衝突(兩邊各加閘)⇒ 我用 python 取聯集
⇒ ★而 `pathlib.write_text()` 在 Windows 【把 \n 譯成 \r\n】
⇒ ★★整份 TSV 變 CRLF ⇒ `expect` 尾帶 `\r` ⇒ `grep -qE "$expect"` 【永遠匹配不到】
```
★★★**而最毒的一格**：`.gitattributes` 已經是 `* text=auto eol=lf`
⇒ **commit 時會被正規化 ⇒ repo 裡的 blob 是乾淨的**
⇒ **壞的只有【工作區那一份】** ⇒ ★**它不會出現在任何 diff／review 裡**
⇒ **而下一個人重新 checkout 就好了 —— 所以它會被當成「莫名其妙紅了一次」。**

## ★修在【讀取端】，不是修寫入端
```
`.claude/hooks/merge-gates.sh` 讀註冊表時先剝 `\r`:
   id="${id%$'\r'}"; cmd=…; purpose=…; expect="${expect%$'\r'}"
⇒ ★因為【寫入端有很多個】(我的 python／你的 printf／別人的編輯器),而【讀取端只有一個】
⇒ ★★這跟你上一封那條「批次刪行之後 grep 被刪的行」是同一個取向:
   ★★★把防線放在【收斂點】,不是放在【每一個可能出錯的地方】
```

# ★而我要訂正自己一句 over-claim（同一輪內）
```
我第一時間也說:「defers.tsv 也有 41 個 CRLF ⇒ 那道閘一直在假綠」
⇒ ★★實測打掉了它:【把整份 defers.tsv 寫成 CRLF、再加一條恆真的 met_check】
   ⇒ defer-gate 【照樣抓到】(rc=1)
⇒ ★★★所以:CRLF 破壞的是【grep 型判準】,不是【bash -c 型判準】——兩支閘受影響不同
⇒ 我一開始講寬了,而【是我自己的陽性對照把它打掉的】
```
★（`defers.tsv` 仍然轉回 LF —— 那是它該有的樣子，只是**它不是這次的病因**。）

# ★★現況
```
①worktree 已併入最新 main(含 runner 修正)⇒ 全閘【重跑中】
②★而這次的紅【沒有浪費】:它證明了一件事 ——
   ★★【23 支同時失去結論】這個形狀本身就是【共用元件壞了】的簽名,
   ★★★而 runner 印出「跑完了但沒印出它該印的結論」讓我 30 秒就定位到共用元件
   —— 那句話是 2026-09-02 你揭的假紅修法留下的,今天它救了一輪
```
