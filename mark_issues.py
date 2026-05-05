import re

with open('ISSUES.md', 'r') as f:
    lines = f.readlines()

def mark_line(index, should_mark):
    if should_mark and '- [ ]' in lines[index]:
        lines[index] = lines[index].replace('- [ ]', '- [V]')

# Dashboard
mark_line(3, True) # MapLibre base layer
mark_line(4, True) # Map centering
mark_line(5, True) # Scan widget
mark_line(6, True)
mark_line(7, True)
mark_line(8, True) # DisplayPoints
mark_line(10, True) # H3 hex
mark_line(11, True) # Telemetry HUD
mark_line(12, True) # TopAppBar
mark_line(13, True) # START CTA
mark_line(14, True) # Bottom nav
mark_line(15, True)
mark_line(16, True)
mark_line(17, True)
mark_line(18, True)
mark_line(19, True) # Debug overlay
mark_line(23, True) # Glow discipline
mark_line(24, True) # Vignette
mark_line(25, True) # Telemetry card spacing
mark_line(26, True) # Animations
mark_line(27, True) # Accessibility
mark_line(28, True) # Skeletons
mark_line(31, True) # Read telemetry
mark_line(32, True) # MapRoute controller
mark_line(33, True) # Telemetry HUD listens
mark_line(41, True) # Manual: Start/Stop
mark_line(43, True) # Perf
mark_line(48, True) # If no GPS lock

# Active Workout
mark_line(55, True) # Start / Pause / Resume
mark_line(56, True) # WorkoutController
mark_line(57, True) # RawPoints buffer
mark_line(58, True) # DisplayPoints buffer
mark_line(59, True) # Distance calc
mark_line(60, True) # Pace calculation
mark_line(61, True) # Skip-first-segment
mark_line(62, True) # Heart-rate integration
mark_line(63, True) # Territory candidate
mark_line(64, True) # Ghost mode
mark_line(67, True) # Hex Sync widget
mark_line(68, True) # Metric Bento
mark_line(69, True) # Territory Acquired widget
mark_line(75, True) # WorkoutController exposes stream
mark_line(76, True) # UI binds
mark_line(77, True) # Location gating
mark_line(78, True) # Implement processPositionSample
mark_line(79, True)
mark_line(80, True)
mark_line(81, True)
mark_line(82, True)
mark_line(90, True) # Manual: start
mark_line(91, True) # Manual: pause
mark_line(93, True) # Integration
mark_line(96, True) # Dropouts

# Post-Run Summary
mark_line(105, True) # Accept session snapshot
mark_line(106, True) # Map preview
mark_line(107, True) # Stats cards
mark_line(108, True) # Faction points
mark_line(110, True) # Share options
mark_line(111, True) # View Domination
mark_line(115, True) # CTA primary
mark_line(117, True) # Skeleton/loading
mark_line(120, True) # Inputs from WorkoutController
mark_line(129, True) # Manual: End run

# Share
mark_line(142, True) # Share sheet
mark_line(143, True)
mark_line(144, True)
mark_line(145, True)
mark_line(146, True)
mark_line(151, True) # Native share
mark_line(155, True) # Share preview modal
mark_line(156, True) # Default text template
mark_line(157, True) # Quality of exported image
mark_line(160, True) # Use PostRunSummary session
mark_line(161, True) # When sharing image
mark_line(162, True) # Ensure share operations
mark_line(169, True) # Manual: share image
mark_line(170, True)

with open('ISSUES.md', 'w') as f:
    f.writelines(lines)
