# RaceDay - Event Management System

## Project Overview
RaceDay is a full-stack web-based event management system designed specifically for the South African road running, walking, and cycling community. The platform allows Event Organisers to create and manage events, categories, and participant results, while Participants can browse upcoming events, enter events, track their personal performance history, and prepare for race day using live weather and route information.

## System Roles

### Organiser
- Can create, edit, and delete events
- Manage event categories (e.g., 5km, 10km, 21km)
- Capture and manage participant results
- View all event enrolments
- Send notifications to participants
- Manage event sponsors and images

### Participant
- Can create an account and manage their profile
- Browse and search for upcoming events
- Enter events by selecting a category
- View their own enrolment history
- Track their personal race results and statistics
- Receive notifications about events and results

## Database Design - ERD Rationale
The system requires a minimum of six entities. I designed a database with **nine entities** to properly support all functional requirements while maintaining normalization and scalability.

**Entities:**
1.  **Users** - Core user table with Role check (Organiser, Participant)
2.  **OrganiserProfiles** - Extended profile for organisers (1-1 with Users)
3.  **Events** - Main event table (Cape Town Cycle Tour, Two Oceans, Comrades)
4.  **Categories** - Event categories like 42km, 21km, 10km (Many-1 with Events)
5.  **Enrolments** - Links Users to Categories, stores race numbers & results
6.  **Payments** - Payment tracking for each enrolment (1-1 with Enrolments)
7.  **EventSponsors** - Sponsors per event with levels (Platinum, Gold, Silver)
8.  **Notifications** - User notifications (Event_Update, Result_Published, etc.)
9.  **EventImages** - Gallery, Cover, Route images stored via Azure Blob

All relationships use `ON DELETE CASCADE` and are indexed for performance.

## API Endpoint Plan
All endpoints versioned under `/api/v1/`. Auth uses JWT Bearer tokens.

### Auth
- `POST /api/v1/auth/register` - Register new user (Public)
- `POST /api/v1/auth/login` - Authenticate and return JWT (Public)
- `POST /api/v1/auth/refresh` - Refresh JWT (Logged in)
- `POST /api/v1/auth/logout` - Logout (Logged in)

### Users
- `GET /api/v1/users/me` - Get current user profile
- `PUT /api/v1/users/me` - Update profile
- `GET /api/v1/users/me/enrolments` - Get enrolment history (Participant)
- `GET /api/v1/users/me/results` - Get race results history (Participant)
- `PUT /api/v1/users/me/profile-image` - Upload profile image to Azure Blob

### Events
- `GET /api/v1/events` - Paginated list of all events (Public)
- `GET /api/v1/events/upcoming` - Upcoming events (Public)
- `GET /api/v1/events/{eventId}` - Get detailed event info (Public)
- `POST /api/v1/events` - Create new event (Organiser)
- `PUT /api/v1/events/{eventId}` - Update existing event (Organiser, Creator only)
- `DELETE /api/v1/events/{eventId}` - Delete event (Organiser, Creator only)

### Categories, Enrolments, Payments
- `POST /api/v1/events/{eventId}/categories` - Add category to event (Organiser)
- `POST /api/v1/categories/{categoryId}/enrol` - Enrol in category (Participant)
- `GET /api/v1/events/{eventId}/enrolments` - View all enrolments (Organiser)
- `PUT /api/v1/enrolments/{enrolmentId}/result` - Capture result (Organiser)
- `POST /api/v1/enrolments/{enrolmentId}/payment` - Process payment (Participant)

## Tech Stack
- **Backend:** .NET 8 / ASP.NET Core Web API
- **Database:** Microsoft SQL Server (T-SQL)
- **Auth:** JWT Bearer Tokens
- **Storage:** Azure Blob Storage for images & GPX routes
- **Frontend:** React / Angular (Planned)

## How to Run Locally
1. Clone repo: `git clone https://github.com/YOUR-USERNAME/RaceDay.git`
2. Run SQL script: Execute `database/RaceDay_Database.sql` in SSMS
3. Update connection string in `appsettings.json`
4. Run API: `dotnet run`

## Database Seed Data
Includes 4 users, 2 organiser profiles, 3 major SA events (Cape Town Cycle Tour 2026, Two Oceans Marathon 2026, Comrades Marathon 2026), 6 categories, and sample enrolments.

## Project Structure