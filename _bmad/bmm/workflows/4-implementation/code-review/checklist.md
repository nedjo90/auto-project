# Senior Developer Review - Validation Checklist

- [ ] Story file loaded from `{{story_path}}`
- [ ] Story Status verified as reviewable (review)
- [ ] Epic and Story IDs resolved ({{epic_num}}.{{story_num}})
- [ ] Story Context located or warning recorded
- [ ] Epic Tech Spec located or warning recorded
- [ ] Architecture/standards docs loaded (as available)
- [ ] Tech stack detected and documented
- [ ] MCP doc search performed (or web fallback) and references captured
- [ ] Acceptance Criteria cross-checked against implementation
- [ ] File List reviewed and validated for completeness
- [ ] Tests identified and mapped to ACs; gaps noted
- [ ] Code quality review performed on changed files
- [ ] Security review performed on changed files and dependencies
- [ ] Responsive validation performed on UI changes:
  - [ ] **Mobile (375px)**: All content accessible, touch-friendly (44px min targets), adapted layout (single column, bottom sheets, card lists)
  - [ ] **Tablet (768px)**: Hybrid layout works, no horizontal overflow
  - [ ] **Desktop (1280px)**: Full layout, all features accessible
  - [ ] Uses `ResponsiveDialog` instead of raw `Dialog` for all modals
  - [ ] Uses responsive typography scale (text-xl sm:text-2xl lg:text-3xl for titles)
  - [ ] Uses responsive spacing (p-4 sm:p-6 lg:p-8)
  - [ ] Navigation accessible at all breakpoints
- [ ] Outcome decided (Approve/Changes Requested/Blocked)
- [ ] Review notes appended under "Senior Developer Review (AI)"
- [ ] Change Log updated with review entry
- [ ] Status updated according to settings (if enabled)
- [ ] Sprint status synced (if sprint tracking enabled)
- [ ] Story saved successfully

_Reviewer: {{user_name}} on {{date}}_
