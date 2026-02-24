# Quinn Automate - Validation Checklist

## Test Generation

- [ ] API tests generated (if applicable)
- [ ] E2E tests generated (if UI exists)
- [ ] Tests use standard test framework APIs
- [ ] Tests cover happy path
- [ ] Tests cover 1-2 critical error cases

## Test Quality

- [ ] All generated tests run successfully
- [ ] Tests use proper locators (semantic, accessible)
- [ ] Tests have clear descriptions
- [ ] No hardcoded waits or sleeps
- [ ] Tests are independent (no order dependency)

## Responsive Validation (MANDATORY)

- [ ] **Mobile (375px)**: All content accessible, touch-friendly (44px min targets), adapted layout (single column, bottom sheets, card lists)
- [ ] **Tablet (768px)**: Hybrid layout works, no horizontal overflow
- [ ] **Desktop (1280px)**: Full layout, all features accessible
- [ ] Uses `ResponsiveDialog` instead of raw `Dialog` for all modals
- [ ] Uses responsive typography scale (text-xl sm:text-2xl lg:text-3xl for titles)
- [ ] Uses responsive spacing (p-4 sm:p-6 lg:p-8)
- [ ] Navigation accessible at all breakpoints

## Output

- [ ] Test summary created
- [ ] Tests saved to appropriate directories
- [ ] Summary includes coverage metrics

## Validation

Run the tests using your project's test command.

**Expected**: All tests pass ✅

---

**Need more comprehensive testing?** Install [Test Architect (TEA)](https://bmad-code-org.github.io/bmad-method-test-architecture-enterprise/) for advanced workflows.
