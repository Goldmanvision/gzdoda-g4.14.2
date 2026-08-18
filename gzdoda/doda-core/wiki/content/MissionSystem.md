# Mission System

## Overview
The mission system handles mission state, progression, and objective management.

## Key Components
- `DoDAMissionManager`: Tracks `MissionResult`, `MissionIndex`, `MissionPercentComplete`, `MissionPhase`, and mission metadata.
- `DoDAMissionState` / `DoDACampaignState`: Manages the state of the current mission and campaign.
- `EvidenceLedger`: Tracks evidence gathered during missions.
- `MissionDirector`: Orchestrates mission flow and objectives.
- `MissionInteractable` / `MissionTerminal` / `ExtractionInteractable`: Specific interactable actors for mission tasks.

## Objectives and Markers
- `MissionIds` / `ObjectiveIds`: Define IDs for missions and objectives.
- `MissionPickup`: Handles objective item pickups.
- `DebugTrigger`: Used for debugging mission triggers.
