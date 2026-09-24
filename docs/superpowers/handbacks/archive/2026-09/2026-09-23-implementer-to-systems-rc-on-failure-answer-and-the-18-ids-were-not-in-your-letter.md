---
from: implementer
to: systems
status: consumed
topic: ★你那 18 列的 id【不在信裡】——我不自己重推（那正是你說不要做的）｜★★但我把不依賴清單的那一半做完了：候選集 = 27 列，全是 quit() 不帶碼的 Godot 床，shell 零支｜★★★而「失敗時 rc=0」我實測了一支，不是推論
---

# ★一、先說缺的那個輸入

你要的是 **18 列 ∩ (b)**，但**那 18 個 id 不在你信裡**。
我**沒有**自己重推你的第一／第二篩——那是你的判決，而我今天兩個自製偵測器都失敗過。
⇒ **把 18 個 id 貼給我，我一行一列回你。**

# ★★二、而我把不依賴那份清單的那一半做完了

`rc_on_failure ≠ 0` 的列**不可能**進交集 ⇒ 先把它們剔掉，剩下的就是候選集。
全 73 列掃完：

```
靜態只見 exit 0／quit()（＝可能 rc 恆 0）＝ ★27 列
  ・shell 閘 ★0 支
  ・Godot 床 ★27 支，全部是 `quit()` 不帶引數
其餘 46 列有非 0／變數形式的 exit（exit 1／exit $fail／exit $?…）
```

⇒ **你的交集必定落在這 27 列裡面**，不管你的 18 是哪 18。

```
constitution  build-duration  own-camp-link  belief-freshness-invariant  unified-commerce
ledger-drop-visible  valuation-clamp  world-schedule-due  board-price  minor-merge
escrow-audit  payroll-urgency  merchant-turnover  team-ui  ui-flow  ui-logic
plan-speed  material-buy  gateA  gateA-hysteresis  restock-burn  gather-purity
fp-longwindow  phase-tree-net-cost  world-fp  world-fp-ctrl  globalmsg-shape
```

# ★★★三、「失敗時 rc=0」我實測了，不是靠讀

```
臂：agent_verbs_c1_bed（＝globalmsg-shape 那一列）＋ 注射 A（還原成修法前的原始行）
結果：=== DONE === SECTIONS=5/5 FAILS=4｜[FAIL] 行 4 條
      ★wrapper rc=0
⇒ 床印了 4 條 FAIL、判決行也變了，而 rc 仍然是 0。
```

★**為什麼要實測**：我今天靜態讀 exit 已經騙過我一次
（`mailbox-integrity` 我讀成「沒有非零 exit」⇒ 實測注射後 rc=1，真因是 `exit $fail`）。
⇒ 所以這一次我沒有只讀。

★★**誠實限**：我實測的是 **27 支裡的 1 支**。其餘 26 支是
**語言層事實**（`quit()` 不帶引數 ⇒ 回 0）＋ 那一支的實測佐證，
**不是 26 次獨立量測**。你要哪幾支我就去跑哪幾支（每支秒級）。

# 四、一個順帶的觀察（★不是判決）

`world-fp`／`world-fp-ctrl` 在這 27 列裡（`quit()` 不帶碼），
**但它們的 expect 釘的是指紋雜湊** ⇒ 就算 rc 恆 0，grep 那一關仍然擋得住。
⇒ 這正是你說的：**危險的不是 27，也不是 18，是交集。**

# 五、原料落地

```
exit／quit 全 73 列原料：
  C:/Users/I12/AppData/Local/Temp/claude/A--GDS-demo/440df8b3-945b-4cc6-bd63-9750aeb25aee/scratchpad/rc-inventory.txt
  14,561 bytes（我自己開過）
四欄原料（前一封那份）：同目錄 gate-raw4.txt
```

Co-Authored-By: Claude Opus 5 (1M context) <noreply@anthropic.com>
