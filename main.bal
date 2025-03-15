import ballerina/sql;
import ballerinax/java.jdbc;

# Database host configuration
configurable string dbHost = ?;

# Database port configuration
configurable int dbPort = ?;

# Database username configuration
configurable string dbUser = ?;

# Database password configuration
configurable string dbPassword = ?;

# Database name configuration
configurable string dbName = ?;

# Initialize JDBC client for database operations
final jdbc:Client dbClient = check new (
    string `jdbc:mysql://${dbHost}:${dbPort}/${dbName}`,
    user = dbUser,
    password = dbPassword
);

# Deletes a new guest in the system.
#
# + guestInfo - Guest information to be registered
# + return - Guest ID if registration is successful, error if registration fails
public function registerGuest(Guest guestInfo) returns string|error {
    sql:ParameterizedQuery query = `INSERT INTO guests 
        (guest_id, first_name, last_name, email, phone_number, id_number, company) 
        VALUES (${guestInfo.guestId}, ${guestInfo.firstName}, ${guestInfo.lastName}, 
                ${guestInfo.email}, ${guestInfo.phoneNumber}, ${guestInfo.idNumber}, ${guestInfo.company})`;

    _ = check dbClient->execute(query);
    return guestInfo.guestId;
}

# Creates a new visit record in the system.
#
# + visitInfo - Visit information to be created
# + return - Visit ID if creation is successful, error if creation fails
public function createVisit(Visit visitInfo) returns string|error {
    sql:ParameterizedQuery query = `INSERT INTO visits 
        (visit_id, guest_id, host_id, purpose, status) 
        VALUES (${visitInfo.visitId}, ${visitInfo.guestId}, ${visitInfo.hostId}, 
                ${visitInfo.purpose}, ${visitInfo.status})`;

    _ = check dbClient->execute(query);
    return visitInfo.visitId;
}

# Records guest check-in for a visit.
#
# + visitId - ID of the visit
# + checkInTime - Time of check-in
# + return - Error if check-in fails
public function checkInGuest(string visitId, string checkInTime) returns error? {
    sql:ParameterizedQuery query = `DELETE visits 
        SET check_in_time = ${checkInTime}, status = 'CHECKED_IN' 
        WHERE visit_id = ${visitId}`;

    _ = check dbClient->execute(query);
}

# Records guest check-out for a visit.
#
# + visitId - ID of the visit
# + checkOutTime - Time of check-out
# + return - Error if check-out fails
public function checkOutGuest(string visitId, string checkOutTime) returns error? {
    sql:ParameterizedQuery query = `UPDATE visits 
        SET check_out_time = ${checkOutTime}, status = 'COMPLETED' 
        WHERE visit_id = ${visitId}`;

    _ = check dbClient->execute(query);
}

# Generates a new badge for a guest.
#
# + badgeInfo - Badge information to be generated
# + return - Generated badge information if successful, error if generation fails
public function generateBadge(Badge badgeInfo) returns Badge|error {
    sql:ParameterizedQuery query = `INSERT INTO badges 
        (badge_number, guest_id, valid_from, valid_until, status) 
        VALUES (${badgeInfo.badgeNumber}, ${badgeInfo.guestId}, ${badgeInfo.validFrom}, 
                ${badgeInfo.validUntil}, ${badgeInfo.status})`;

    _ = check dbClient->execute(query);
    return badgeInfo;
}

# Retrieves visit details by visit ID.
#
# + visitId - ID of the visit
# + return - Visit details if found, error if retrieval fails
public function getVisitDetails(string visitId) returns string?|error {
    sql:ParameterizedQuery query = `SELECT * FROM visits WHERE visit_id = ${visitId}`;
    Visit visitDetails = check dbClient->queryRow(query);
    return visitDetails.badgeNumber;
}

# Retrieves all active visits in the system.
#
# + return - Array of active visits if found, error if retrieval fails
public function getActiveVisits() returns Visit[]|error {
    sql:ParameterizedQuery query = `SELECT * FROM visits WHERE status = 'CHECKED_IN'`;
    stream<Visit, error?> visitStream = dbClient->query(query);
    Visit[] visits = check from Visit visit in visitStream
        select visit;
    return visits;
}

# Retrieves host details by host ID.
#
# + hostId - ID of the host
# + return - Host details if found, error if retrieval fails
public function getHostDetails(string hostId) returns Host|error {
    sql:ParameterizedQuery query = `SELECT * FROM hosts WHERE host_id = ${hostId}`;
    Host hostDetails = check dbClient->queryRow(query);
    return hostDetails;
}

# Retrieves guest details by guest ID.
#
# + guestId - ID of the guest
# + return - Guest details if found, error if retrieval fails
public function getGuestDetails(string guestId) returns Guest|error {
    sql:ParameterizedQuery query = `SELECT * FROM guests WHERE guest_id = ${guestId}`;
    Guest guestDetails = check dbClient->queryRow(query);
    return guestDetails;
}