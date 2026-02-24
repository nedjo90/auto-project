---
stepsCompleted: []
inputDocuments: []
---

# {{project_name}} - Epic Breakdown

## Overview

This document provides the complete epic and story breakdown for {{project_name}}, decomposing the requirements from the PRD, UX Design if it exists, and Architecture requirements into implementable stories.

## Requirements Inventory

### Functional Requirements

{{fr_list}}

### NonFunctional Requirements

{{nfr_list}}

### Additional Requirements

{{additional_requirements}}

### FR Coverage Map

{{requirements_coverage_map}}

## Epic List

{{epics_list}}

<!-- Repeat for each epic in epics_list (N = 1, 2, 3...) -->

## Epic {{N}}: {{epic_title_N}}

{{epic_goal_N}}

<!-- Repeat for each story (M = 1, 2, 3...) within epic N -->

### Story {{N}}.{{M}}: {{story_title_N_M}}

As a {{user_type}},
I want {{capability}},
So that {{value_benefit}}.

**Acceptance Criteria:**

<!-- for each AC on this story -->

**Given** {{precondition}}
**When** {{action}}
**Then** {{expected_outcome}}
**And** {{additional_criteria}}

**Responsive Validation (MANDATORY for UI stories):**
- [ ] **Mobile (375px)**: All content accessible, touch-friendly (44px min targets), adapted layout (single column, bottom sheets, card lists)
- [ ] **Tablet (768px)**: Hybrid layout works, no horizontal overflow
- [ ] **Desktop (1280px)**: Full layout, all features accessible
- [ ] Uses `ResponsiveDialog` instead of raw `Dialog` for all modals
- [ ] Uses responsive typography scale (text-xl sm:text-2xl lg:text-3xl for titles)
- [ ] Uses responsive spacing (p-4 sm:p-6 lg:p-8)
- [ ] Navigation accessible at all breakpoints

<!-- End story repeat -->
