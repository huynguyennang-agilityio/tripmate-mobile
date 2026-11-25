# MF1 Mobile skeleton and CI -- Round 2 Notes

**Card:** MF1, [tasks/EPIC-11.md](../EPIC-11.md#mf1)\
**Pull request:** https://github.com/huynguyennang-agilityio/tripmate-mobile/pull/1\
**Round 2:** since `343861b`, head `0921914`

The findings of the second diff review round that are not defects
([development-flow.md](https://github.com/huynguyennang-agilityio/tripmate-docs/blob/main/docs/development-flow.md),
section 2.4). The Decision column stays empty until the epic closes.

Round 2 also found one defect, R2-1: the checks `Analyze`, `Test`, and
`Android build` are not yet required on `main`, so MF1-1 is not met. It
is closed by the product owner's branch protection change, not by a
note.

| Note | Level | Proposed fix | Priority | Decision |
|------|-------|--------------|----------|----------|
| R2-2 (from R1-2): `CLAUDE.md:266` says "the branch must be up to date with `main`", but the branch protection of `main` has no required status checks, so `strict` is not enforced and later sessions would assume a guard that is not there | Repository | Turn on "Require branches to be up to date before merging" when the required checks `Analyze`, `Test`, `Android build` are added (R2-1); if the product owner decides against it, change the line to "`main` is protected: every change goes through a pull request" | Low | |
