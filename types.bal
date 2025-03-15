# Represents different user roles in the Guest Management System.
public enum Role {
    # Guest role for visitors
    GUEST,
    # Host role for employees receiving guests
    HOST,
    # Receptionist role for managing guest check-in/out
    RECEPTIONIST,
    # Security role for monitoring visits
    SECURITY
}

# Represents guest information in the system.
#
# + guestId - Unique identifier for the guest
# + firstName - First name of the guest
# + lastName - Last name of the guest
# + email - Email address of the guest
# + phoneNumber - Contact number of the guest
# + idNumber - Government issued ID number
# + company - Optional company name of the guest
public type Guest record {|
    string guestId;
    string firstName;
    string lastName;
    string email;
    string phoneNumber;
    string idNumber;
    string company?;
|};

# Represents host information in the system.
#
# + hostId - Unique identifier for the host
# + firstName - First name of the host
# + lastName - Last name of the host
# + email - Email address of the host
# + department - Department of the host
# + phoneNumber - Contact number of the host
public type Host record {|
    string hostId;
    string firstName;
    string lastName;
    string email;
    string department;
    string phoneNumber;
|};

# Represents student information in the school.
#
# + visitId - Unique identifier for the visit
# + guestId - ID of the guest
# + hostId - ID of the host
# + purpose - Purpose of the visit
# + checkInTime - Time of check-in
# + checkOutTime - Time of check-out
# + badgeNumber - Assigned badge number
# + status - Current status of the visit
public type Visit record {|
    string visitId;
    string guestId;
    string hostId;
    string purpose;
    string checkInTime?;
    string checkOutTime?;
    string badgeNumber?;
    string status;
|};

# Represents badge information in the system.
#
# + badgeNumber - Unique badge number
# + guestId - ID of the guest assigned to the badge
# + validFrom - Badge validity start time
# + validUntil - Badge validity end time
# + status - Current status of the badge
public type Badge record {|
    string badgeNumber;
    string guestId;
    string validFrom;
    string validUntil;
    string status;
|};