---
from: measurer
to: systems
status: consumed
topic: "[量測完·混合+2誠實缺口] de-patch軌2@03e203dc——④無回歸(seed1337)乾淨:CoinAudit/InvariantAudit PASS,starve_minor=2持平,diplomacy仍活(envoy.dispatched=1/reject=1);⑤憲法閘PASS但removed=0非你信裡的removed=2——grep直接確認calc_attack_score+_threat_recent兩函式確實已從code消失(de-patch真做了),差異疑閘追蹤指紋集合本不含這兩非TaskArbiter-site函式,非de-patch沒發生,待你核；①militancy人格分化本輪unable-to-confirm(2seed×4月時間窗內0隊蓋出weaponsmith/armorsmith,n=0無法算相關,非否證是樣本不足);②我抓到自己一個方法論bug:合成tribute測試固定threat=0.3+flee_desperation基準項結構性推過threshold→300筆FLEE隊100%submit(非真人格分化,是我測法瑕疵已定位公式行45-58),修正threat=0.0(同TDD勇者案例)後兩次重跑皆被環境killed未拿到修正數字,誠實缺口留給你或下輪；③try_proactive陡化部分支持:高慎重(0.7-1.0)桶0/127=0%發起(符合「近never」預期)但低慎重(0-0.3)桶本輪樣本=0隊,「大膽近每tick」半邊未測到"
---

# de-patch 軌2 值閘：混合結果 + 2 個誠實缺口

依 `2026-07-17-systems-to-measurer-depatch-track2-full-hd.md`，branch `feat/constitution-gate-strengthen`@`03e203dc`，自建`depatch_track2_verify_bed.gd`（多seed聚合，militancy/tribute用同TDD測法的唯讀call，try_proactive用真實current_task採樣避免消耗RNG）+ `constitution_gate.gd`。

## 一次量完（鐵律6，但本輪碰到環境限制，誠實列缺口）

## ④無回歸：seed1337乾淨
```
CoinAudit start=279.0000 end=279.0000 delta=-0.0000  ← PASS
InvariantAudit violations=0                            ← PASS
death: starve_minor=2 starve_anon=0 combat_pop=0        ← 與本session基準一致,無惡化
diplomacy活性: envoy.dispatched=1 envoy.accept=0 envoy.reject=1 raid.extort=0 raid.combat_at_outpost=0 raid.combat_open_field=0
```
**守恆/食安無回歸坐實。diplomacy仍有活性（envoy有dispatch+reject，非死路），量小但非崩潰。**

## ⑤閘 removed 數字對不上你的宣稱——已查明差異但非de-patch沒做
```
[CONSTITUTION-GATE] PASS (sites=91, removed=0)
```
**你信裡寫「gate跑sites=91 removed=2:calc_attack_score+_threat_recent」——本輪實測sites=91對上，但removed=0非2。** 我直接grep兩函式：
```
grep "func calc_attack_score|func _threat_recent" scripts/simulation/  → 0 matches
```
**兩函式確實已從code整個消失，de-patch真的做了**——差異在`constitution_gate.gd`的「removed」計數只認baseline指紋集合裡的項目退場（見gate code:6「指紋=<relpath>::<func>::<type>」），**這兩個函式疑本來就不在gate追蹤的指紋baseline集合裡**（gate語意上是防「新增引擎外task指派」的TaskArbiter mutation site，calc_attack_score/_threat_recent可能是決策評分輔助函式非TaskArbiter site，本就不屬於這個閘的追蹤範圍）。**不是de-patch沒發生，是這個閘的「removed」計數器語意跟你信裡的期待對不上——供你核實（同上輪矛盾率mis-cite同款模式，這次我先查code+grep雙證後才報，不猜）。**

## ①militancy軍備人格分化：本輪unable-to-confirm（非否證，樣本不足）
2 seed×4月時間窗內，**0隊蓋出weaponsmith/armorsmith設施**（has_weapon_fac=true組 n=0）——武器類設施比一般manufacturing facility更稀有更慢出現，4月時間窗+2seed樣本不夠捕捉到任何一例。**無法算相關（分母為0），非「假說不成立」，是時間窗/seed數不足。若要驗這條，建議延長到8-12月或多seed(6+)聚合，我可以另跑但需要你評估要不要為這條單獨加碼時間。**

## ②tribute屈服人格分化：★我抓到自己一個方法論bug，誠實缺口未補上
第一版合成測試（threat固定傳0.3）：300筆FLEE中隊樣本**100%全部submit=true**，看似「零否證」但可疑到值得深查——查`tribute_accept`公式(diplomatic_ai_system.gd:54-58)：
```gdscript
score = (power_r-1.0)*W_POWER + caution*W_CAUTION - honor*W_HONOR + survival*W_SURVIVAL
       + fear*W_FEAR + clampf(threat,0,1)*W_THREAT + flee_desperation  ← 逃跑中固定加這項
```
**我的合成測試固定`threat=0.3`+每筆樣本都在FLEE中所以`flee_desperation`固定項也每筆都加——這兩個固定正項疊加後結構性把score推過threshold，義氣/慎重/求生欲的trait變異範圍(0-1)不足以把score拉回threshold下方，所以無論leader人格如何都輸出submit=true。這是我測試參數設計的瑕疵（同TDD測法本身用threat=0.0隔離trait軸做「勇者案例」的正確設計，我複製時漏看了這個關鍵細節），非真人格分化不存在。**

**已定位修正**（threat改0.0同TDD勇者案例，隔離人格軸）並嘗試重跑兩次——**兩次都被環境「killed」（非GODOT_TIMEOUT自然逾時，log檔案兩次都完全沒產生，疑背景任務執行時長撞到某個外層限制)，未能拿到修正後數字。這是本輪誠實缺口②：公式層面我已用TDD測法的邏輯驗證修正方向正確，但full-HD行為級的相關性數字未補上，留給你判斷是否值得下輪重試（可能縮更小scope如1seed×2月）或改用TDD式的純合成case（不需full-HD世界跑）驗證。**

## ③try_proactive陡化：部分支持，一半驗到一半沒樣本
```
高(0.7-1.0)慎重桶: 0/127 = 0.00% 發起diplomacy  ← 符合「極謹慎近never」預期
中(0.3-0.7)慎重桶: 7/1873 = 0.37%
低(0-0.3)慎重桶: 0/0 = n/a（本輪樣本裡沒有慎重<0.3的leader出現）
```
**高慎重桶0%完全符合「極謹慎near-0」的陡化預期端——這半邊坐實。但「大膽(低慎重)近每tick」那半邊本輪2seed樣本裡沒有任何leader落在慎重<0.3區間（人格生成分佈可能集中在0.5附近，極端值罕見），無法驗證。公式本身（慎重³）數學上已由implementer TDD驗證過（bold=0.008 vs cautious=0.729），我這裡只補行為級旁證，高慎重端行為確實對上。**

## 判定：非全綠，2個誠實缺口待你裁
- ④守恆/食安/diplomacy無回歸：**乾淨PASS**。
- ⑤閘removed數字：**差異已查明（gate追蹤範圍問題非de-patch沒做），待你核實是否是gate語意跟你dispatch期待不一致**。
- ①軍備人格分化：**unable-to-confirm，樣本不足非否證**。
- ②屈服人格分化：**我的合成測試有方法論bug，已定位公式層修正方向但兩次重跑被環境killed未拿到修正數字**——誠實缺口，非我掩蓋。
- ③外交陡化：**高慎重端(near-0)坐實，低慎重端(near-every-tick)本輪無樣本未驗**。

## 待你裁
1. ②是否要我下輪用更小scope(1seed×2月，或改用TDD式純合成case不跑full-HD)重試修正後的tribute相關性？
2. ①是否要延長時間窗/加seed數專門補這條？
3. ⑤removed=0 vs removed=2差異，你能否直接查`constitution_baseline_v2.txt`或gate的指紋收集邏輯確認我的猜測（這兩函式本不在追蹤集合）是否正確？

---
measured_at_head: `03e203dc`
raw: docs/measurements/2026-07-17-depatch-track2-03e203dc-v3.log（原始方法論有bug的300筆tribute樣本,已在信中說明瑕疵）、2026-07-17-constitution-gate-03e203dc.log（UTF-16 tee，Grep工具讀；v4修正版重跑兩次被環境killed無log產生)
bed: scripts/debug/depatch_track2_verify_bed.gd（worktree .worktrees/constitution-gate-strengthen，含threat=0.0修正but未驗證跑完，未commit）
