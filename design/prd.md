# Home Bulking Coach --- Product Requirements Document (PRD)

**Document status:** Draft v1.0\
**Product:** Home Bulking Coach\
**Platform:** Android (Flutter)\
**Primary audience:** Beginner home-workout users pursuing muscle gain\
**Product type:** Consumer fitness application\
**Document owner:** Product / Engineering\
**Last updated:** 3 November 2026

------------------------------------------------------------------------

## 1. Executive Summary

Home Bulking Coach is an Android application that helps beginners build
muscle at home using bodyweight and minimal equipment. It turns the
question *"What should I train today, and how do I do it correctly?"*
into a clear, guided experience.

The product combines personalized beginner workout plans, exercise
demonstrations using both 2D animations and video, an in-session workout
coach, workout history, and progress tracking. The first release will be
local-first: users can complete and save workouts without creating an
account or relying on an internet connection for core functionality.

The product should feel polished, motivating, trustworthy, and easy to
understand---not like a spreadsheet of exercises or a complicated gym
logging tool.

**Product promise:** *Know what to train. Learn how to do it. See your
progress.*

## 2. Product Vision

Become the most approachable home muscle-building companion for
beginners who want structured, understandable, and sustainable training
without needing a gym.

### 2.1 Product principles

1.  **Clarity over complexity:** show the next useful action, not every
    possible metric.
2.  **Coach the user:** explain exercises, sets, reps, rest, and
    progression in plain language.
3.  **Progress safely:** encourage gradual progression rather than
    arbitrary increases.
4.  **Make consistency achievable:** support realistic schedules and
    recovery days.
5.  **Work offline:** core workout flows must not depend on a network
    connection.
6.  **Respect the user:** no shame-based messaging, unrealistic body
    promises, or manipulative streak mechanics.
7.  **Premium feel, practical scope:** a cohesive visual system and
    responsive interactions matter as much as feature count.

## 3. Problem Statement

Beginner home-workout users commonly face five problems:

-   They do not know which exercises to do or how to arrange them into a
    weekly routine.
-   They are unsure how to perform movements with correct technique.
-   They struggle to understand sets, reps, rest periods, and when to
    progress.
-   They lose track of completed workouts and performance over time.
-   Many fitness apps overwhelm beginners with advanced metrics,
    gym-centric programs, or too many choices.

Home Bulking Coach addresses these problems with a guided plan, clear
exercise education, a focused workout session experience, and simple
progress feedback.

## 4. Goals and Non-Goals

### 4.1 MVP goals

-   Help a beginner complete onboarding and receive a suitable starter
    plan.
-   Make the next scheduled workout obvious from the Home screen.
-   Provide clear instructions and media for every exercise included in
    the MVP programs.
-   Let users complete, pause, resume, skip, or end a workout.
-   Persist workout progress locally, including recovery after app
    interruption.
-   Save completed and incomplete workout sessions with clear status.
-   Show useful workout consistency and performance history.
-   Support core workout functionality offline.
-   Establish a high-quality, accessible, consistent Android experience.

### 4.2 Non-goals for MVP

-   Social feed, followers, likes, or public workout sharing.
-   Live coaching, video calls, or real-time form analysis.
-   AI-generated workout plans.
-   Meal logging, barcode scanning, or full nutrition coaching.
-   Wearable integrations and smartwatch applications.
-   Paid subscriptions, advertising, or in-app purchases.
-   Cloud account synchronization and multi-device backup.
-   Medical diagnosis, rehabilitation, or treatment recommendations.

These may be considered after validating the core workout experience.

## 5. Target Users

### Primary persona: Beginner Home Builder

-   Wants to gain muscle and become stronger.
-   Has little or inconsistent gym experience.
-   Trains at home with bodyweight and/or simple equipment.
-   Needs clear, visual instructions and a realistic routine.
-   May not understand common fitness terminology.
-   Wants visible evidence of consistency and improvement.

### Secondary persona: Returning exerciser

-   Has trained before but has lost consistency.
-   Wants a simple routine to restart at home.
-   Benefits from adjustable difficulty and session history.

### Initial supported equipment

-   Bodyweight only
-   Dumbbells
-   Resistance bands
-   Exercise mat
-   Pull-up bar

Users may select multiple equipment types. Programs must not prescribe
equipment the user has not selected unless an explicit bodyweight or
alternative variation is provided.

## 6. Product Positioning and Differentiation

**Positioning:** A beginner-first home muscle-building coach---not a
general-purpose gym tracker.

Differentiators:

1.  Beginner-friendly language and exercise explanations.
2.  Dual exercise guidance: lightweight 2D animation plus video
    demonstration.
3.  Workout flow designed around the user's attention: one exercise, one
    clear next action.
4.  Offline-first workout execution and local history.
5.  Progression suggestions based on recorded performance, with user
    control.
6.  Programs designed for minimal equipment and realistic home
    schedules.

## 7. Platform and Technical Direction

  -----------------------------------------------------------------------
  Area                                MVP direction
  ----------------------------------- -----------------------------------
  Platform                            Android

  Framework                           Flutter

  Language                            Dart

  State management                    Provider

  Navigation                          GoRouter

  Local persistence                   SQLite/Drift or an agreed
                                      equivalent

  Charts                              fl_chart or equivalent

  Notifications                       Local notifications

  Media                               Bundled/local assets where
                                      practical; cached remote media
                                      where needed

  Architecture                        Feature-oriented, repository-based,
                                      local-first
  -----------------------------------------------------------------------

### 7.1 Architectural principles

-   Keep UI, domain logic, and persistence concerns separate.
-   Treat exercise and program content as versioned product data.
-   Store user profile, plan configuration, active session, completed
    sessions, and measurements locally.
-   Make workout execution resilient to app backgrounding, process
    termination, and device rotation.
-   Do not require authentication for core MVP functionality.
-   Design repository boundaries so optional cloud sync can be added
    later without rewriting workout logic.
-   Do not store secrets or private API keys in the mobile application.

## 8. Information Architecture

Bottom navigation has four primary destinations:

1.  **Home:** today's workout, weekly schedule, quick progress, and
    recovery-day guidance.
2.  **Plans:** assigned program, available programs, and exercise
    library.
3.  **Progress:** workout consistency, workout history, body
    measurements, and exercise performance.
4.  **Profile:** personal details, goal, experience, equipment,
    schedule, units, notifications, privacy, and data controls.

Secondary screens are reached from these destinations rather than adding
more bottom-navigation items.

## 9. Core User Journeys

### 9.1 First-time setup

Welcome → Personal information → Goal → Experience level → Equipment →
Weekly schedule and session duration → Plan preview → Home.

Requirements: - Show onboarding progress. - Explain why each requested
field is needed. - Validate age, height, and weight ranges without
shaming language. - Allow the user to go back and edit previous
answers. - Save onboarding progress so it can be resumed. - Avoid asking
for unnecessary sensitive information. - Clearly explain that the app
provides general fitness guidance, not medical advice.

### 9.2 Start and complete a workout

Home → Today's workout → Workout overview → Exercise instructions →
Active workout → Set completion → Rest timer → Next exercise → Workout
summary → Save session → Progress.

### 9.3 Explore an exercise

Plans → Exercise library → Search/filter → Exercise detail →
Animation/video → Technique instructions → Easier variation or related
exercise.

### 9.4 Review progress

Progress → Choose time range or metric → View trend → Open workout
history or exercise performance detail.

## 10. Functional Requirements

Priority definitions: - **P0:** required for MVP launch. - **P1:**
valuable enhancement after the core flow is stable. - **P2:** future
consideration.

### 10.1 Onboarding and profile

  -----------------------------------------------------------------------
  ID                      Requirement             Priority
  ----------------------- ----------------------- -----------------------
  ONB-01                  Show a branded welcome  P0
                          screen and clear start  
                          action.                 

  ONB-02                  Collect display name,   P0
                          age, height, and        
                          current weight.         

  ONB-03                  Allow the user to       P0
                          select a fitness goal;  
                          muscle gain is the      
                          primary path.           

  ONB-04                  Allow Beginner,         P0
                          Intermediate, or        
                          Advanced experience     
                          selection; default to   
                          Beginner.               

  ONB-05                  Support multi-select    P0
                          equipment selection.    

  ONB-06                  Let the user select 3,  P0
                          4, or 5 training days   
                          per week.               

  ONB-07                  Let the user select a   P0
                          preferred session       
                          duration.               

  ONB-08                  Generate a plan preview P0
                          based on the onboarding 
                          profile and available   
                          content.                

  ONB-09                  Allow profile and       P0
                          preferences to be       
                          edited later.           

  ONB-10                  Allow onboarding to be  P0
                          resumed after app       
                          interruption.           
  -----------------------------------------------------------------------

### 10.2 Workout plans

  -----------------------------------------------------------------------
  ID                      Requirement             Priority
  ----------------------- ----------------------- -----------------------
  PLN-01                  Show the user's         P0
                          assigned weekly plan on 
                          Home.                   

  PLN-02                  Provide a plan detail   P0
                          screen with duration,   
                          level, equipment,       
                          muscle groups, and      
                          exercises.              

  PLN-03                  Include                 P0
                          beginner-appropriate    
                          starter plans for       
                          supported equipment     
                          profiles.               

  PLN-04                  Clearly identify        P0
                          training days and       
                          recovery days.          

  PLN-05                  Prevent a plan from     P0
                          requiring unavailable   
                          equipment without an    
                          alternative.            

  PLN-06                  Allow users to browse   P1
                          available plans.        

  PLN-07                  Allow users to create   P2
                          or customize a workout  
                          plan.                   
  -----------------------------------------------------------------------

### 10.3 Exercise library and guidance

  -----------------------------------------------------------------------
  ID                      Requirement             Priority
  ----------------------- ----------------------- -----------------------
  EXE-01                  Maintain structured     P0
                          exercise records with   
                          name, description,      
                          muscle groups,          
                          equipment, level, and   
                          instructions.           

  EXE-02                  Show an exercise detail P0
                          screen.                 

  EXE-03                  Provide a 2D animation  P0
                          or equivalent visual    
                          demonstration for each  
                          MVP exercise.           

  EXE-04                  Provide a video         P0
                          demonstration when      
                          available.              

  EXE-05                  Allow switching between P0
                          animation and video     
                          when both are           
                          available.              

  EXE-06                  Show setup, execution   P0
                          steps, breathing cues   
                          where relevant, and     
                          common mistakes.        

  EXE-07                  Provide an easier       P0
                          variation or safe       
                          alternative where       
                          available.              

  EXE-08                  Support search and      P1
                          muscle/equipment        
                          filters in the exercise 
                          library.                

  EXE-09                  Provide a fallback when P0
                          video cannot load.      
  -----------------------------------------------------------------------

Media content must be licensed, original, or otherwise cleared for
commercial/public app distribution. Exercise instructions should be
reviewed for accuracy before release.

### 10.4 Active workout

  -----------------------------------------------------------------------
  ID                      Requirement             Priority
  ----------------------- ----------------------- -----------------------
  WKO-01                  Start a session from    P0
                          the assigned workout.   

  WKO-02                  Show current exercise,  P0
                          position in workout,    
                          target sets, and target 
                          reps or duration.       

  WKO-03                  Allow the user to       P0
                          record actual reps and, 
                          when relevant,          
                          resistance/load.        

  WKO-04                  Allow the user to mark  P0
                          a set complete.         

  WKO-05                  Start a configurable    P0
                          rest timer after a      
                          completed set.          

  WKO-06                  Allow rest timer pause, P0
                          resume, and skip.       

  WKO-07                  Allow pause and resume  P0
                          of the workout.         

  WKO-08                  Allow an exercise to be P0
                          skipped with an         
                          explicit skipped        
                          status.                 

  WKO-09                  Confirm before ending   P0
                          or discarding an active 
                          session.                

  WKO-10                  Persist active session  P0
                          state locally and       
                          restore it after        
                          interruption.           

  WKO-11                  Keep workout timing and P0
                          set completion          
                          independent of video    
                          playback.               

  WKO-12                  Support screen wake     P1
                          behavior during active  
                          workout, subject to     
                          Android platform        
                          conventions.            
  -----------------------------------------------------------------------

### 10.5 Workout summary and history

  -----------------------------------------------------------------------
  ID                      Requirement             Priority
  ----------------------- ----------------------- -----------------------
  HIS-01                  Show total duration,    P0
                          completed exercises,    
                          completed sets, and     
                          session status.         

  HIS-02                  Save completed sessions P0
                          locally.                

  HIS-03                  Support incomplete      P0
                          sessions with clear     
                          status.                 

  HIS-04                  Show a chronological    P0
                          workout history.        

  HIS-05                  Let users open a        P1
                          session to review       
                          exercise/set details.   

  HIS-06                  Avoid presenting        P1
                          estimated calories as   
                          precise measurements.   
  -----------------------------------------------------------------------

### 10.6 Progress tracking

  -----------------------------------------------------------------------
  ID                      Requirement             Priority
  ----------------------- ----------------------- -----------------------
  PRG-01                  Show weekly and monthly P0
                          workout counts.         

  PRG-02                  Show workout history    P0
                          and completion          
                          consistency.            

  PRG-03                  Allow manual            P1
                          body-weight entries     
                          with dates.             

  PRG-04                  Display body-weight     P1
                          trend over time.        

  PRG-05                  Track performance by    P1
                          exercise, including     
                          reps and load when      
                          applicable.             

  PRG-06                  Allow optional          P2
                          circumference           
                          measurements.           

  PRG-07                  Provide useful empty    P0
                          states when the user    
                          has no history.         
  -----------------------------------------------------------------------

### 10.7 Profile, settings, and privacy

  -----------------------------------------------------------------------
  ID                      Requirement             Priority
  ----------------------- ----------------------- -----------------------
  SET-01                  Edit personal profile   P0
                          and training            
                          preferences.            

  SET-02                  Change selected         P0
                          equipment and weekly    
                          schedule.               

  SET-03                  Support metric/imperial P1
                          display preferences.    

  SET-04                  Configure workout       P1
                          reminders.              

  SET-05                  Provide privacy policy  P0
                          and terms links.        

  SET-06                  Provide a way to delete P0
                          local user data.        

  SET-07                  Clearly disclose any    P0
                          data collected or       
                          shared by the app.      
  -----------------------------------------------------------------------

## 11. Workout and Progression Logic

### 11.1 Program design

MVP programs should be authored and reviewed, not generated from
arbitrary combinations of exercises.

Initial program direction: - Three-day full-body option. - Four-day
upper/lower option. - Five-day option only if a safe, balanced beginner
program is validated.

The plan engine must consider: - Experience level. - Available
equipment. - Weekly availability. - Preferred session duration. -
Exercise substitutions. - Recovery between sessions.

A plan must not imply that more training days always produce better
results.

### 11.2 Progressive overload

The app may suggest progression based on previous sessions, but must not
automatically increase load.

Example logic: 1. Store target rep range and actual reps for each set.
2. Determine whether the user completed the prescribed work with
acceptable technique as self-reported. 3. If the user reaches the top of
the target rep range across all prescribed sets on repeated sessions,
show a conservative suggestion to increase resistance slightly or choose
a harder variation. 4. Keep the decision with the user. 5. If the user
reports pain, unusual fatigue, or difficulty, do not suggest increasing
difficulty.

Progression suggestions must be framed as general guidance, not a
guarantee of muscle growth.

### 11.3 Recovery

-   Display rest days clearly.
-   Avoid encouraging users to train the same muscle group hard on
    consecutive days by default.
-   Provide an option to reschedule a missed workout.
-   Never shame users for missing sessions.
-   Encourage stopping when experiencing sharp pain, dizziness, or
    concerning symptoms.

## 12. UX and Visual Design Requirements

### 12.1 Visual direction

-   Light theme.
-   Clean, modern, premium, energetic.
-   White/off-white surfaces with lime-green accent.
-   Dark charcoal primary text.
-   Soft neutral borders and backgrounds.
-   Clear typography and generous spacing.
-   Exercise imagery should be consistent in style and framing.

Suggested initial design tokens:

  Token                       Value
  --------------------------- -----------
  Primary                     `#B8E66B`
  Text primary                `#202820`
  Background                  `#F5F7F2`
  Border                      `#E3E9DF`
  Success surface             `#E9F5DA`
  Warning surface             `#FCE8E5`
  Font                        Inter
  Screen horizontal padding   20 dp
  Card radius                 18 dp
  Button radius               14 dp

These are starting tokens and may be refined during visual design and
accessibility testing.

### 12.2 Navigation

Four bottom-navigation destinations: - Home - Plans - Progress - Profile

Use clear selected/unselected states, accessible labels, and Android
back-navigation behavior.

### 12.3 Interaction standards

-   Primary CTA must be visually distinct and consistently placed.
-   Avoid multiple competing primary CTAs on one screen.
-   Use skeleton/loading states only when loading is genuinely required.
-   Provide clear empty, error, success, and offline states.
-   Confirm destructive actions.
-   Preserve user input when navigating backward.
-   Respect system font scaling and display size.

### 12.4 Accessibility

-   Maintain readable text contrast.
-   Do not rely on color alone to communicate status.
-   Provide semantic labels for controls and exercise media.
-   Ensure tap targets are comfortably sized (aim for at least 48 dp).
-   Support screen readers for key workout actions.
-   Support larger text without clipping critical controls.

## 13. Content and Media Requirements

Each exercise content record should include:

-   Stable exercise ID.
-   Display name and optional localized name.
-   Short description.
-   Primary and secondary muscle groups.
-   Required equipment.
-   Difficulty level.
-   Setup instructions.
-   Execution steps.
-   Breathing cue where appropriate.
-   Common mistakes.
-   Safety notes.
-   Easier variation.
-   Animation asset reference.
-   Video asset reference.
-   Media attribution/license metadata.
-   Content review status and version.

Content quality is a launch requirement. Do not publish an exercise with
missing or unreviewed instructions simply to increase catalog size.

## 14. Data Model --- Conceptual

### UserProfile

-   id
-   displayName
-   age
-   height
-   currentWeight
-   goal
-   experienceLevel
-   preferredSessionDuration
-   preferredTrainingDays
-   unitPreference
-   createdAt
-   updatedAt

### Equipment

-   id
-   name
-   category

### UserEquipment

-   userId
-   equipmentId

### Exercise

-   id
-   name
-   description
-   primaryMuscles
-   secondaryMuscles
-   equipment
-   difficulty
-   instructions
-   commonMistakes
-   safetyNotes
-   easierVariationId
-   animationAsset
-   videoAsset
-   contentVersion

### WorkoutProgram

-   id
-   name
-   description
-   level
-   weeklySchedule
-   durationEstimate
-   equipmentRequirements
-   programVersion

### ProgramExercise

-   id
-   programId
-   dayId
-   exerciseId
-   order
-   targetSets
-   targetRepMin
-   targetRepMax
-   targetDuration
-   restSeconds

### WorkoutSession

-   id
-   programId
-   scheduledDate
-   startedAt
-   endedAt
-   durationSeconds
-   status (in_progress, completed, incomplete, abandoned)
-   notes

### WorkoutSet

-   id
-   sessionId
-   exerciseId
-   setNumber
-   targetReps
-   actualReps
-   targetLoad
-   actualLoad
-   durationSeconds
-   status

### BodyMeasurement

-   id
-   measurementType
-   value
-   unit
-   recordedAt

Use stable IDs and versioned program/content data. Store timestamps
consistently and display them in the user's local time zone.

## 15. Non-Functional Requirements

### Performance

-   Home screen should feel responsive on supported mid-range Android
    devices.
-   Avoid blocking the UI while loading media or calculating summaries.
-   Use appropriately compressed image/video assets.
-   Keep animations smooth without excessive battery use.

### Reliability

-   Workout session data must be persisted incrementally.
-   An app crash must not silently erase the latest completed sets.
-   Timer state must be recoverable after app interruption.
-   Local database migrations must be tested.

### Offline behavior

-   Onboarding, assigned plan, exercise instructions, workout execution,
    history, and core progress summaries should work offline.
-   Remote video may require internet unless cached.
-   If video is unavailable, show the local animation or static
    instructions.

### Security and privacy

-   Minimize personal data collection.
-   Store local data using appropriate Android application storage
    protections.
-   Do not log sensitive profile or measurement data unnecessarily.
-   Provide clear privacy disclosures.
-   If cloud features are introduced later, define encryption,
    authentication, retention, export, and deletion behavior before
    release.

### Compatibility

-   Define the minimum Android version after checking Flutter/plugin
    support and target market analytics.
-   Test different screen sizes, Android navigation modes, and font
    scaling.
-   Follow current Google Play target API and policy requirements at
    release time.

## 16. Analytics and Success Metrics

Analytics should be privacy-conscious and disclosed appropriately. MVP
can begin with local product metrics and add consent-based analytics if
needed.

### North-star metric

**Weekly completed workout sessions per active user.**

### Product metrics

  -----------------------------------------------------------------------
  Metric                              What it measures
  ----------------------------------- -----------------------------------
  Onboarding completion rate          Whether users reach a usable plan

  First workout start rate            Whether users understand the next
                                      action

  First workout completion rate       Whether the workout experience is
                                      usable

  Week-1 return rate                  Early habit formation

  Weekly workout completion           Core engagement

  Session interruption rate           Workout flow reliability

  Exercise instruction opens          Usefulness of guidance

  Crash-free sessions                 Technical quality
  -----------------------------------------------------------------------

Do not optimize for workout volume at the expense of safety or recovery.

## 17. MVP Acceptance Criteria

The MVP is ready for release candidate testing when:

1.  A new user can complete onboarding and receive a compatible plan.
2.  The assigned plan does not require equipment the user does not own.
3.  Every MVP exercise has reviewed instructions and at least one
    working visual demonstration.
4.  A user can start a workout, complete sets, use rest timers, pause,
    resume, and finish.
5.  Active session progress survives app backgrounding and process
    interruption.
6.  Completed and incomplete sessions are stored with correct statuses.
7.  Home and Progress reflect saved workout data accurately.
8.  Core workout functionality works in airplane mode after initial
    installation/content availability.
9.  Empty, loading, offline, and error states are implemented.
10. User can edit profile/preferences and delete local data.
11. No critical or high-severity defects remain in onboarding, workout
    execution, persistence, or data deletion.
12. Privacy policy, store listing, screenshots, and media usage rights
    are ready for public release.

## 18. Testing Strategy

### Functional testing

-   Onboarding validation and resume.
-   Equipment compatibility.
-   Program assignment.
-   Exercise detail and media fallback.
-   Set/repetition recording.
-   Rest timer behavior.
-   Pause/resume/skip/end flows.
-   Workout history and progress calculations.
-   Profile editing and local data deletion.

### Interruption testing

-   Lock screen during workout.
-   Switch to another app.
-   Force close and reopen.
-   Device rotation.
-   Low-memory process termination.
-   Device restart during an active session.

### Device and accessibility testing

-   Small and large Android screens.
-   System font scaling.
-   Screen reader navigation.
-   Light theme contrast.
-   Low-end and mid-range device performance.

### Content testing

-   Verify exercise technique instructions.
-   Verify media matches the named movement.
-   Verify equipment requirements.
-   Verify easier variations and safety notes.
-   Verify commercial usage rights and attribution.

## 19. Risks and Mitigations

  -----------------------------------------------------------------------
  Risk                                Mitigation
  ----------------------------------- -----------------------------------
  Incorrect exercise guidance         Qualified content review before
                                      release

  Users select unsuitable intensity   Beginner-safe defaults and clear
                                      progression

  Video assets increase app size      Optimize, cache selectively, retain
                                      animation fallback

  Workout state is lost               Incremental local persistence and
                                      interruption tests

  Program requires unavailable        Equipment-aware plan validation
  equipment                           

  Scope grows too quickly             Protect MVP non-goals

  Public release privacy issues       Data minimization and policy review

  Users expect medical advice         Clear scope and appropriate
                                      disclaimers
  -----------------------------------------------------------------------

## 20. Release Strategy

### Phase 0 --- Product foundation

-   Confirm UX flows and visual design.
-   Define exercise content schema.
-   Author and review initial exercise library.
-   Define starter workout programs.
-   Confirm local data model.

### Phase 1 --- MVP implementation

-   Onboarding and profile.
-   Plan assignment and Home.
-   Exercise detail and media.
-   Active workout engine.
-   Summary and local history.
-   Basic progress.
-   Privacy and data controls.

### Phase 2 --- Closed testing

-   Internal device testing.
-   Beginner usability testing.
-   Exercise content review.
-   Offline and interruption testing.
-   Fix critical defects and polish UX.

### Phase 3 --- Public launch

-   Play Store listing and screenshots.
-   Privacy policy and required declarations.
-   Store compliance checks.
-   Staged rollout and crash monitoring.
-   Collect feedback and prioritize improvements.

### Post-launch candidates

-   Body-weight and circumference trends.
-   More programs and custom plans.
-   Cloud backup and account sync.
-   Nutrition guidance.
-   Adaptive recommendations.
-   Wearable integrations.

## 21. Open Product Decisions

The following decisions must be resolved before implementation is
considered fully specified:

1.  Final app name, logo, and brand identity.
2.  Initial exercise catalog size and approved content sources.
3.  Final beginner programs for 3, 4, and potentially 5 days.
4.  Exact minimum Android version.
5.  Whether video assets are bundled, streamed, or selectively cached.
6.  Whether user accounts/cloud backup are intentionally deferred from
    launch.
7.  Final privacy policy, analytics approach, and data-retention
    decisions.
8.  Whether body measurements are included in MVP or the first
    post-launch release.

## 22. Definition of Done

A feature is done only when:

-   Its acceptance criteria pass.
-   Loading, empty, error, and offline states are handled where
    relevant.
-   Accessibility and responsive behavior are checked.
-   Data persistence and migration behavior are tested.
-   No sensitive information is exposed in logs.
-   UI follows the approved design system.
-   Automated tests cover critical domain behavior.
-   The feature has been tested on a real Android device.

------------------------------------------------------------------------

## Product North Star

Home Bulking Coach should make a beginner feel:

**"I know what to do today. I understand how to do it. I can see that
I'm getting stronger."**

That is the experience every screen, feature, and technical decision
should support.
