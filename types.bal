# Represents a student in the school.
#
# + guestId - Unique identifier for the guest
# + firstName - First name of the guest
# + lastName - Last name of the guest
# + email - Email address of the guest
# + phoneNumber - Contact number of the guest
# + company - Company or organization the guest represents
# + idType - Type of identification provided (e.g., "Passport", "Driver's License")
# + idNumber - Identification number from the provided ID
# + photoId - Reference to the guest's photo ID image
public type Guest record {|
    string guestId?;
    string firstName;
    string lastName;
    string email;
    string phoneNumber;
    string company;
    string idType;
    string idNumber;
    string photoId?;
|};

# Represents a host in the organization.
#
# + hostId - Unique identifier for the host
# + firstName - First name of the host
# + lastName - Last name of the host
# + email - Email address of the host
# + department - Department where the host works
# + phoneNumber - Contact number of the host
public type Host record {|
    string hostId;
    string firstName;
    string lastName;
    string email;
    string department;
    string phoneNumber;
|};

# Represents a visit record in the system.
#
# + visitId - Unique identifier for the visit
# + guestId - Reference to the guest making the visit
# + hostId - Reference to the host being visited
# + purpose - Purpose of the visit
# + checkInTime - Time when the guest checked in
# + checkOutTime - Time when the guest checked out
# + status - Current status of the visit (e.g., "SCHEDULED", "CHECKED_IN", "COMPLETED")
# + qrCode - QR code associated with the visit for check-in/out
public type Visit record {|
    int visitId?;
    string guestId;
    string hostId;
    string purpose;
    string checkInTime?;
    string checkOutTime?;
    string status;
    string qrCode?;
|};

# Represents a visitor badge in the system.
#
# + badgeId - Unique identifier for the badge
# + guestId - Reference to the guest the badge is issued to
# + visitId - Reference to the associated visit
# + badgeType - Type of badge issued
# + validFrom - Badge validity start time
# + validTo - Badge validity end time
# + accessLevel - Access level granted by the badge
public type Badge record {|
    string badgeId?;
    string guestId;
    string visitId;
    string badgeType;
    string validFrom;
    string validTo;
    string accessLevel;
|};

# Represents a log entry for visit-related actions.
#
# + logId - Unique identifier for the log entry
# + visitId - Reference to the associated visit
# + action - Type of action performed (e.g., "CHECK_IN", "CHECK_OUT")
# + timestamp - Time when the action was performed
# + details - Additional details about the action
public type VisitLog record {|
    int logId?;
    int visitId;
    string action;
    string timestamp;
    string details;
|};