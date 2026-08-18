# Driving School Management System (DSMS) — Admin User Documentation V1.0

This guide outlines system operations, module field specifications, and workflows for **DSMS Administrators**.

---

## 1. Getting Started & Authentication

### 1.1 First Launch & Onboarding
1. On initial app launch, review the onboarding slides highlighting scheduling, curriculum, and payment tracking.
2. Tap **Get Started** or **Skip** to reach the Sign In screen.

### 1.2 Sign In & Session Management
- **Sign In**: Enter your registered administrator email address and password.
- **Remember Me**: Enable *Remember Me* to remain signed in across app sessions.
- **Forgot Password**: Tap *Forgot Password*, enter your registered email, verify the OTP code, and set a new secure password.

---

## 2. Admin Dashboard Modules & Form Input Fields

The DSMS admin portal provides seven core modules:

| Tab | Module | Admin Responsibilities | Model Input Fields |
| :--- | :--- | :--- | :--- |
| **0** | **Overview Dashboard** | Real-time KPI monitoring, student metrics, lesson charts, and revenue statistics. | `Total Students`, `Active Instructors`, `Open Schedules`, `Recent Payments` |
| **1** | **Students** | Create student user accounts, manage student profile & identity information, assign usernames, and manage active/inactive status. | `firstName`, `middleName`, `lastName`, `username`, `email`, `contact/phone`, `gender`, `birthdate`, `address`, `accountStatus`, `role` |
| **2** | **Instructors** | Provision instructor staff accounts, assign transmission vehicle types (Manual/Auto), set driving experience years, and monitor teaching load. | `firstName`, `middleName`, `lastName`, `username`, `email`, `contact/phone`, `gender`, `birthdate`, `address`, `drivingExperience`, `vehicleType`, `accountStatus` |
| **3** | **Enrolments** | Register students into training curriculum packages, set enrolment dates, and track payment status. | `enrolmentId`, `studentName`, `packageName`, `enrolmentDate`, `paymentStatus` |
| **4** | **Schedules** | Create driving training sessions, assign instructors, set available seat slots, and track completion. | `scheduleCode`, `date`, `time`, `instructor/instructorId`, `slotsAvailable`, `totalSlots`, `amount`, `remarks`, `status` |
| **5** | **Payments** | Record financial transactions, issue digital receipts, and deduct student balances. | `transactionId`, `studentName`, `amount`, `date`, `method` |
| **6** | **Packages** | Define driving course packages, syllabus descriptions, duration, and course fees. | `name/packageName`, `description`, `price` |

---

## 3. Core Admin Workflows

### 3.1 Provisioning a Student Account
1. Open the **Students** tab and tap **Add Student**.
2. Complete the profile fields: Name, Username, Email, Phone, Gender, Birthdate, and Address.
3. Save the record to create the account.

### 3.2 Provisioning an Instructor Account
1. Open the **Instructors** tab and tap **Add Instructor**.
2. Complete the profile fields: Name, Email, Phone, Years of Driving Experience, and Assigned Vehicle Type (Manual/Automatic).
3. Save the record to activate the instructor profile.

### 3.3 Enrolling a Student & Creating Session Schedules
1. Go to **Enrolments** $\rightarrow$ select the Student and desired Training Package.
2. Go to **Schedules** $\rightarrow$ create time slots, assign the Instructor, and confirm the booking.
3. Go to **Payments** $\rightarrow$ record payment received (Cash, Bank Transfer, Card, Mobile Money) and generate the invoice.
