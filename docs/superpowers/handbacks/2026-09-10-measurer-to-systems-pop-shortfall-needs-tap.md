---
from: measurer
to: systems
status: consumed
slice: 派工失敗「pop不足」(人口軸)
topic: ★開跑前查完:材料軸(faction_ai_system.gd:4722-4727)有bump_sample逐筆detail,人口軸(同檔4741-4746)只有聚合counter funnel.build_gate.pop/dispatch_fail.pop不足,沒有逐筆缺口/隊id/tick——這正是票面說的「材料軸修過人口軸沒查過」的字面意思。我不能自己補(scripts/simulation不歸我改)，需implementer照材料軸同款式補一個bump_sample｜★★順帶抓到一個會吃掉③訊號的東西:print本身有de-dup(同reason連續不重印)，若同一支隊反覆撞同一個「10<12」,只會印一次,不補tap連raw log都看不出反覆撞的次數
---

# 查完的結論（跑之前先報，不要空跑一輪）

```
①母體(次數)：dispatch_fail.pop不足 / funnel.build_gate.pop 兩個聚合counter
  已存在(faction_ai_system.gd:4745/4649)，這個【可以】直接讀，不需要tap
②③缺口大小分布+逐隊重撞次數：★★★沒有tap——faction_ai_system.gd:4741-4746
  只有Probe.bump("funnel.build_gate.pop")，沒有像材料軸那樣(:4722-4727)
  的Probe.bump_sample帶逐筆{team,need,avail,tick}
④三軸(tick/天/規模)：純讀state.world.current_tick+state.teams.size()，不需要tap
```

# ★★順帶一個會吃掉③訊號的東西

```
_log_dispatch_fail(faction_ai_system.gd:4650-4653)有de-dup：
  if _last_dispatch_fail.get(faction_id,"")==reason: return（不print）
⇒ 若同一支隊反覆撞同一個「pop 不足: 10 < 12」(reason字串完全一樣)，
  只有第一次會印進log——raw log本身看不出【反覆撞同一道門檻】這件事，
  ★但Probe.bump("dispatch_fail."+_cat)是fire在de-dup之前的(注釋已標明
  「真實觸發率非只變化次數」)⇒ 聚合次數是準的，只是拿不到「哪支隊撞了幾次」
  這個逐隊拆解——這正需要③要的那個tap。
```

# 建議的tap形狀（給implementer抄材料軸那段，不是我自己動手）

```
faction_ai_system.gd:4741-4746附近，照4722-4727同款式加：
  if Probe.enabled:
    Probe.bump_sample("dispatch_fail.pop_detail", {"team": leader_team.team_id,
      "have": leader_team.population, "need": pop * 2,
      "short": pop * 2 - leader_team.population, "tick": state.world.current_tick}, 30)
理由同材料軸：單一寫入點，不外掛三處各自猜格式。
```

# 我這邊已備妥

①④已經想清楚怎麼讀(純state/既有counter)，就差②③缺tap。跑法(窗長/seed)等tap落地後我再定。
