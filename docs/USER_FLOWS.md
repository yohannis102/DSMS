# DSMS - Admin System Architecture & Operational Flows

This document contains visual operational flows for the **DSMS (Driving School Management System)** focused on **Administrator Operations**.

> [!TIP]
> **How to edit these diagrams visually in Draw.io:**
> 1. Open **[Draw.io (app.diagrams.net)](https://app.diagrams.net)**.
> 2. Click **`+` (Insert)** in the top toolbar $\rightarrow$ **`Advanced`** $\rightarrow$ **`Mermaid`**.
> 3. Copy any of the Mermaid code blocks below and paste it into Draw.io.
> 4. Click **Insert** to generate fully customizable drag-and-drop vector diagrams.

---

## 1. Master Admin Navigation & Auth Flow

```mermaid
flowchart TD
    Start([Launch DSMS App]) --> AppGate{AppGate Check}
    
    AppGate -->|First Time Launch| Onboarding[Onboarding Slides]
    Onboarding --> AuthPage[Sign In Screen]
    
    AppGate -->|Remember Me Active| Dashboard[Admin Dashboard]
    AppGate -->|Not Logged In| AuthPage
    
    AuthPage --> Login[Enter Registered Email & Password]
    AuthPage --> ForgotPass[Forgot Password / Reset OTP]
    ForgotPass --> ResetSuccess[Password Updated] --> Login
    
    Login --> AuthSuccess{Authenticated?}
    AuthSuccess -->|Yes| Dashboard
    AuthSuccess -->|No| ErrorPrompt[Display Error Notification]
    ErrorPrompt --> Login

    subgraph NavigationTabs [Admin Dashboard Modules]
        Dashboard --> Tab0[0. Overview Dashboard]
        Dashboard --> Tab1[1. Students Management]
        Dashboard --> Tab2[2. Instructors Management]
        Dashboard --> Tab3[3. Course Enrolments]
        Dashboard --> Tab4[4. Schedules & Slots]
        Dashboard --> Tab5[5. Payment & Invoicing]
        Dashboard --> Tab6[6. Training Packages]
    end
```

---

## 2. Complete Admin Operational Lifecycle Flow

```mermaid
flowchart TD
    AdminLogin([Admin Signed In]) --> AdminDashboard[Access Admin Dashboard]
    
    AdminDashboard --> Step1[1. Create / Configure Training Packages]
    Step1 --> Step2[2. Provision Instructor Account & Assign Vehicle]
    Step2 --> Step3[3. Create Student Account & Profile Details]
    
    Step3 --> Step4[4. Enrol Student into Training Package]
    Step4 --> Step5[5. Schedule Driving Training Slots]
    
    Step5 --> Step6[6. Record Payment & Issue Receipt]
    Step6 --> Step7[7. Mark Completed Sessions & Review Analytics on Dashboard]
    
    Step7 --> End([Operational Cycle Complete])
```
