Act as a code reviewer for the runner R package. Review the recent changes with these priorities:

## Linked Issue (check first)
- Every PR must reference a linked issue (e.g. "Closes #123", "Fixes #45", or a GitHub linked issue)
- If no issue is linked, **reject the PR immediately** with a comment requesting the author to create an issue first and link it
- Do NOT proceed with the rest of the review until an issue is linked

## CRAN Compliance
- No `browser()`, `debug()`, or `debugonce()` calls left in code
- No `cat()` or `print()` without `verbose` / `quiet` argument gating
- No absolute file paths or platform-specific assumptions
- No installed.packages() usage

## Backward Compatibility
- Check that existing exported function signatures are not broken
- Verify default argument values are preserved
- Flag any changes to return types or class attributes

## Documentation
- Every exported function has `@export` and complete `@param` / `@return` tags
- Examples are present and correct
- NEWS.md entry exists for user-visible changes
- DESCRIPTION version is bumped if needed

## Tests
- New or changed functionality has corresponding tests
- Edge cases are covered (empty input, NA, single element, zero-length window)
- Tests do not depend on external resources or specific locale
- Test coverage should never be lower than the current one

## Issue Alignment
- Read the linked issue carefully and verify the implementation actually addresses what was requested
- Check that the scope of changes matches the issue — no unrelated changes bundled in
- If the implementation deviates from or only partially addresses the issue, flag it as a **blocker**

Summarize findings with severity: **blocker**, **should fix**, or **nit**.

## Escalation
If you are blocked or unable to complete the review (e.g. cannot determine backward compatibility, unclear CRAN policy implications):
- Tag the maintainer @gogonzo in your review comment asking for guidance
- Clearly explain what you're unsure about and what decision is needed
