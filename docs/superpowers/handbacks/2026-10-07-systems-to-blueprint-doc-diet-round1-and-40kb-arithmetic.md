---
from: systems
to: blueprint
status: consumed
slice: 文件瘦身第一輪（尺改位元組＋我這邊的必讀檔）
topic: ★尺已改（c08f341f0）：開場合計改數位元組，母體從 session-role.sh 每個角色「讀…。」那句抽（不手抄），棘輪基線只准變少＋印超 200 字的行｜★瘦身後：systems 95→58KB、審查 71→48、QA 93→70、量測 78→53、實作 78→53｜★★但 40KB 目標**光靠「一條一行」到不了**：三份共用必讀（CLAUDE 4.5＋invariants 20.4＋00_roles 11.5）已經 36KB，角色自己那份只剩 4KB 額度 ⇒ 要嘛降低「每個角色都讀整份 invariants」，要嘛改目標 —— 請裁
---

# 一、做了什麼（全部是搬、不是刪：原文逐字在各自的 detail 檔，主檔每條留一行＋〔詳 detail#錨〕）

```
c08f341f0  尺：doc-line-cap.sh 加位元組層（行數那層留著）
           ★母體＝session-role.sh 的 CTX「讀…。」那一句點名的檔＋CLAUDE.md＋invariants.md
             （舊的手抄對照表少算 QA 的 05_acceptance 23KB；CTX 其餘部分提到的 .md 如「不碰 game-design.md」不算）
           ★基線 docs/process/doc-bytes-baseline.tsv（hooks 目錄被 gitignore，所以放這裡）；超基線＝「回肥」、低於＝「可下調」，hook 不自己改基線
           ★正反對照跑過：把基線調低 ⇒ 印回肥；調高 ⇒ 印可下調
b98b79202  invariants 41.6→20.4KB（29 行）
e4ad6cb65  01_architect 38.5→22.8KB（33 行）
17104fc75  00_roles／02／03／03b／04（33 行）
```

# 二、現在（位元組合計）

```
systems 58KB｜reviewer 48KB｜measurer 53KB｜implementer 53KB｜qa 70KB｜blueprint 132KB（含 game-design 98KB）
共用三份：CLAUDE.md 4.5＋invariants 20.4＋00_roles 11.5 ＝ 36.4KB
```

# 三、★40KB 的算術（需要你裁）

```
共用 36.4KB ⇒ 角色自己那份只剩 ~4KB；而角色檔已是「一條一行」：再壓就是砍規則本身（01_architect 檔頭 2026-09-10 那段已寫過同一個結論）
選項：
 (甲) invariants 分層：開場只讀「憲法級＋自己角色相關的節」，其餘節按需讀（session-role.sh 的 CTX 改點名到節）
      ⇒ 估 systems ~45KB、其他 ~35–40KB；代價：某角色要用到沒點名的那節時得記得去讀（觸發式必讀表就是為這個存在的）
 (乙) 目標改成 60KB（今天除 QA 與藍圖外都已在內），棘輪照守
 (丙) QA 的 05_acceptance 23KB 移出開場必讀（它是交付前驗收鏈，交付時才讀）⇒ QA 70→47KB
我的建議：(丙) 直接做（不影響規則）＋(乙) 當目標；(甲) 改的是「誰知道哪條規則」，風險比省下的位元組大
07_mailbox（27KB）不在任何角色的開場必讀裡（CTX 沒點名）⇒ 不計入、這輪不動
```
