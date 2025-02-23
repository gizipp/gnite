### Introduction

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

- [v] POST /api/v1/follows - Follow another user
- [v] DELETE /api/v1/follows/:id - Unfollow a user
- [v] GET /api/v1/follows/following_sleep_records - Get friend's sleep records from last week

Note: Currently, the `user_id` parameter or X-User-Id is used as  auth `current_user` implementation. In a real application, this would be handled by authentication

## System Design Considerations
For handling high volume of data and concurrent requests, I've considered several strategies:

### [v] Database Indexing [(ref)](https://github.com/gizipp/gnite/blob/main/db/schema.rb)
- Added indexes on frequently queried columns
- Created composite indexes for common query patterns

### [v] Pagination
- All listing endpoints support pagination to prevent memory issues
- Implemented using the Kaminari gem - [(ref)](https://github.com/gizipp/gnite/commit/4af73d2)

### [v] Precomputed Data Storage
- Storing duration_minutes directly in the database [(ref)](https://github.com/gizipp/gnite/commit/d37062139e9583205d47f763d88a5756dcb66107#diff-532bed2fbfac2ee988121ace44b08bfe1224215e323473e0eff026e20c6a5fd5R22/gizipp/gnite/commit/4af73d2)

### [v] API Versioning
- Used /v1/ namespace for all endpoints
- This allows for future API changes without breaking existing clients

### [v] Efficient Queries
- Used eager loading with includes to avoid N+1 queries - [(ref)](https://github.com/gizipp/gnite/commit/4286c35b104d0bf40f7dc4d11b6e25b49b264b54#diff-532bed2fbfac2ee988121ace44b08bfe1224215e323473e0eff026e20c6a5fd5R22)
- Implemented scopes for common query patterns

### [v] Caching
- Query optimization with caching [(ref)](https://github.com/gizipp/gnite/commit/d76f42495befe3c453f3bc3e0a45afd06ea0c8f6)

## Metrics Target

### Performance
- [x] P95 < 300ms
- [x] P99 < 500ms
- [x] Average < 200ms

## Reliability
- [v] Error rate < 1%
- [v] Success rate > 99%

## Throughput
- [v] Min 50 RPS
- [v] Handle spike 2.5x (20 -> 50 concurrent users)

### Device Used During Perf Test
- Intel(R) Core(TM) i5-1038NG7 CPU @ 2.00GHz 16GB / Disk Size: 500.3 GB
- postgres (PostgreSQL) 14.16 (Homebrew)
- ruby 3.1.2p20 (2022-04-12 revision 4491bb740a) [x86_64-darwin21]
- Rails 7.0.8.7
- TODO: Setup isolated containerized env for more less bias result