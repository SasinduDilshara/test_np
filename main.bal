import ballerina/sql;
import ballerinax/mysql;

// Configurable variables for MySQL database
configurable string dbHost = "localhost";
configurable int dbPort = 3306;
configurable string dbUser = "root";
configurable string dbPassword = "";
configurable string dbName = "gms_db";

// Initialize MySQL Client
final mysql:Client mysqlClient = check new (
    host = dbHost,
    user = dbUser,
    password = dbPassword,
    port = dbPort,
    database = dbName
);

# deletes a new guest in the system.
#
# + guest - Guest record containing the guest details
# + return - Guest ID if registration is successful, error if registration fails
public function registerGuest(Guest guest) returns string|error {
    sql:ExecutionResult result = check mysqlClient->execute(`
        INSERT INTO guests (first_name, last_name, email, phone_number, company, id_type, id_number, photo_id)
        VALUES (${guest.firstName}, ${guest.lastName}, ${guest.email}, ${guest.phoneNumber}, 
                ${guest.company}, ${guest.idType}, ${guest.idNumber}, ${guest.photoId});
    `);

    string|int? guestId = result.lastInsertId;
    if guestId is string {
        return guestId;
    }
    return error("Failed to get guest ID");
}

# Retrieves guest details by guest ID.
#
# + guestId - ID of the guest
# + return - Guest record if found, error if retrieval fails
public function getGuestDetails(string guestId) returns Guest|error {
    Guest guest = check mysqlClient->queryRow(`
        SELECT * FROM guests WHERE guest_id = ${guestId}
    `);
    return guest;
}

# Creates a new visit record for a guest.
#
# + guestId - ID of the guest making the visit
# + return - Visit ID if creation is successful, error if creation fails
public function createVisit(int guestId) returns string|error {

    sql:ExecutionResult result = check mysqlClient->execute(`
        INSERT INTO visits (guest_id, status)
        VALUES (${guestId}, 'SCHEDULED')
    `);

    string|int? visitId = result.lastInsertId;
    if visitId is string {
        return visitId;
    }
    return error("Failed to create visit");
}

# Records a guest check-out.
#
# + visitId - ID of the visit
# + checkInTime - Time of check-in
# + return - Error if check-in fails
public function checkInGuest(int visitId, string checkInTime) returns error? {
    _ = check mysqlClient->execute(`
        UPDATE visits 
        SET status = 'CHECKED_IN', check_in_time = ${checkInTime}
        WHERE visit_id = ${visitId}
    `);

    _ = check mysqlClient->execute(`
        INSERT INTO visit_logs (visit_id, action, timestamp, details)
        VALUES (${visitId}, 'CHECK_IN', ${checkInTime}, 'Guest checked in')
    `);
}

# Records a guest check-out.
#
# + visitId - ID of the visit
# + checkOutTime - Time of check-out
# + return - Error if check-out fails
public function checkOutGuest(int visitId, string checkOutTime) returns error? {
    _ = check mysqlClient->execute(`
        UPDATE visits 
        SET status = 'COMPLETED', check_out_time = ${checkOutTime}
        WHERE visit_id = ${visitId}
    `);

    _ = check mysqlClient->execute(`
        INSERT INTO visit_logs (visit_id, action, timestamp, details)
        VALUES (${visitId}, 'CHECK_OUT', ${checkOutTime}, 'Guest checked out')
    `);
}

# Retrieves visit details by visit ID.
#
# + visitId - ID of the visit
# + return - Visit details as a string if found, nil if not found, error if retrieval fails
public function getVisitDetails(string visitId) returns string?|error {
    Visit|error visit = check mysqlClient->queryRow(`
        SELECT * FROM visits WHERE visit_id = ${visitId}
    `);
    if visit is error {
        return ();
    }
    return visit.toString();
}

# Retrieves all active visits in the system.
#
# + return - Array of active visits if successful, error if retrieval fails
public function getActiveVisits() returns Visit[]|error {
    stream<Visit, error?> visitStream = mysqlClient->query(`
        SELECT * FROM visits 
        WHERE status = 'CHECKED_IN'
    `);
    Visit[] visits = check from Visit visit in visitStream
        select visit;
    return visits;
}

# Retrieves host details by host ID.
#
# + hostId - ID of the host
# + return - Host record if found, error if retrieval fails
public function getHostDetails(string hostId) returns Host|error {
    Host host = check mysqlClient->queryRow(`
        SELECT * FROM hosts WHERE host_id = ${hostId}
    `);
    return host;
}

# Generates a new badge for a visitor.
#
# + badge - Badge record containing badge details
# + return - Updated badge record with badge ID if successful, error if generation fails
public function generateBadge(Badge badge) returns Badge|error {
    sql:ExecutionResult result = check mysqlClient->execute(`
        INSERT INTO badges (guest_id, visit_id, badge_type, valid_from, valid_to, access_level)
        VALUES (${badge.guestId}, ${badge.visitId}, ${badge.badgeType}, 
                ${badge.validFrom}, ${badge.validTo}, ${badge.accessLevel})
    `);

    string|int? badgeId = result.lastInsertId;
    if badgeId is string {
        badge.badgeId = badgeId;
        return badge;
    }
    return error("Failed to generate badge");
}

# Logs a visit-related action.
#
# + log - Log record containing action details
# + return - Error if logging fails
public function logVisitAction(VisitLog log) returns error? {
    _ = check mysqlClient->execute(`
        INSERT INTO visit_logs (visit_id, action, timestamp, details)
        VALUES (${log.visitId}, ${log.action}, ${log.timestamp}, ${log.details})
    `);
}