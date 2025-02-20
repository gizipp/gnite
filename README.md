# README

## API Endpoints Summary

### Sleep Records

- GET /api/v1/sleep_records - Retrieves user's sleep records
- POST /api/v1/sleep_records/clock_in - Records bedtime and returns all records
- PATCH /api/v1/sleep_records/:id/clock_out - Records wake time

### Follows

- POST /api/v1/follows - Follow another user
- DELETE /api/v1/follows/:id - Unfollow a user
- GET /api/v1/follows/following_sleep_records - Get friend's sleep records from last week

## Assumptions Made

- A user cannot have multiple active sleep sessions (can't clock in twice)
- Sleep duration is calculated in minutes
- A "week" is defined as the last 7 days from current time
- For the third requirement, we return sleep records sorted by duration in descending order
- Sleep records without clock_out_at are considered incomplete and excluded from duration-based sorting