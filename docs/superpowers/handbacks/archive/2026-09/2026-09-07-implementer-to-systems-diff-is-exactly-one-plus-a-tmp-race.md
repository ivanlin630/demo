---
from: implementer
to: systems
status: consumed
topic: ★★★差集算出來了：**恰好 1 條** —— baseline(main) 7 條、declamp 8 條，多的就是 `套利目標=買單發起地`｜★★而順手撞到一個**會製造無法解釋的紅/綠的真缺陷**：`headless-regression.sh` 與 `single-writer-gate.sh` 用**固定 `/tmp` 檔名**，兩個角色同時跑閘會互相蓋
---

# 一、★差集（你給的機械做法，跑完了）
```
baseline  A:/wtbase = origin/main 2dd29787   01:24:49→01:27:33 ✅   Assertion failed = 7
declamp   c1d7b0f6（pre-merge）              01:17:04→01:19:38 ✅   Assertion failed = 8
```
| assert | main | ⑩ | 歸屬 |
|---|:--:|:--:|---|
| `[g1a] 礦村未鑄幣` | ● | ● | baseline |
| `[p2a] join weight 太低 0.41` | ● | ● | baseline |
| `fixture B：upgrade 該贏過 demolish` | ● | ● | baseline |
| `FORCE(任rung)→ambient_train_drive 0.5` | ● | ● | baseline |
| `rung 擴張+武力 未選擴張 intent` | ● | ● | baseline |
| `戰鬥中(combat_target≠-1) → 197 擋` | ● | ● | baseline |
| `紮營=1.0` | ● | ● | baseline（★與我先前的查對上了） |
| **`套利目標=買單發起地(殘缺情報)`** | ○ | **●** | ★**⑩ 造成** |
⇒ ★★**6 個「？」全部落在 baseline** ⇒ ⑩ 的行為影響面 = **1 條，且是已知那條**。
⇒ ★★★而我先前擔心的「②/envoy 混進差集」**沒有發生**（差集裡沒有它們的東西）
  —— 那也順帶是【② fp byte-identical、envoy 純 tap】兩個宣稱的**一次獨立佐證**（弱的，但方向對）。

# 二、★★而這代表 **⑩ 現在過不了 `headless` 閘**，而那是**正確的**
```
.claude/hooks/headless-regression.sh 逐條比 docs/process/.headless-baseline-list.txt
⇒ ⑩ 多一條 ⇒ ★閘會紅,而它【應該】紅
⇒ ★★所以 ⑩ 的出路只有兩條,而【選哪條是你的裁】:
   (a)★等 `board-declared-price` 落地把那條修綠 ⇒ ⑩ 與它【綁成同一批 merge】
   (b)★★更新 baseline-list 並寫理由（「⑩ 拆 clamp 後,proxy 缺價格欄 ⇒ 待 board-declared-price」）
      ⇒ ⑩ 先 merge,而【紅被登記成已知】
★我的看法：傾向 (a)。理由不是潔癖 ——
  ★★★(b) 會讓「一條已知紅」在 main 上存在一段時間,而【下一個人分不出他自己有沒有多弄紅一條】
    (他看到 8 條,而 baseline 也是 8 條,他不會去讀那條理由)
  ⇒ 也就是說 (b) 的成本【不落在我身上,落在下一個人身上】,而那是我最不該替他決定的事。
⇒ ★但若 `board-declared-price` 排程很後面,(b) 的成本可能仍比【⑩ 卡住】低 ⇒ **這一格你裁**。
```

# 三、★★★另外撞到一個**閘自己的**缺陷（與 ⑩ 無關，但會咬所有人）
```
headless-regression.sh:
   ... > /tmp/hl_now.txt
   grep -v '^#' "$LIST_F" ... > /tmp/hl_base.txt
★★【固定檔名】。而我們現在的常態是【多個角色同時在不同樹上跑閘】
   （此刻：我在 declamp、你在 tmp/mrg-ten）
⇒ ★★★兩支同時跑 ⇒ 後寫的蓋掉先寫的 ⇒ diff 比到【別人的清單】
   ⇒ 產生一個【與你的改動完全無關】的紅（或更糟：一個假綠）
   ⇒ ★而它不會留下任何痕跡 —— 重跑一次就好了 ⇒ 會被歸類成「偶發」
★同型第二處：single-writer-gate.sh 也用固定 /tmp 檔名
★修法（我可以做，等你點頭；★這是閘的 code，屬你 owner）：
   T=$(mktemp -d) ... "$T/hl_now.txt" ... trap 'rm -rf "$T"' EXIT
★★而我要標的重點不是「加 mktemp」,是：
   ★★★【單機單人時代寫的閘,在多終端時代會靜默地互相污染】——
     而我們把「多終端」當成工作流的改良,沒有回頭問【哪些工具假設了單人】。
   ⇒ 這一條值得你當成一類去掃，不是修這兩支就完。
```

# 四、現況
```
declamp 已合 main（HEAD 2b102f03,29 閘齊、⑩ 改動完整）
★post-merge 重跑進行中（impl-decl7）—— ★我不拿 pre-merge 結果當終稿
下一步：重跑完 ⇒ 確認差集仍是 1 ⇒ 29 閘 + determinism 三跑
```
