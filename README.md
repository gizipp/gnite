# README

## Requirement Overview

Restful APIS to achieve the following:
 1. Clock In operation, and return all clocked-in times, ordered by created time. 
 2. Users can follow and unfollow other users. 
 3. See the sleep records of a user's All following users' sleep records. from the previous week, which are sorted based on the duration of All friends sleep length

### Assumptions Made

- A user cannot have multiple active sleep sessions (can't clock in twice)
- Sleep duration is calculated in minutes
- A "week" is defined as the last 7 days from current time
- For the third requirement, we return sleep records sorted by duration in descending order
- Sleep records without clock_out_at are considered incomplete and excluded from duration-based sorting

## API Endpoints Summary

### Sleep Records

- [v] GET /api/v1/sleep_records - Retrieves user's sleep records
- [v] POST /api/v1/sleep_records/clock_in - Records bedtime and returns all records
- [v] PATCH /api/v1/sleep_records/:id/clock_out - Records wake time

### Follows

- [] POST /api/v1/follows - Follow another user
- [] DELETE /api/v1/follows/:id - Unfollow a user
- [v] GET /api/v1/follows/following_sleep_records - Get friend's sleep records from last week

## System Design Considerations
For handling high volume of data and concurrent requests, I've considered several strategies:

### [] Database Indexing
- Added indexes on frequently queried columns
- Created composite indexes for common query patterns

### [v] Pagination
- All listing endpoints support pagination to prevent memory issues
- Implemented using the Kaminari gem [see reference commit]
(https://github.com/gizipp/gnite/commit/4af73d2)

### [v] Precomputed Data Storage
- Storing duration_minutes directly in the database

### [] API Versioning
- Used /v1/ namespace for all endpoints
- This allows for future API changes without breaking existing clients

### [] Efficient Queries
- Used eager loading with includes to avoid N+1 queries
- Implemented scopes for common query patterns

### Caching

- TBA