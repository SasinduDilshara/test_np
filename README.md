# Guest Management System

A comprehensive visitor management system built with Ballerina that handles guest registration, visit tracking, and badge management.

## Overview

The Guest Management System (GMS) is designed to streamline the process of managing visitors in an organization. It provides functionality for guest registration, visit tracking, badge generation, and maintaining records of hosts and guests.

## Features

- Visit Creation and Tracking
- Check-in/Check-out Management
- Badge Generation and Management
- Host Information Management
- Active Visit Monitoring

## API Functions

### Guest Management
- `registerGuest(Guest) returns string|error` - Register a new guest
- `getGuestDetails(string) returns Guest|error` - Retrieve guest information

### Visit Management
- `createVisit(int) returns string|error` - Create a new visit record
- `checkInGuest(string, string) returns error?` - Record guest check-in
- `checkOutGuest(string, string) returns error?` - Record guest check-out
- `getVisitDetails(string) returns string?|error` - Get visit details
- `getActiveVisits() returns Visit[]|error` - Get all active visits

### Host Management
- `getHostDetails(string) returns Host|error` - Retrieve host information

### Badge Management
- `generateBadge(Badge) returns Badge|error` - Generate visitor badge

## Configuration

The system requires the following configurations:

```toml
# Config.toml
dbHost = "localhost"
dbPort = 3306
dbUser = "username"
dbPassword = "password"
dbName = "gms_db"
```

## Prerequisites

- Ballerina Swan Lake
- MySQL Database

## Setup Instructions

1. Clone the repository
2. Configure the database connection in `Config.toml`
3. Run the application using `bal run`

## Database Schema

The system requires the following database tables:
- guests
- hosts
- visits
- badges

## User Roles

The system supports four user roles:
- GUEST - Visitors to the organization
- HOST - Employees receiving guests
- RECEPTIONIST - Staff managing check-in/out
- SECURITY - Personnel monitoring visits

## License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## Contributing

Contributions are welcome. Please fork the repository and submit a pull request with your changes.