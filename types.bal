// Represents a claim in the system
public type Claim record {|
    string claimId;
    string userId;
    decimal amount;
    string status;
    string description;
|};

// Request type for claim submission
public type ClaimRequest record {|
    decimal amount;
    string description;
|};

// Response type for claim submission
public type ClaimResponse record {|
    string claimId;
    string status;
    string message;
|};

// Response type for claim status
public type StatusResponse record {|
    string status;
    string message;
|};

// Response type for claim deletion
public type DeleteResponse record {|
    boolean success;
    string message;
|};

// Transaction log record
public type TransactionLog record {|
    string logId;
    string operation;
    string claimId;
    string userId;
    string details;
|};