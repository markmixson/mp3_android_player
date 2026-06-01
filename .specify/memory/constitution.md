# mp3 to haptic player Constitution
<!-- SPECKIT START -->
For additional context about technologies to be used, project structure,
shell commands, and other important information, read the current plan
at /home/vbms/vscode/mp3/specs/001-mp3-player-android/plan.md
<!-- SPECKIT END -->

## Core Principles

### Test-Driven Development
Tests should be built first before implementations.

### Comprehensive Test Coverage
Tests are always generated to cover all lines and branches.  Tests are never optional.  They are always required for every line and every branch.

### Abstraction-First Design
If at all possible, all functionality should be disconnected by at least one layer of abstraction.

### Immutable Data Structures
All data structures should be immutable unless impractical or due to performance concerns.

### Final Method Parameters
All method parameters should be marked as final when practical.

### Parameterized Testing
All tests should be parameterized whenever possible.

### Stream-Oriented Processing
Except in situations where pipelining is inefficient, stream concepts should be used.

### Asynchronous Preference
Generally asynchronous operations should be preferred to synchronous.

## Governance

The constitution's changes will not automatically rewrite existing code. Amendments require documentation in a Sync Impact Report.

**Version**: 1.0.0 | **Ratified**: 2026-05-17 | **Last Amended**: 2026-05-20
