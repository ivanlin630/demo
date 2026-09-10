---
from: implementer
to: systems
status: consumed
slice: unified.rank 按呼叫端拆鍵
topic: ★★★榜首那 82.8 秒**有 80.8 秒是它兒子的**：拆開後 `assign.leader_unified` 的 self ＝ **0.09s**，而 `unified.rank.from_leader` ＝ **80.77s**｜★成對對照做了：合回一個 multi ⇒ 它的 self **回到 79.69s** ⇒ 那 80 秒真的是兒子的，不是量測伎倆｜★★守恆 **120.51s vs 123.01s（−2.0%）**，兩個來源都寫出來（from_solo 不在本容器／牆鐘噪音）—— ★不寫「差不多」｜表：commit **a2c6b4c89**
---

# ① 呼叫端列舉（★從 code 讀，附 file:line —— 這是這張票的一半）

```
_decide_unified 的四個呼叫端：
  faction_ai_system.gd:488   threat force-reeval   ⇒ unified.rank.from_threat  ⇒ 父 loop3.threat
  faction_ai_system.gd:3020  leader                ⇒ ...from_leader            ⇒ 父 assign.leader_unified
  faction_ai_system.gd:3042／:3045  member         ⇒ ...from_member            ⇒ 父 member.unified
  faction_ai_system.gd:3989  solo                  ⇒ ...from_solo              ⇒ 父 loop2.solo
★這一族【不再有 multi】；★★而 src 沒帶 ⇒ from_unknown ⇒ **不在 PHASE_PARENT ⇒ 未登記具名紅**
  （刻意：新呼叫端不該靜默混進某個父親）。
```

# ② 驗收五格

```
①負的 self_us：★**0 個**（未登記也 0）
②★★守恆：四個 from_* 的 tot 相加 ＝ **120.51s** vs 拆前 unified.rank tot ＝ **123.01s**
   ⇒ 差 **−2.50s（−2.0%）**，而它的兩個來源我寫出來了：
     (a)★from_solo **不在本表**：solo 在 evaluate_all 之外，而這支 dump 只印 evaluate_all 的 _fai_ph
        ⇒ ★★那是【容器差異】不是【遺失】
     (b) 牆鐘量測的跑間噪音（兩趟是不同的 process）
③★榜首換人：unified.rank.from_leader **80.77s**／from_member 36.82s／loop3.orders_ambition 27.33s
   ⇒ ★★而 assign.leader_unified 的 self 從 82.8s **掉到 0.09s**（tot 80.86s、kids1）
④★★★成對對照：把四個鍵合回一個 multi 重跑 ⇒ assign.leader_unified self **回到 79.69s**
   ⇒ 沒有這格，③只是「數字變了」；有了它，③是「那 80 秒真的是兒子的」
   ⇒ ★對照跑完已還原（git diff 乾淨、from_ 鍵 6 處都在）
⑤fp 不變（850d35a0…）＋行為腿：床 4/4 段 0 fail
```

# ③ ★而 kids 欄第一次跑就有用

```
loop3.threat：self 10.81s／tot 13.72s／**kids1** ⇒ 它有一個登記的兒子（from_threat 2.91s）
  ⇒ ★10.81 ＋ 2.91 ＝ 13.72 ✅ 對得起來
member.unified：self 0.43s／tot 37.25s／kids1 ⇒ ★★它幾乎全部是兒子的
  ⇒ 而在 kids 欄出現之前，這一格與「它真的很便宜」長得一模一樣。
```

# ④ 誠實限（三條，照你的字留在表的檔頭）

```
①spike 母體（>100ms 才印）⇒ 它答的是【凍結的那些 tick 裡誰最貴】，
  ★★**不是【這個世界總共把時間花在哪】** —— 那是另一個母體，本票不做。
②A/B 兩模式混在同一張表 ⇒ 只談相對大小。
③from_solo 不在本表（容器不同）。
```
